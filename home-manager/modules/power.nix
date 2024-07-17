{ config, lib, pkgs, ... }:
{
    # disable automatic sleep
    home.file.".config/powerdevilrc".text = ''
        [AC][Display]
        DimDisplayIdleTimeoutSec=600
        TurnOffDisplayIdleTimeoutSec=900

        [AC][SuspendAndShutdown]
        AutoSuspendAction=0

        [Battery][Display]
        DimDisplayIdleTimeoutSec=600
        TurnOffDisplayIdleTimeoutSec=900

        [Battery][SuspendAndShutdown]
        AutoSuspendAction=0
    '';
}