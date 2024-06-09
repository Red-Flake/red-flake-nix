{ config, lib, pkgs, ... }:
{
  home.file.".config/bloodhound/config.json".force = true;
  home.file.".config/bloodhound/config.json".text = ''
{
        "performance": {
                "edge": 5,
                "lowGraphics": false,
                "nodeLabels": 1,
                "edgeLabels": 1,
                "darkMode": true
        },
        "edgeincluded": {
                "MemberOf": true,
                "HasSession": true,
                "AdminTo": true,
                "AllExtendedRights": true,
                "AddMember": true,
                "ForceChangePassword": true,
                "GenericAll": true,
                "GenericWrite": true,
                "Owns": true,
                "WriteDacl": true,
                "WriteOwner": true,
                "CanRDP": true,
                "ExecuteDCOM": true,
                "AllowedToDelegate": true,
                "ReadLAPSPassword": true,
                "Contains": true,
                "GPLink": true,
                "AddAllowedToAct": true,
                "AllowedToAct": true,
                "WriteAccountRestrictions": true,
                "SQLAdmin": true,
                "ReadGMSAPassword": true,
                "HasSIDHistory": true,
                "CanPSRemote": true,
                "SyncLAPSPassword": true,
                "DumpSMSAPassword": true,
                "AZMGGrantRole": true,
                "AZMGAddSecret": true,
                "AZMGAddOwner": true,
                "AZMGAddMember": true,
                "AZMGGrantAppRoles": true,
                "AZNodeResourceGroup": true,
                "AZWebsiteContributor": true,
                "AZLogicAppContributo": true,
                "AZAutomationContributor": true,
                "AZAKSContributor": true
        }
}

  '';
}
