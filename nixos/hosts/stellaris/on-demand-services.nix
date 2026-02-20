{ lib, ... }:
{
  # Keep these services installed/configured, but don't start them automatically.
  # Start them when needed via `sudo systemctl start <name>`.
  systemd.services = {
    #bloodhound-ce.wantedBy = lib.mkForce [ ];
    #neo4j.wantedBy = lib.mkForce [ ];
    #postgresql.wantedBy = lib.mkForce [ ];

    #docker.wantedBy = lib.mkForce [ ];
    #containerd.wantedBy = lib.mkForce [ ];

    ollama.wantedBy = lib.mkForce [ ];
  };
}
