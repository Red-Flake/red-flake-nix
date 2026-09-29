{ pkgs }:
pkgs.hyprlandPlugins.mkHyprlandPlugin {
  pluginName = "stellaris-desktop";
  version = "1";
  src = ./.;
  nativeBuildInputs = [ pkgs.wayland-scanner ];
  buildInputs = [ pkgs.nlohmann_json ];
  buildPhase = ''
    protocol=${pkgs.kdePackages.plasma-wayland-protocols}/share/plasma-wayland-protocols/appmenu.xml
    wayland-scanner server-header "$protocol" appmenu.h
    wayland-scanner private-code "$protocol" appmenu.c
    $CC -fPIC -c appmenu.c $(pkg-config --cflags wayland-server) -o appmenu.o
    $CXX -shared -fPIC -std=c++23 main.cpp appmenu.o -o libstellaris-desktop.so \
      $(pkg-config --cflags hyprland pixman-1 libdrm libinput libudev wayland-server xkbcommon) \
      $(pkg-config --libs wayland-server)
  '';
  installPhase = ''
    install -Dm755 libstellaris-desktop.so "$out/lib/libstellaris-desktop.so"
  '';
  meta.description = "Stellaris native minimize requests and per-window application menu metadata";
}
