self: super: {
  # replace intel-compute-runtime with intel-compute-runtime-legacy1 for legacy Gen8, Gen9 and Gen11 Intel GPUs
  intel-compute-runtime = super.intel-compute-runtime-legacy1;

  # create symlink for intel-opencl/libigdrcl_legacy1.so
  super.systemd.tmpfiles.rules =
    let
      createLink = src: dest: "L+ ${dest} - - - - ${src}";
    in
    [
      (createLink "${super.pkgs.intel-compute-runtime-legacy1}/lib/intel-opencl/libigdrcl_legacy1.so" "/usr/lib/x86_64-linux-gnu/intel-opencl/libigdrcl_legacy1.so")
    ];
}