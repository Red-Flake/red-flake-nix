# Wraps REA with the optional tools it only finds through absolute REA_* paths.
# REA checks most of these versions exactly, so several are pinned below.
# Every variable uses --set-default, so an MCP registration can still override it.
#
# Not wired up:
#   - sigrok-cli: REA wants exactly 0.7.2, nixpkgs ships 0.8.0.
#   - pwndbg core context: wants pwndbg 2026.09.15 as a venv + gdbinit.
#   - Hopper, IDA, JEB, Kuna: commercial or external.
{ lib
, stdenv
, rea
, symlinkJoin
, makeWrapper
, fetchurl
, fetchFromGitHub
, autoPatchelfHook
, util-linux
, wabt
, binwalk
, unblob
, unicorn
, python3
, chromium
, wireshark-cli
}:

let
  # recover_javascript_sources: Wakaru ^1.13.0, verified with 1.14.0.
  # Upstream ships a plain Rust binary per platform.
  wakaru = stdenv.mkDerivation (finalAttrs: {
    pname = "wakaru";
    version = "1.14.0";

    src = fetchurl {
      url = "https://github.com/pionxzh/wakaru/releases/download/v${finalAttrs.version}/wakaru-linux-x64.tar.gz";
      hash = "sha256-2w5iADRyMZWrQm6U0A1V29j9AQapKK2iVj8RAxltCfo=";
    };

    sourceRoot = ".";
    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ stdenv.cc.cc.lib ];

    installPhase = ''
      runHook preInstall
      install -Dm755 wakaru "$out/bin/wakaru"
      runHook postInstall
    '';

    meta = {
      description = "JavaScript decompiler for bundled and minified code";
      homepage = "https://github.com/pionxzh/wakaru";
      license = lib.licenses.mit;
      mainProgram = "wakaru";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  });

  # inspect_wasm_artifact: exactly WABT 1.0.42 (nixpkgs has 1.0.41).
  wabt_1_0_42 = wabt.overrideAttrs (finalAttrs: _: {
    version = "1.0.42";
    src = fetchFromGitHub {
      owner = "WebAssembly";
      repo = "wabt";
      tag = finalAttrs.version;
      hash = "sha256-33XpYt42Jw2xfwBR64jVI3VYVIKD1YjND9SSI6CdkaM=";
      fetchSubmodules = true;
    };
  });

  # inspect_binary_layout / inspect_recorded_crash: exactly pwntools 4.15.0,
  # pyelftools 0.33 and unicorn 2.1.2 (nixpkgs has 0.32 and 2.1.4).
  unicorn_2_1_2 = unicorn.overrideAttrs (finalAttrs: _: {
    version = "2.1.2";
    src = fetchFromGitHub {
      owner = "unicorn-engine";
      repo = "unicorn";
      tag = finalAttrs.version;
      hash = "sha256-qA84xBztyWmt/rUExhhZMkQzvDPx0UE9MAIPG/Su3iE=";
    };
  });

  pwntoolsPython =
    let
      python = python3.override {
        self = python;
        packageOverrides = _: pyPrev: {
          pyelftools = pyPrev.pyelftools.overridePythonAttrs (_: rec {
            version = "0.33";
            src = fetchFromGitHub {
              owner = "eliben";
              repo = "pyelftools";
              tag = "v${version}";
              hash = "sha256-NqF5A6PRl4uncwNS9j44fIV7ovlljiucvV2Msv0LK/w=";
            };
          });
          unicorn = (pyPrev.unicorn.override { unicorn = unicorn_2_1_2; }).overridePythonAttrs (old: {
            # 2.1.2 reads its version from git via versioningit; the source has
            # no .git, so pin it in pyproject.toml instead.
            postPatch = (old.postPatch or "") + ''
              substituteInPlace pyproject.toml \
                --replace-fail 'dynamic = ["version"]' 'version = "${unicorn_2_1_2.version}"' \
                --replace-fail ', "versioningit"' ""
              sed -i '/^\[tool\.versioningit\]/d' pyproject.toml
            '';
            # Its tests want capstone 6.0.0a2; the import check still runs.
            doCheck = false;
          });
        };
      };
    in
    python.withPackages (ps: [ ps.pwntools ]);

  # Android tools (inspect_android_*): jadx-headless-mcp 0.7.1. REA reports
  # this exact sha256 as the verified build.
  jadxMcpJar = fetchurl {
    url = "https://github.com/1013503897/jadx-headless-mcp/releases/download/v0.7.1/jadx-headless-mcp-0.7.1-all.jar";
    hash = "sha256-bl6s9QC2QpK/tzxJeXwZWPbuRGRuQ+hoA5rn/rVz/3U=";
  };

  # REA defaults every resource limiter to /usr/bin/prlimit.
  prlimit = lib.getExe' util-linux "prlimit";
  prlimitVariables = [
    "REA_JAVASCRIPT_PRLIMIT_COMMAND"
    "REA_FIRMWARE_PRLIMIT_COMMAND"
    "REA_TSHARK_PRLIMIT_COMMAND"
    "REA_EVM_PRLIMIT_COMMAND"
    "REA_SIGROK_PRLIMIT_COMMAND"
  ];

  wrapperArgs = lib.concatStringsSep " " (
    map (name: "--set-default ${name} ${prlimit}") prlimitVariables
    ++ [
      "--set-default REA_WAKARU_COMMAND ${lib.getExe wakaru}"
      "--set-default REA_WABT_BIN_DIRECTORY ${wabt_1_0_42}/bin"
      "--set-default REA_PWNTOOLS_PYTHON ${pwntoolsPython.interpreter}"
      "--set-default REA_JADX_MCP_JAR ${jadxMcpJar}"
      "--set-default REA_BINWALK_COMMAND ${lib.getExe binwalk}"
      "--set-default REA_UNBLOB_COMMAND ${lib.getExe unblob}"
      # inspect_packet_capture needs absolute TShark/capinfos paths on Linux.
      "--set-default REA_TSHARK_COMMAND ${lib.getExe' wireshark-cli "tshark"}"
      "--set-default REA_CAPINFOS_COMMAND ${lib.getExe' wireshark-cli "capinfos"}"
      # trace_web_module_imports native resolution (import.meta.resolve).
      "--set-default REA_BROWSER_EXECUTABLE ${lib.getExe chromium}"
    ]
  );
in
symlinkJoin {
  name = "rea-agents-${rea.version}";
  inherit (rea) version;
  paths = [ rea ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    for program in rea rea-agents; do
      wrapProgram "$out/bin/$program" ${wrapperArgs}
    done
  '';

  passthru = {
    unwrapped = rea;
    inherit wakaru pwntoolsPython jadxMcpJar;
    wabt = wabt_1_0_42;
  };

  meta = rea.meta // {
    mainProgram = "rea";
  };
}
