{ config, lib, pkgs, ... }:

{
  # Ensure the directory exists
  home.activation.ensureBloodhoundDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Creating directory: ${config.xdg.configHome}/bloodhound";
    mkdir -p ${config.xdg.configHome}/bloodhound;
  '';

  # Create the configuration file
  home.file = {
    ".config/bloodhound/config1.json" = {
      text = ''
        {
          "performance": {
            "edge": 5,
            "lowGraphics": false,
            "nodeLabels": 0,
            "edgeLabels": 0,
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
            "AZLogicAppContributor": true,
            "AZAutomationContributor": true,
            "AZAKSContributor": true,
            "AZAddMembers": true,
            "AZAddOwner": true,
            "AZAddSecret": true,
            "AZAvereContributor": true,
            "AZContains": true,
            "AZContributor": true,
            "AZExecuteCommand": true,
            "AZGetCertificates": true,
            "AZGetKeys": true,
            "AZGetSecrets": true,
            "AZGlobalAdmin": true,
            "AZHasRole": true,
            "AZManagedIdentity": true,
            "AZMemberOf": true,
            "AZOwns": true,
            "AZPrivilegedAuthAdmin": true,
            "AZPrivilegedRoleAdmin": true,
            "AZResetPassword": true,
            "AZUserAccessAdministrator": true,
            "AZAppAdmin": true,
            "AZCloudAppAdmin": true,
            "AZRunsAs": true,
            "AZKeyVaultContributor": true,
            "AZVMAdminLogin": true,
            "AZVMContributor": true,
            "AddSelf": true,
            "WriteSPN": true,
            "AddKeyCredentialLink": true,
            "DCSync": true
          },
          "databaseInfo": {
            "url": "bolt://localhost:7687",
            "user": "neo4j",
            "password": "Password1337"
          }
        }
      '';
      force = true;
    };
  };

  # Activation script to copy the configuration file
  home.activation.bloodhound = lib.hm.dag.entryAfter [ "ensureBloodhoundDir" "writeBoundary" "createBloodhoundConfig" ] ''
    echo "Checking if ${config.xdg.configHome}/bloodhound/config1.json exists";
    if [ -f "${config.xdg.configHome}/bloodhound/config1.json" ]; then
      echo "Copying ${config.xdg.configHome}/bloodhound/config1.json to ${config.xdg.configHome}/bloodhound/config.json";
      cp -L -f "${config.xdg.configHome}/bloodhound/config1.json" "${config.xdg.configHome}/bloodhound/config.json";
    else
      echo "Error: ${config.xdg.configHome}/bloodhound/config1.json does not exist";
      exit 1;
    fi
  '';

}
