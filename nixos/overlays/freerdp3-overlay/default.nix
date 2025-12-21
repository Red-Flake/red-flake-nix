_self: super: {
  freerdp3 = super.freerdp3.overrideAttrs (old: rec {
    # Keep the same version, but ensure the channel flag is enabled
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      "-DWITH_RDP2TCP=ON"
      "-DCHANNEL_RDP2TCP=ON"
    ];

    # (Optional) make debugging verbose so you can see why things do/don't build:
    # You can uncomment the next line if you want very verbose make output
    # NIX_CMAKE_FLAGS = (old.NIX_CMAKE_FLAGS or "") + " -DCMAKE_VERBOSE_MAKEFILE=ON";
  });
}
