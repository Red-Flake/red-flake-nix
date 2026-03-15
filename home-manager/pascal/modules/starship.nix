# Starship prompt configuration
# https://starship.rs/config/
_:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = false; # Using custom transient prompt implementation in zsh.nix

    settings = {
      # Don't add blank line before prompt
      add_newline = false;

      # Prompt format - two lines with right-aligned content on each
      # Line 1: path/git info ... IPs (right, using fill)
      # Line 2: character (left) ... time (right, using right_format)
      format = "$username$hostname$directory$git_branch$git_status$nix_shell$python$rust$nodejs$golang$cmd_duration$fill\${custom.vpn_ip}\${custom.lan_ip}$line_break$character";

      # Right format appears on line 2 next to character
      right_format = "$time";

      # Character module (prompt symbol)
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };

      # Fill - used to push content to the right
      fill = {
        symbol = " ";
      };

      # Directory with intelligent truncation
      directory = {
        format = "[$path]($style) ";
        truncation_length = 3;
        truncation_symbol = "…/";
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

      # Time with seconds
      time = {
        disabled = false;
        format = "[ $time]($style)";
        time_format = "%H:%M:%S";
        style = "bold white";
      };

      # Custom modules for IP display
      custom = {
        # LAN IP - always shown (trailing space to align with RPROMPT margin)
        lan_ip = {
          command = "ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i==\"src\") print $(i+1)}'";
          when = "true";
          format = "[󰈀 $output]($style) ";
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
