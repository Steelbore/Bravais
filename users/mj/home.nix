# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Bravais — Home Manager Configuration
{
  config,
  pkgs,
  lib,
  steelborePalette,
  gitway,
  ...
}:

let
  # Foot requires hex colors without the '#' prefix
  h = c: builtins.substring 1 (builtins.stringLength c - 1) c;

  # User-authored AI skills — single source of truth at /steelbore/skills/
  # (separate GitHub repo). Symlinked individually (not whole-dir) so Codex's
  # bundled .system/ namespace under .codex/skills/ stays untouched.
  aiSkillNames = [
    "rust-guidelines"
    "steelbore-agentic-cli"
    "steelbore-brand-guidelines"
    "steelbore-cli-preference"
    "steelbore-cli-shell"
    "steelbore-cli-standard"
    "steelbore-document-format"
    "steelbore-missing-pkg"
    "steelbore-standard"
    "steelbore-theme-factory"
  ];
  aiSkillToolDirs = [
    ".agent/skills"
    ".agents/skills"
    ".ai/skills"
    ".claude/skills"
    ".codex/skills"
    ".gemini/skills"
    ".copilot/skills"
    ".opencode/skills"
    ".aichat/skills"
  ];
  aiSkillLinks = builtins.listToAttrs (lib.flatten (
    map (toolDir: map (skill: {
      name = "${toolDir}/${skill}";
      value.source = config.lib.file.mkOutOfStoreSymlink
        "/steelbore/skills/${skill}";
    }) aiSkillNames) aiSkillToolDirs
  ));

  # Wallpaper daemon: upstream renamed swww → awww. On unstable both
  # exist (swww is a deprecation alias that warns); on stable 25.11
  # only swww. The `or`-fallback picks the right package per channel;
  # binary names follow the package name (awww/awww-daemon vs
  # swww/swww-daemon), so wallpaperBin tracks. Mirrors the system-wide
  # logic in modules/desktops/niri.nix.
  wallpaperPkg = pkgs.awww or pkgs.swww;
  wallpaperBin = if pkgs ? awww then "awww" else "swww";
in

{
  home.username = "mj";
  home.homeDirectory = "/home/mj";
  home.stateVersion = "25.11";

  home.file = aiSkillLinks // {
    # Steelbore project symlink
    "steelbore".source = config.lib.file.mkOutOfStoreSymlink "/steelbore";

    # Brush (Rust Bash-compatible) — share init with Bash via ~/.bashrc
    ".brushrc".text = ''
      # Steelbore Brush shell init — sources Home Manager's bashrc so Bash and Brush
      # share aliases, env, and gitway-agent key auto-loading.
      [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
    '';
  };

  # Keyboard layout
  home.keyboard = {
    layout = "us,ara";
    options = [ "grp:ctrl_space_toggle" ];
  };

  # Session variables
  home.sessionVariables = {
    EDITOR = "${pkgs.msedit}/bin/edit";
    VISUAL = "${pkgs.msedit}/bin/edit";
    STEELBORE_THEME = "true";
    # Move bw's app-data out from under the literal-space "Bitwarden CLI"
    # default into a scriptable XDG-compliant path. bw populates data.json
    # itself; we only set the directory.
    BITWARDENCLI_APPDATA_DIR = "${config.xdg.configHome}/bitwarden-cli";
  };

  # Refresh the tealdeer (tldr) cache on every home-manager activation.
  # `tldr --update` pulls the latest pages bundle. Failure is non-fatal so
  # an offline rebuild still succeeds.
  home.activation.tldrUpdate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.tealdeer}/bin/tldr --update >/dev/null 2>&1 || true
  '';

  # User packages
  home.packages = with pkgs; [
    sequoia-chameleon-gnupg
  ];

  # Programs
  programs = {
    # Git-LFS
    git.lfs.enable = true;

    # Git configuration
    git = {
      enable = true;
      settings = {
        user.name = "UnbreakableMJ";
        user.email = "34196588+UnbreakableMJ@users.noreply.github.com";
        user.signingkey = "~/.ssh/id_ed25519.pub";
        gpg.program = "${pkgs.sequoia-chameleon-gnupg}/bin/gpg-sq";
        gpg.format = "ssh";
        gpg.ssh.program = "${gitway.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/gitway-keygen";
        commit.gpgsign = true;
        init.defaultBranch = "main";
      };
    };

    # Bash/Brush — kept enabled because NixOS internals (PAM, userdel, etc.)
    # require it. The bashrcExtra below ONLY overrides SSH_AUTH_SOCK back to
    # gitway-agent's socket (PAM's pam_gnome_keyring otherwise pins it to
    # /run/user/$UID/keyring/ssh, which often points at a non-existent
    # socket). No SSH-key auto-load — that runs from each WM's session
    # spawn, see modules/desktops/{niri,leftwm}.nix.
    bash = {
      enable = true;
      bashrcExtra = ''
        export SSH_AUTH_SOCK="/run/user/$(id -u)/gitway-agent.sock"
      '';
    };

    # Starship prompt (Tokyo Night preset)
    starship = {
      enable = true;
      settings = {
        "$schema" = "https://starship.rs/config-schema.json";
        format = "[░▒▓](#a3aed2)[  ](bg:#a3aed2 fg:#090c0c)[](bg:#769ff0 fg:#a3aed2)$directory[](fg:#769ff0 bg:#394260)$git_branch$git_status[](fg:#394260 bg:#212736)$nodejs$rust$golang$php[](fg:#212736 bg:#1d2230)$time[ ](fg:#1d2230)\n$character";

        directory = {
          style = "fg:#e3e5e5 bg:#769ff0";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";

          substitutions = {
            Documents = "󰈙 ";
            Downloads = " ";
            Music = " ";
            Pictures = " ";
          };
        };

        git_branch = {
          symbol = "";
          style = "bg:#394260";
          format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
        };

        git_status = {
          style = "bg:#394260";
          format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
        };

        nodejs = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        rust = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        golang = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        php = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        time = {
          disabled = false;
          time_format = "%R";
          style = "bg:#1d2230";
          format = "[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)";
        };
      };
    };

    # Nushell configuration
    nushell = {
      enable = true;
      configFile.text = ''
        # Override SSH_AUTH_SOCK at every interactive shell start. PAM's
        # pam_gnome_keyring sets it to /run/user/$UID/keyring/ssh under
        # greetd, which (a) often points at a non-existent socket and
        # (b) shadows our gitway-agent socket. environment.sessionVariables
        # only takes effect for login shells; non-login shells (terminals
        # spawned inside a DE) inherit the PAM-set value.
        $env.SSH_AUTH_SOCK = $"/run/user/(id -u)/gitway-agent.sock"

        # Steelbore palette — kept in sync with flake.nix steelborePalette.
        # Nushell needs literals; env-var interpolation isn't available inside
        # color_config records.
        let steelbore = {
          voidNavy:    "#000027"
          moltenAmber: "#D98E32"
          steelBlue:   "#4B7EB0"
          radiumGreen: "#50FA7B"
          redOxide:    "#FF5C5C"
          liquidCool:  "#8BE9FD"
        }

        $env.config = {
          show_banner: false,
          ls: { use_ls_colors: true, clickable_links: true },
          cursor_shape: { emacs: block, vi_insert: block, vi_normal: block },
          color_config: {
            separator:        $steelbore.steelBlue
            leading_trailing_space_bg: { attr: "n" }
            header:           { fg: $steelbore.moltenAmber attr: "b" }
            empty:            $steelbore.liquidCool
            bool:             {|v| if $v { $steelbore.radiumGreen } else { $steelbore.redOxide } }
            int:              $steelbore.moltenAmber
            filesize:         {|v| if $v == 0b { $steelbore.steelBlue } else if $v < 1mb { $steelbore.liquidCool } else { $steelbore.moltenAmber } }
            duration:         $steelbore.moltenAmber
            date:             {|v| (date now) - $v | if $in < 1hr { { fg: $steelbore.radiumGreen attr: "b" } } else if $in < 6hr { $steelbore.radiumGreen } else if $in < 1day { $steelbore.moltenAmber } else if $in < 3day { $steelbore.liquidCool } else if $in < 1wk { { fg: $steelbore.liquidCool attr: "b" } } else if $in < 6wk { $steelbore.steelBlue } else if $in < 52wk { { fg: $steelbore.steelBlue attr: "b" } } else { "dark_gray" } }
            range:            $steelbore.moltenAmber
            float:            $steelbore.moltenAmber
            string:           $steelbore.moltenAmber
            nothing:          $steelbore.liquidCool
            binary:           $steelbore.liquidCool
            cell-path:        $steelbore.steelBlue
            row_index:        { fg: $steelbore.steelBlue attr: "b" }
            record:           $steelbore.moltenAmber
            list:             $steelbore.moltenAmber
            block:            $steelbore.moltenAmber
            hints:            "dark_gray"
            search_result:    { fg: $steelbore.voidNavy bg: $steelbore.moltenAmber }

            shape_and:                { fg: $steelbore.radiumGreen attr: "b" }
            shape_binary:             { fg: $steelbore.liquidCool attr: "b" }
            shape_block:              { fg: $steelbore.liquidCool attr: "b" }
            shape_bool:               $steelbore.radiumGreen
            shape_closure:            { fg: $steelbore.radiumGreen attr: "b" }
            shape_custom:             $steelbore.radiumGreen
            shape_datetime:           { fg: $steelbore.liquidCool attr: "b" }
            shape_directory:          $steelbore.liquidCool
            shape_external:           $steelbore.moltenAmber
            shape_externalarg:        { fg: $steelbore.radiumGreen attr: "b" }
            shape_external_resolved:  { fg: $steelbore.liquidCool attr: "b" }
            shape_filepath:           $steelbore.steelBlue
            shape_flag:               { fg: $steelbore.steelBlue attr: "b" }
            shape_float:              { fg: $steelbore.moltenAmber attr: "b" }
            shape_garbage:            { fg: $steelbore.redOxide bg: $steelbore.voidNavy attr: "b" }
            shape_glob_interpolation: { fg: $steelbore.liquidCool attr: "b" }
            shape_globpattern:        { fg: $steelbore.liquidCool attr: "b" }
            shape_int:                { fg: $steelbore.moltenAmber attr: "b" }
            shape_internalcall:       { fg: $steelbore.moltenAmber attr: "b" }
            shape_keyword:            { fg: $steelbore.radiumGreen attr: "b" }
            shape_list:               { fg: $steelbore.liquidCool attr: "b" }
            shape_literal:            $steelbore.steelBlue
            shape_match_pattern:      $steelbore.radiumGreen
            shape_matching_brackets:  { attr: "u" }
            shape_nothing:            $steelbore.liquidCool
            shape_operator:           $steelbore.moltenAmber
            shape_or:                 { fg: $steelbore.radiumGreen attr: "b" }
            shape_pipe:               { fg: $steelbore.radiumGreen attr: "b" }
            shape_range:              { fg: $steelbore.moltenAmber attr: "b" }
            shape_record:             { fg: $steelbore.liquidCool attr: "b" }
            shape_redirection:        { fg: $steelbore.radiumGreen attr: "b" }
            shape_signature:          { fg: $steelbore.radiumGreen attr: "b" }
            shape_string:             $steelbore.steelBlue
            shape_string_interpolation: { fg: $steelbore.liquidCool attr: "b" }
            shape_table:              { fg: $steelbore.steelBlue attr: "b" }
            shape_variable:           $steelbore.steelBlue
            shape_vardecl:            $steelbore.steelBlue
            shape_raw_string:         $steelbore.steelBlue
            shape_garbage_unknown:    { fg: $steelbore.redOxide attr: "b" }
          }
        }

        # Steelbore Telemetry Aliases
        alias ll = ls -l
        alias lla = ls -la
        alias telemetry = macchina
        alias sensors = ^watch -n 1 sensors
        alias sys-logs = journalctl -p 3 -xb
        alias network-diag = gping google.com
        alias top-processes = bottom
        alias disk-telemetry = yazi
        alias edit = ${pkgs.msedit}/bin/edit

        # Project Steelbore Identity
        def steelbore [] {
          print "============================================================"
          print "  STEELBORE :: Industrial Sci-Fi Desktop Environment"
          print "============================================================"
          print "  STATUS    :: ACTIVE"
          print "  LOAD      :: NOMINAL"
          print "  INTEGRITY :: VERIFIED"
          print "============================================================"
        }


        # Pull latest AI skills from /steelbore/skills (decoupled from rebuild)
        def skills-sync [] {
          cd /steelbore/skills
          git pull --ff-only
          print $"(date now | format date '%Y-%m-%d %H:%M:%S') skills synced"
        }
      '';
    };

    # Alacritty (Steelbore theme)
    alacritty = {
      enable = true;
      settings = {
        terminal.shell = {
          program = "${pkgs.nushell}/bin/nu";
        };
        window = {
          padding = {
            x = 10;
            y = 10;
          };
          dynamic_title = true;
          opacity = 0.95;
        };
        font = {
          normal = {
            family = "JetBrains Mono";
            style = "Regular";
          };
          size = 12.0;
        };
        colors = {
          primary = {
            background = steelborePalette.voidNavy;
            foreground = steelborePalette.moltenAmber;
          };
          cursor = {
            text = steelborePalette.voidNavy;
            cursor = steelborePalette.moltenAmber;
          };
          selection = {
            text = steelborePalette.voidNavy;
            background = steelborePalette.steelBlue;
          };
          normal = {
            black = steelborePalette.voidNavy;
            red = steelborePalette.redOxide;
            green = steelborePalette.radiumGreen;
            yellow = steelborePalette.moltenAmber;
            blue = steelborePalette.steelBlue;
            magenta = steelborePalette.steelBlue;
            cyan = steelborePalette.liquidCool;
            white = steelborePalette.moltenAmber;
          };
          bright = {
            black = steelborePalette.steelBlue;
            red = steelborePalette.redOxide;
            green = steelborePalette.radiumGreen;
            yellow = steelborePalette.moltenAmber;
            blue = steelborePalette.liquidCool;
            magenta = steelborePalette.liquidCool;
            cyan = steelborePalette.liquidCool;
            white = steelborePalette.moltenAmber;
          };
        };
      };
    };
  };

  # GPG agent — uses pinentry-qt for KDE wallet and commit signing prompts
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-qt;
  };

  # gitway-agent itself is enabled system-wide via services.gitway-agent.enable
  # in modules/core/security.nix (NixOS module from the gitway flake). That
  # module also writes /etc/environment.d/10-gitway-agent.conf and registers
  # the hardened systemd.user.services.gitway-agent unit, so neither needs to
  # be duplicated here.

  # SSH key loading happens lazily via the bash/brush rc snippet above on the
  # first interactive shell. A boot-time systemd user unit was tried but
  # failed silently against passphrase-protected keys without a TTY/SSH_ASKPASS.

  # XDG config files
  xdg.configFile = {
    # Suppress gnome-keyring's SSH component so it doesn't override
    # SSH_AUTH_SOCK (which gitway-agent points at /run/user/$UID/gitway-agent.sock
    # via /etc/environment.d/10-gitway-agent.conf). PAM still launches
    # gnome-keyring-daemon for secrets/keyring; this file shadows the system
    # autostart and the daemon honors Hidden=true to skip its SSH agent.
    "autostart/gnome-keyring-ssh.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=SSH Key Agent
      Hidden=true
    '';

    "containers/containers.conf".text = ''
      [engine]
      runtime = "runc"
    '';

    # tealdeer (tldr) — auto-update once a week on first invocation.
    # The home-manager activation script also forces a refresh on every
    # nixos-rebuild (see home.activation.tldrUpdate).
    "tealdeer/config.toml".text = ''
      [updates]
      auto_update = true
      auto_update_interval_hours = 168

      [display]
      use_pager = false
      compact = false
    '';

    # Suppress IBus autostarts that surface as Wayland-session popups.
    # i18n.inputMethod = ibus (modules/core/locale.nix) is required to
    # silence COSMIC's "no input method configured" notification — that
    # check keys off QT_IM_MODULE / GTK_IM_MODULE / XMODIFIERS, which the
    # option sets globally. The option also installs two autostart files
    # that misbehave under non-GNOME Wayland sessions:
    #   • Panel (Wayland Gtk3) — a tray widget we don't need
    #   • ibus-daemon          — under Niri, the daemon prints its long
    #                            "IBus should be called from the desktop
    #                            session in Wayland..." help text, which
    #                            dunst surfaces as a notification.
    # We shadow both with Hidden=true. ibus-daemon dbus-activates on
    # demand if any client really needs it.
    "autostart/org.freedesktop.IBus.Panel.Wayland.Gtk3.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=IBus Panel (Wayland)
      Hidden=true
    '';

    "autostart/ibus-daemon.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=IBus Daemon
      Hidden=true
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # EWW — Shared status bar for LeftWM (X11) and Niri (Wayland).
    # Eww auto-detects X11 vs Wayland; one config drives both. WMs spawn it
    # via `eww open bar` from their startup scripts.
    # ═══════════════════════════════════════════════════════════════════════════
    "eww/eww.yuck".text = ''
      ;; Steelbore Eww — shared bar widget

      (defpoll time    :interval "1s"  "date '+%Y-%m-%d %H:%M:%S'")
      (defpoll cpu     :interval "3s"  "top -bn1 -d 0.1 | awk '/^%Cpu/ {printf \"%d\", $2 + $4}'")
      (defpoll memory  :interval "5s"  "free | awk '/^Mem/ {printf \"%d\", $3 / $2 * 100}'")
      (defpoll battery :interval "30s" "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo --")

      (defwidget bar []
        (centerbox :orientation "h"
          (label :class "title" :text "STEELBORE :: BRAVAIS")
          (label :class "clock" :text time)
          (box :orientation "h" :spacing 16 :halign "end" :class "metrics"
            (label :class "metric" :text "CPU ''${cpu}%")
            (label :class "metric" :text "RAM ''${memory}%")
            (label :class "metric" :text "BAT ''${battery}%"))))

      (defwindow bar
        :monitor 0
        :geometry (geometry :x      "0"
                            :y      "0"
                            :width  "100%"
                            :height "32px"
                            :anchor "top center")
        :stacking  "fg"
        :exclusive true
        (bar))
    '';

    "eww/eww.scss".text = ''
      $voidNavy:    ${steelborePalette.voidNavy};
      $moltenAmber: ${steelborePalette.moltenAmber};
      $steelBlue:   ${steelborePalette.steelBlue};
      $radiumGreen: ${steelborePalette.radiumGreen};
      $liquidCool:  ${steelborePalette.liquidCool};
      $redOxide:    ${steelborePalette.redOxide};

      * {
          font-family: "Share Tech Mono", "JetBrains Mono", monospace;
          font-size: 13px;
          font-weight: bold;
      }

      window {
          background-color: $voidNavy;
          color: $moltenAmber;
          border-bottom: 2px solid $steelBlue;
          padding: 0 12px;
      }

      .title  { color: $moltenAmber; }
      .clock  { color: $liquidCool; }
      .metrics { padding-right: 12px; }
      .metric { color: $radiumGreen; }
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # ZELLIJ — Full Steelbore config
    # User has no custom keybinds; ship a complete config that activates the
    # Steelbore theme. zellij will write any auto-generated keybinds to its
    # internal cache; our config.kdl wins because it's at $XDG_CONFIG_HOME.
    # ═══════════════════════════════════════════════════════════════════════════
    "zellij/config.kdl".text = ''
      theme "steelbore"
      default_shell "${pkgs.nushell}/bin/nu"
      simplified_ui false
      pane_frames true
      mouse_mode true
      copy_on_select true

      themes {
          steelbore {
              fg "${steelborePalette.moltenAmber}"
              bg "${steelborePalette.voidNavy}"
              black "${steelborePalette.voidNavy}"
              red "${steelborePalette.redOxide}"
              green "${steelborePalette.radiumGreen}"
              yellow "${steelborePalette.moltenAmber}"
              blue "${steelborePalette.steelBlue}"
              magenta "${steelborePalette.steelBlue}"
              cyan "${steelborePalette.liquidCool}"
              white "${steelborePalette.moltenAmber}"
              orange "${steelborePalette.moltenAmber}"
          }
      }
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # ION — Shell init (Starship prompt)
    # ═══════════════════════════════════════════════════════════════════════════
    "ion/initrc".text = ''
      # Steelbore Ion Shell Init

      # Override SSH_AUTH_SOCK back to gitway-agent's socket. PAM's
      # pam_gnome_keyring otherwise sets it to /run/user/$UID/keyring/ssh.
      let SSH_AUTH_SOCK = "/run/user/$(id -u)/gitway-agent.sock"
      export SSH_AUTH_SOCK

      # Starship prompt
      eval $(${pkgs.starship}/bin/starship init ion)

      # Aliases
      alias ll = ls -l
      alias lla = ls -la
      alias telemetry = macchina
      alias sensors = watch -n 1 sensors
      alias sys-logs = journalctl -p 3 -xb
      alias top-processes = bottom
      alias disk-telemetry = yazi
      alias edit = ${pkgs.msedit}/bin/edit
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # NIRI — User configuration
    # ═══════════════════════════════════════════════════════════════════════════
    "niri/config.kdl".text = ''
      // Steelbore Niri User Configuration

      layout {
          focus-ring {
              // off  — uncomment to disable; presence of the block enables it
              width 2
              active-color "${steelborePalette.moltenAmber}"
              inactive-color "${steelborePalette.steelBlue}"
          }
          border { off; }
          gaps 8
      }

      // Startup — see system-wide config in modules/desktops/niri.nix for
      // the full rationale. The wallpaper daemon needs to bind its IPC
      // socket before any client command.
      spawn-at-startup "${wallpaperPkg}/bin/${wallpaperBin}-daemon"
      spawn-at-startup "sh" "-c" "sleep 1 && ${wallpaperPkg}/bin/${wallpaperBin} clear ${lib.removePrefix "#" steelborePalette.voidNavy}"
      spawn-at-startup "eww" "open" "bar"
      spawn-at-startup "dunst"
      // Load SSH key into gitway-agent once per session. With no TTY but
      // DISPLAY/WAYLAND_DISPLAY set, gitway-add uses $SSH_ASKPASS
      // (ksshaskpass) automatically. Cached for 24 h per the agent TTL.
      spawn-at-startup "gitway-add" "/home/mj/.ssh/id_ed25519"

      // Input — natural-scroll intentionally absent (presence = enabled).
      input {
          keyboard {
              xkb {
                  layout "us,ar"
                  options "grp:ctrl_space_toggle"
              }
          }
          touchpad {
              tap
              accel-speed 0.3
          }
      }

      binds {
          // Session
          Mod+Shift+E { quit; }
          Mod+Shift+L { spawn "gtklock"; }

          // Applications
          Mod+Return { spawn "rio"; }
          Mod+D { spawn "anyrun"; }

          // Window management
          Mod+Q { close-window; }
          Mod+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }

          // Focus (Vim-style)
          Mod+H { focus-column-left; }
          Mod+L { focus-column-right; }
          Mod+K { focus-window-up; }
          Mod+J { focus-window-down; }

          // Focus (Arrow keys)
          Mod+Left { focus-column-left; }
          Mod+Right { focus-column-right; }
          Mod+Up { focus-window-up; }
          Mod+Down { focus-window-down; }

          // Move windows (Vim-style; Mod+Shift+L is reserved for gtklock)
          Mod+Shift+H { move-column-left; }
          Mod+Shift+K { move-window-up; }
          Mod+Shift+J { move-window-down; }

          // Move windows (Arrow keys)
          Mod+Shift+Left { move-column-left; }
          Mod+Shift+Right { move-column-right; }
          Mod+Shift+Up { move-window-up; }
          Mod+Shift+Down { move-window-down; }

          // Workspaces
          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }

          // Move to workspace
          Mod+Shift+1 { move-column-to-workspace 1; }
          Mod+Shift+2 { move-column-to-workspace 2; }
          Mod+Shift+3 { move-column-to-workspace 3; }
          Mod+Shift+4 { move-column-to-workspace 4; }
          Mod+Shift+5 { move-column-to-workspace 5; }
          Mod+Shift+6 { move-column-to-workspace 6; }
          Mod+Shift+7 { move-column-to-workspace 7; }
          Mod+Shift+8 { move-column-to-workspace 8; }
          Mod+Shift+9 { move-column-to-workspace 9; }

          // Resize
          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }

          // Scrolling
          Mod+WheelScrollDown { focus-workspace-down; }
          Mod+WheelScrollUp { focus-workspace-up; }

          // Screenshot
          Print { screenshot; }
          Mod+Print { screenshot-window; }
      }
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # IRONBAR — Wayland status bar
    # ═══════════════════════════════════════════════════════════════════════════
    "ironbar/config.yaml".text = ''
      anchor_to_edges: true
      position: top
      height: 32

      start:
        - type: workspaces
        - type: focused

      center:
        - type: clock
          format: "%H:%M:%S :: %Y-%m-%d"

      end:
        - type: sys_info
          interval: 1
          format:
            - "CPU: {cpu_percent}%"
            - "RAM: {memory_percent}%"
        - type: tray
    '';

    "ironbar/style.css".text = ''
      * {
          font-family: "Share Tech Mono", "JetBrains Mono", monospace;
          font-size: 14px;
          transition: none;
      }

      window {
          background-color: ${steelborePalette.voidNavy};
          color: ${steelborePalette.moltenAmber};
          border-bottom: 2px solid ${steelborePalette.steelBlue};
      }

      .widget {
          padding: 0 10px;
          border-left: 1px solid ${steelborePalette.steelBlue};
      }

      .workspaces button {
          color: ${steelborePalette.steelBlue};
          border-bottom: 2px solid transparent;
      }

      .workspaces button.active {
          color: ${steelborePalette.moltenAmber};
          border-bottom: 2px solid ${steelborePalette.moltenAmber};
      }

      .clock {
          color: ${steelborePalette.moltenAmber};
          font-weight: bold;
      }

      .sys_info {
          color: ${steelborePalette.radiumGreen};
      }
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # WEZTERM — User configuration
    # ═══════════════════════════════════════════════════════════════════════════
    "wezterm/wezterm.lua".text = ''
      -- Steelbore WezTerm User Configuration
      local wezterm = require 'wezterm'
      local config = {}

      config.font = wezterm.font 'JetBrains Mono'
      config.font_size = 12.0
      config.window_background_opacity = 0.95
      config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
      config.enable_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = true
      config.default_prog = { "${pkgs.nushell}/bin/nu" }

      config.colors = {
        foreground = "${steelborePalette.moltenAmber}",
        background = "${steelborePalette.voidNavy}",
        cursor_bg = "${steelborePalette.moltenAmber}",
        cursor_fg = "${steelborePalette.voidNavy}",
        cursor_border = "${steelborePalette.moltenAmber}",
        selection_bg = "${steelborePalette.steelBlue}",
        selection_fg = "${steelborePalette.voidNavy}",
        ansi = {
          "${steelborePalette.voidNavy}",
          "${steelborePalette.redOxide}",
          "${steelborePalette.radiumGreen}",
          "${steelborePalette.moltenAmber}",
          "${steelborePalette.steelBlue}",
          "${steelborePalette.steelBlue}",
          "${steelborePalette.liquidCool}",
          "${steelborePalette.moltenAmber}"
        },
        brights = {
          "${steelborePalette.steelBlue}",
          "${steelborePalette.redOxide}",
          "${steelborePalette.radiumGreen}",
          "${steelborePalette.moltenAmber}",
          "${steelborePalette.liquidCool}",
          "${steelborePalette.liquidCool}",
          "${steelborePalette.liquidCool}",
          "${steelborePalette.moltenAmber}"
        },
        tab_bar = {
          background = "${steelborePalette.voidNavy}",
          active_tab = {
            bg_color = "${steelborePalette.steelBlue}",
            fg_color = "${steelborePalette.moltenAmber}",
          },
          inactive_tab = {
            bg_color = "${steelborePalette.voidNavy}",
            fg_color = "${steelborePalette.steelBlue}",
          },
        },
      }

      return config
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # RIO — User configuration
    # ═══════════════════════════════════════════════════════════════════════════
    "rio/config.toml".text = ''
      # Steelbore Rio User Configuration

      [window]
      opacity = 0.95

      [fonts]
      size = 14

      [fonts.regular]
      family = "JetBrains Mono"
      weight = 400

      [fonts.bold]
      family = "JetBrains Mono"
      weight = 700

      [fonts.italic]
      family = "JetBrains Mono"
      weight = 400

      [fonts.bold-italic]
      family = "JetBrains Mono"
      weight = 700

      [colors]
      background = '${steelborePalette.voidNavy}'
      foreground = '${steelborePalette.moltenAmber}'
      cursor = '${steelborePalette.moltenAmber}'
      selection-background = '${steelborePalette.steelBlue}'
      selection-foreground = '${steelborePalette.voidNavy}'

      [colors.regular]
      black = '${steelborePalette.voidNavy}'
      red = '${steelborePalette.redOxide}'
      green = '${steelborePalette.radiumGreen}'
      yellow = '${steelborePalette.moltenAmber}'
      blue = '${steelborePalette.steelBlue}'
      magenta = '${steelborePalette.steelBlue}'
      cyan = '${steelborePalette.liquidCool}'
      white = '${steelborePalette.moltenAmber}'

      [colors.bright]
      black = '${steelborePalette.steelBlue}'
      red = '${steelborePalette.redOxide}'
      green = '${steelborePalette.radiumGreen}'
      yellow = '${steelborePalette.moltenAmber}'
      blue = '${steelborePalette.liquidCool}'
      magenta = '${steelborePalette.liquidCool}'
      cyan = '${steelborePalette.liquidCool}'
      white = '${steelborePalette.moltenAmber}'

      [shell]
      program = "${pkgs.nushell}/bin/nu"
      args = []
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # GHOSTTY — User configuration
    # ═══════════════════════════════════════════════════════════════════════════
    "ghostty/config".text = ''
      # Steelbore Ghostty User Configuration

      font-family = JetBrains Mono
      font-size = 12

      background-opacity = 0.95
      window-padding-x = 10
      window-padding-y = 10

      background = ${steelborePalette.voidNavy}
      foreground = ${steelborePalette.moltenAmber}
      cursor-color = ${steelborePalette.moltenAmber}
      cursor-text = ${steelborePalette.voidNavy}
      selection-background = ${steelborePalette.steelBlue}
      selection-foreground = ${steelborePalette.voidNavy}

      palette = 0=${steelborePalette.voidNavy}
      palette = 1=${steelborePalette.redOxide}
      palette = 2=${steelborePalette.radiumGreen}
      palette = 3=${steelborePalette.moltenAmber}
      palette = 4=${steelborePalette.steelBlue}
      palette = 5=${steelborePalette.steelBlue}
      palette = 6=${steelborePalette.liquidCool}
      palette = 7=${steelborePalette.moltenAmber}
      palette = 8=${steelborePalette.steelBlue}
      palette = 9=${steelborePalette.redOxide}
      palette = 10=${steelborePalette.radiumGreen}
      palette = 11=${steelborePalette.moltenAmber}
      palette = 12=${steelborePalette.liquidCool}
      palette = 13=${steelborePalette.liquidCool}
      palette = 14=${steelborePalette.liquidCool}
      palette = 15=${steelborePalette.moltenAmber}

      # Shell — launches nushell (starship integrated via nushell config)
      command = ${pkgs.nushell}/bin/nu
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # FOOT — User configuration
    # ═══════════════════════════════════════════════════════════════════════════
    "foot/foot.ini".text = ''
      # Steelbore Foot User Configuration

      [main]
      font=JetBrains Mono:size=12
      shell=${pkgs.nushell}/bin/nu
      term=xterm-256color

      [colors]
      background=${h steelborePalette.voidNavy}
      foreground=${h steelborePalette.moltenAmber}
      regular0=${h steelborePalette.voidNavy}
      regular1=${h steelborePalette.redOxide}
      regular2=${h steelborePalette.radiumGreen}
      regular3=${h steelborePalette.moltenAmber}
      regular4=${h steelborePalette.steelBlue}
      regular5=${h steelborePalette.steelBlue}
      regular6=${h steelborePalette.liquidCool}
      regular7=${h steelborePalette.moltenAmber}
      bright0=${h steelborePalette.steelBlue}
      bright1=${h steelborePalette.redOxide}
      bright2=${h steelborePalette.radiumGreen}
      bright3=${h steelborePalette.moltenAmber}
      bright4=${h steelborePalette.liquidCool}
      bright5=${h steelborePalette.liquidCool}
      bright6=${h steelborePalette.liquidCool}
      bright7=${h steelborePalette.moltenAmber}
      cursor=${h steelborePalette.voidNavy} ${h steelborePalette.moltenAmber}
      selection-foreground=${h steelborePalette.voidNavy}
      selection-background=${h steelborePalette.steelBlue}

      [scrollback]
      lines=10000
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # XFCE4-TERMINAL — User configuration
    # ═══════════════════════════════════════════════════════════════════════════
    "xfce4/terminal/terminalrc".text = ''
      [Configuration]
      FontName=JetBrains Mono 12
      MiscDefaultGeometry=160x48
      RunCustomCommand=TRUE
      CustomCommand=${pkgs.nushell}/bin/nu
      BackgroundMode=TERMINAL_BACKGROUND_TRANSPARENT
      BackgroundDarkness=0.95
      ColorBackground=${steelborePalette.voidNavy}
      ColorForeground=${steelborePalette.moltenAmber}
      ColorCursor=${steelborePalette.moltenAmber}
      ColorBold=FALSE
      ColorPalette=${steelborePalette.voidNavy};${steelborePalette.redOxide};${steelborePalette.radiumGreen};${steelborePalette.moltenAmber};${steelborePalette.steelBlue};${steelborePalette.steelBlue};${steelborePalette.liquidCool};${steelborePalette.moltenAmber};${steelborePalette.steelBlue};${steelborePalette.redOxide};${steelborePalette.radiumGreen};${steelborePalette.moltenAmber};${steelborePalette.liquidCool};${steelborePalette.liquidCool};${steelborePalette.liquidCool};${steelborePalette.moltenAmber}
      MiscMenubarDefault=FALSE
      ScrollingBar=TERMINAL_SCROLLBAR_NONE
      ScrollingLines=10000
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # KWIN — Enable Krohnkite tiling script
    # ═══════════════════════════════════════════════════════════════════════════
    "kwinrc".text = ''
      [Plugins]
      krohnkiteEnabled=true
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # KWALLET — Pre-enable GPG backend
    # The wallet itself must be created manually via KWallet Manager:
    #   File → New Wallet → choose GPG encryption → select your GPG key.
    # ═══════════════════════════════════════════════════════════════════════════
    "kwalletrc".text = ''
      [Wallet]
      Default Wallet=kdewallet
      Enabled=true
      First Use=false

      [gpg]
      use=true
    '';

    "konsolerc".text = ''
      [Desktop Entry]
      DefaultProfile=Steelbore.profile

      [TabBar]
      CloseTabOnMiddleMouseButton=true
      NewTabButton=false
      TabBarPosition=Top
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # YAKUAKE — KDE drop-down terminal (uses Konsole as backend)
    # Inherits shell and colors from the Konsole Steelbore profile above
    # ═══════════════════════════════════════════════════════════════════════════
    "yakuakerc".text = ''
      [Desktop Entry]
      DefaultProfile=Steelbore.profile

      [Window]
      Height=50
      Width=100
      KeepOpen=false
      AnimationDuration=0
    '';
  };

  # Konsole colorscheme and profile live in $XDG_DATA_HOME/konsole/
  xdg.dataFile = {
    # ═══════════════════════════════════════════════════════════════════════════
    # KONSOLE — User profile and colorscheme
    # ═══════════════════════════════════════════════════════════════════════════
    "konsole/Steelbore.colorscheme".text = ''
      # Steelbore Konsole Color Scheme

      [Background]
      Color=0,0,39

      [BackgroundFaint]
      Color=0,0,39

      [BackgroundIntense]
      Bold=true
      Color=75,126,176

      [Color0]
      Color=0,0,39

      [Color0Faint]
      Color=0,0,39

      [Color0Intense]
      Bold=true
      Color=75,126,176

      [Color1]
      Color=255,92,92

      [Color1Faint]
      Color=255,92,92

      [Color1Intense]
      Bold=true
      Color=255,92,92

      [Color2]
      Color=80,250,123

      [Color2Faint]
      Color=80,250,123

      [Color2Intense]
      Bold=true
      Color=80,250,123

      [Color3]
      Color=217,142,50

      [Color3Faint]
      Color=217,142,50

      [Color3Intense]
      Bold=true
      Color=217,142,50

      [Color4]
      Color=75,126,176

      [Color4Faint]
      Color=75,126,176

      [Color4Intense]
      Bold=true
      Color=139,233,253

      [Color5]
      Color=75,126,176

      [Color5Faint]
      Color=75,126,176

      [Color5Intense]
      Bold=true
      Color=139,233,253

      [Color6]
      Color=139,233,253

      [Color6Faint]
      Color=139,233,253

      [Color6Intense]
      Bold=true
      Color=139,233,253

      [Color7]
      Color=217,142,50

      [Color7Faint]
      Color=217,142,50

      [Color7Intense]
      Bold=true
      Color=217,142,50

      [Foreground]
      Color=217,142,50

      [ForegroundFaint]
      Color=217,142,50

      [ForegroundIntense]
      Bold=true
      Color=217,142,50

      [General]
      Anchor=0.5,0.5
      Blur=false
      ColorRandomization=false
      Description=Steelbore
      FillStyle=Tile
      Opacity=0.95
      Spread=1.0
      Wallpaper=
    '';

    "konsole/Steelbore.profile".text = ''
      # Steelbore Konsole Profile

      [Appearance]
      ColorScheme=Steelbore
      Font=JetBrains Mono,12,-1,5,50,0,0,0,0,0

      [General]
      Command=${pkgs.nushell}/bin/nu
      Name=Steelbore
      Parent=FALLBACK/
      TerminalColumns=160
      TerminalRows=48

      [Scrolling]
      HistoryMode=2
      ScrollFullPage=false

      [Terminal Features]
      BlinkingCursorEnabled=true
    '';
  };

  # XTerm Xresources (loaded by xrdb on X session start)
  xresources.properties = {
    "XTerm*termName"               = "xterm-256color";
    "XTerm*faceName"               = "JetBrains Mono";
    "XTerm*faceSize"               = 12;
    "XTerm*loginShell"             = true;
    "XTerm*scrollBar"              = false;
    "XTerm*saveLines"              = 10000;
    "XTerm*bellIsUrgent"           = true;
    "XTerm*internalBorder"         = 10;
    "XTerm*background"             = steelborePalette.voidNavy;
    "XTerm*foreground"             = steelborePalette.moltenAmber;
    "XTerm*cursorColor"            = steelborePalette.moltenAmber;
    "XTerm*pointerColorBackground" = steelborePalette.voidNavy;
    "XTerm*pointerColorForeground" = steelborePalette.moltenAmber;
    "XTerm*highlightColor"         = steelborePalette.steelBlue;
    "XTerm*color0"                 = steelborePalette.voidNavy;
    "XTerm*color1"                 = steelborePalette.redOxide;
    "XTerm*color2"                 = steelborePalette.radiumGreen;
    "XTerm*color3"                 = steelborePalette.moltenAmber;
    "XTerm*color4"                 = steelborePalette.steelBlue;
    "XTerm*color5"                 = steelborePalette.steelBlue;
    "XTerm*color6"                 = steelborePalette.liquidCool;
    "XTerm*color7"                 = steelborePalette.moltenAmber;
    "XTerm*color8"                 = steelborePalette.steelBlue;
    "XTerm*color9"                 = steelborePalette.redOxide;
    "XTerm*color10"                = steelborePalette.radiumGreen;
    "XTerm*color11"                = steelborePalette.moltenAmber;
    "XTerm*color12"                = steelborePalette.liquidCool;
    "XTerm*color13"                = steelborePalette.liquidCool;
    "XTerm*color14"                = steelborePalette.liquidCool;
    "XTerm*color15"                = steelborePalette.moltenAmber;
  };

  # dconf settings for GNOME-based terminals (Ptyxis, GNOME Console)
  dconf.settings = {
    # ── Ptyxis ──────────────────────────────────────────────────────────────
    "org/gnome/Ptyxis" = {
      default-profile-uuid = "steelbore";
      font-name = "JetBrains Mono 12";
      use-system-font = false;
    };
    "org/gnome/Ptyxis/Profiles/steelbore" = {
      label = "Steelbore";
      use-custom-command = true;
      custom-command = "${pkgs.nushell}/bin/nu";
      palette = [
        steelborePalette.voidNavy      # black
        steelborePalette.redOxide      # red
        steelborePalette.radiumGreen   # green
        steelborePalette.moltenAmber   # yellow
        steelborePalette.steelBlue     # blue
        steelborePalette.steelBlue     # magenta
        steelborePalette.liquidCool    # cyan
        steelborePalette.moltenAmber   # white
        steelborePalette.steelBlue     # bright black
        steelborePalette.redOxide      # bright red
        steelborePalette.radiumGreen   # bright green
        steelborePalette.moltenAmber   # bright yellow
        steelborePalette.liquidCool    # bright blue
        steelborePalette.liquidCool    # bright magenta
        steelborePalette.liquidCool    # bright cyan
        steelborePalette.moltenAmber   # bright white
      ];
      background-color = steelborePalette.voidNavy;
      foreground-color = steelborePalette.moltenAmber;
      use-theme-colors = false;
      opacity = 0.95;
    };

    # ── GNOME Console (kgx) ─────────────────────────────────────────────────
    # kgx has limited theming: fixed "night"/"day"/"auto" themes only.
    # Shell is inherited from $SHELL (nushell). Font can be customized.
    "org/gnome/Console" = {
      theme = "night";
      use-system-font = false;
      custom-font = "JetBrains Mono 12";
    };
  };
}
