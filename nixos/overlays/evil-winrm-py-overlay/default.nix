_: prev:
{
  evil-winrm-py = prev.evil-winrm-py.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ./pypsrp-0.9.1-transport-send.patch
    ];
  });
}
