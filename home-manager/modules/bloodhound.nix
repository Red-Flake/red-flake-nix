{ config, lib, pkgs, ... }:

let
  configDir = "${config.xdg.configHome}/bloodhound";
in
{
  # Ensure the directory exists
  home.activation.ensureBloodhoundDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${configDir}
  '';

  # Create the configuration file
  home.file.".config/bloodhound/config1.json".text = ''
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
        "AZLogicAppContributo": true,
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
        "AZLogicAppContributor": true,
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

  # Activation script to copy the configuration file
  home.activation.bloodhound = lib.hm.dag.entryAfter [ "writeBoundary" "ensureBloodhoundDir" ] ''
    if [ -f "${configDir}/config1.json" ]; then
      cp -L -f "${configDir}/config1.json" "${configDir}/config.json";
    else
      echo "Error: ${configDir}/config1.json does not exist";
      exit 1;
    fi
  '';
}
