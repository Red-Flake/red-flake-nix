# Starship prompt configuration
# https://starship.rs/config/
_:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = false; # Using custom transient prompt implementation in zsh.nix

    settings = {
      # Prompt format
      format = "$username$hostname$directory$git_branch$git_status$nix_shell$python$rust$nodejs$golang$cmd_duration$line_break$character";

      # Right side prompt - show IPs
      right_format = "\${custom.vpn_ip}\${custom.lan_ip}";

      # Character module (prompt symbol)
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };

      # Directory
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };

      # Git branch
      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
        style = "bold purple";
      };

      # Git status
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "bold red";
        conflicted = "⚔ ";
        ahead = "⇡\${count} ";
        behind = "⇣\${count} ";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count} ";
        untracked = "?\${count} ";
        stashed = "📦 ";
        modified = "!\${count} ";
        staged = "+\${count} ";
        renamed = "»\${count} ";
        deleted = "✘\${count} ";
      };

      # Nix shell indicator
      nix_shell = {
        format = "[$symbol$state( \\($name\\))]($style) ";
        symbol = " ";
        style = "bold blue";
      };

      # Python
      python = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "bold yellow";
      };

      # Rust
      rust = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "bold red";
      };

      # Node.js
      nodejs = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "bold green";
      };

      # Golang
      golang = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "bold cyan";
      };

      # Command duration
      cmd_duration = {
        min_time = 2000; # 2 seconds
        format = "took [$duration]($style) ";
        style = "bold yellow";
      };

      # Username (show when root or SSH)
      username = {
        format = "[$user]($style)@";
        style_user = "bold green";
        style_root = "bold red";
        show_always = false;
      };

      # Hostname (show when SSH)
      hostname = {
        format = "[$hostname]($style) ";
        style = "bold green";
        ssh_only = true;
      };

      # Custom modules for IP display
      custom = {
        # LAN IP - always shown
        lan_ip = {
          command = "ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i==\"src\") print $(i+1)}'";
          when = "true";
          format = "[󰈀 $output]($style)";
          style = "bold green";
        };

        # VPN IP - only shown when VPN interface is active
        # Checks for common VPN interfaces: tun0, tun1, wg0, wg1, etc.
        vpn_ip = {
          command = ''
            for iface in tun0 tun1 tun2 wg0 wg1 proton0 nordlynx; do
              ip -4 addr show "$iface" 2>/dev/null | awk '/inet / {gsub(/\/.*/, "", $2); print $2; exit}'
            done | head -1
          '';
          when = "ip link show tun0 2>/dev/null || ip link show tun1 2>/dev/null || ip link show wg0 2>/dev/null || ip link show wg1 2>/dev/null || ip link show proton0 2>/dev/null || ip link show nordlynx 2>/dev/null";
          format = "[󰖂 $output]($style) ";
          style = "bold yellow";
        };
      };
    };
  };
}
