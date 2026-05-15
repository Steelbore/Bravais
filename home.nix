# SPDX-License-Identifier: GPL-3.0-or-later
# Spacecraft Software Bravais — Home Manager Configuration
{
  config,
  pkgs,
  lib,
  spacecraftPalette,
  ...
}:

{
  home.username = "mj";
  home.homeDirectory = "/home/mj";
  home.stateVersion = "25.11";

  # Spacecraft Software project symlink
  home.file."steelbore".source = config.lib.file.mkOutOfStoreSymlink "/steelbore";

  # Keyboard layout
  home.keyboard = {
    layout = "us,ara";
    options = [ "grp:ctrl_space_toggle" ];
  };

  # Session variables
  home.sessionVariables = {
    EDITOR = "${pkgs.msedit}/bin/edit";
    VISUAL = "${pkgs.msedit}/bin/edit";
    SPACECRAFT_THEME = "true";
  };

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
        gpg.format = "ssh";
        commit.gpgsign = true;
        init.defaultBranch = "main";
      };
    };

    # Starship prompt (Spacecraft Software theme)
    starship = {
      enable = true;
      settings = {
        format = "$directory$git_branch$git_status$cmd_duration$character";
        palette = "spacecraft";

        palettes.spacecraft = {
          void_navy = spacecraftPalette.voidNavy;
          molten_amber = spacecraftPalette.moltenAmber;
          steel_blue = spacecraftPalette.steelBlue;
          radium_green = spacecraftPalette.radiumGreen;
          red_oxide = spacecraftPalette.redOxide;
          liquid_coolant = spacecraftPalette.liquidCool;
        };

        directory = {
          style = "bold steel_blue";
          truncate_to_repo = true;
        };

        character = {
          success_symbol = "[>](bold radium_green)";
          error_symbol = "[x](bold red_oxide)";
        };

        git_branch = {
          style = "bold liquid_coolant";
          symbol = " ";
        };

        git_status = {
          style = "bold red_oxide";
          format = "([\\[$all_status$ahead_behind\\]]($style) )";
        };

        cmd_duration = {
          style = "bold molten_amber";
          min_time = 2000;
        };
      };
    };

    # Nushell configuration
    nushell = {
      enable = true;
      configFile.text = ''
        $env.config = {
          show_banner: false,
          ls: { use_ls_colors: true, clickable_links: true },
          cursor_shape: { emacs: block, vi_insert: block, vi_normal: block },
        }

        # Spacecraft Software Telemetry Aliases
        alias ll = ls -l
        alias lla = ls -la
        alias telemetry = macchina
        alias sensors = ^watch -n 1 sensors
        alias sys-logs = journalctl -p 3 -xb
        alias network-diag = gping google.com
        alias top-processes = bottom
        alias disk-telemetry = yazi
        alias edit = ${pkgs.msedit}/bin/edit

        # Project Spacecraft Software Identity
        def spacecraft [] {
          print "============================================================"
          print "  SPACECRAFT SOFTWARE :: Industrial Sci-Fi Desktop"
          print "============================================================"
          print "  STATUS    :: ACTIVE"
          print "  LOAD      :: NOMINAL"
          print "  INTEGRITY :: VERIFIED"
          print "============================================================"
        }
      '';
    };

    # Alacritty (Spacecraft Software theme)
    alacritty = {
      enable = true;
      settings = {
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
            background = spacecraftPalette.voidNavy;
            foreground = spacecraftPalette.moltenAmber;
          };
          cursor = {
            text = spacecraftPalette.voidNavy;
            cursor = spacecraftPalette.moltenAmber;
          };
          selection = {
            text = spacecraftPalette.voidNavy;
            background = spacecraftPalette.steelBlue;
          };
          normal = {
            black = spacecraftPalette.voidNavy;
            red = spacecraftPalette.redOxide;
            green = spacecraftPalette.radiumGreen;
            yellow = spacecraftPalette.moltenAmber;
            blue = spacecraftPalette.steelBlue;
            magenta = spacecraftPalette.steelBlue;
            cyan = spacecraftPalette.liquidCool;
            white = spacecraftPalette.moltenAmber;
          };
          bright = {
            black = spacecraftPalette.steelBlue;
            red = spacecraftPalette.redOxide;
            green = spacecraftPalette.radiumGreen;
            yellow = spacecraftPalette.moltenAmber;
            blue = spacecraftPalette.liquidCool;
            magenta = spacecraftPalette.liquidCool;
            cyan = spacecraftPalette.liquidCool;
            white = spacecraftPalette.moltenAmber;
          };
        };
      };
    };
  };

  # XDG config files
  xdg.configFile = {
    # ═══════════════════════════════════════════════════════════════════════════
    # NIRI — User configuration
    # ═══════════════════════════════════════════════════════════════════════════
    "niri/config.kdl".text = ''
      // Spacecraft Software Niri User Configuration

      layout {
          focus-ring {
              enable
              width 2
              active-color "${spacecraftPalette.moltenAmber}"
              inactive-color "${spacecraftPalette.steelBlue}"
          }
          border { off }
          gaps 8
      }

      spawn-at-startup "swaybg" "-c" "${spacecraftPalette.voidNavy}"
      spawn-at-startup "ironbar"
      spawn-at-startup "wired"

      binds {
          // Session
          Mod+Shift+E { quit; }

          // Applications
          Mod+Return { spawn "alacritty"; }
          Mod+D { spawn "onagre"; }
          Mod+Shift+D { spawn "anyrun"; }

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

          // Move windows (Vim-style)
          Mod+Shift+H { move-column-left; }
          Mod+Shift+L { move-column-right; }
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
          background-color: ${spacecraftPalette.voidNavy};
          color: ${spacecraftPalette.moltenAmber};
          border-bottom: 2px solid ${spacecraftPalette.steelBlue};
      }

      .widget {
          padding: 0 10px;
          border-left: 1px solid ${spacecraftPalette.steelBlue};
      }

      .workspaces button {
          color: ${spacecraftPalette.steelBlue};
          border-bottom: 2px solid transparent;
      }

      .workspaces button.active {
          color: ${spacecraftPalette.moltenAmber};
          border-bottom: 2px solid ${spacecraftPalette.moltenAmber};
      }

      .clock {
          color: ${spacecraftPalette.moltenAmber};
          font-weight: bold;
      }

      .sys_info {
          color: ${spacecraftPalette.radiumGreen};
      }
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # WEZTERM — User configuration
    # ═══════════════════════════════════════════════════════════════════════════
    "wezterm/wezterm.lua".text = ''
      -- Spacecraft Software WezTerm User Configuration
      local wezterm = require 'wezterm'
      local config = {}

      config.font = wezterm.font 'JetBrains Mono'
      config.font_size = 12.0
      config.window_background_opacity = 0.95
      config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
      config.enable_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = true

      config.colors = {
        foreground = "${spacecraftPalette.moltenAmber}",
        background = "${spacecraftPalette.voidNavy}",
        cursor_bg = "${spacecraftPalette.moltenAmber}",
        cursor_fg = "${spacecraftPalette.voidNavy}",
        cursor_border = "${spacecraftPalette.moltenAmber}",
        selection_bg = "${spacecraftPalette.steelBlue}",
        selection_fg = "${spacecraftPalette.voidNavy}",
        ansi = {
          "${spacecraftPalette.voidNavy}",
          "${spacecraftPalette.redOxide}",
          "${spacecraftPalette.radiumGreen}",
          "${spacecraftPalette.moltenAmber}",
          "${spacecraftPalette.steelBlue}",
          "${spacecraftPalette.steelBlue}",
          "${spacecraftPalette.liquidCool}",
          "${spacecraftPalette.moltenAmber}"
        },
        brights = {
          "${spacecraftPalette.steelBlue}",
          "${spacecraftPalette.redOxide}",
          "${spacecraftPalette.radiumGreen}",
          "${spacecraftPalette.moltenAmber}",
          "${spacecraftPalette.liquidCool}",
          "${spacecraftPalette.liquidCool}",
          "${spacecraftPalette.liquidCool}",
          "${spacecraftPalette.moltenAmber}"
        },
        tab_bar = {
          background = "${spacecraftPalette.voidNavy}",
          active_tab = {
            bg_color = "${spacecraftPalette.steelBlue}",
            fg_color = "${spacecraftPalette.moltenAmber}",
          },
          inactive_tab = {
            bg_color = "${spacecraftPalette.voidNavy}",
            fg_color = "${spacecraftPalette.steelBlue}",
          },
        },
      }

      return config
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # RIO — User configuration
    # ═══════════════════════════════════════════════════════════════════════════
    "rio/config.toml".text = ''
      # Spacecraft Software Rio User Configuration

      [window]
      opacity = 0.95

      [fonts]
      family = "JetBrains Mono"
      size = 14

      [colors]
      background = '${spacecraftPalette.voidNavy}'
      foreground = '${spacecraftPalette.moltenAmber}'
      cursor = '${spacecraftPalette.moltenAmber}'
      selection-background = '${spacecraftPalette.steelBlue}'
      selection-foreground = '${spacecraftPalette.voidNavy}'

      [colors.regular]
      black = '${spacecraftPalette.voidNavy}'
      red = '${spacecraftPalette.redOxide}'
      green = '${spacecraftPalette.radiumGreen}'
      yellow = '${spacecraftPalette.moltenAmber}'
      blue = '${spacecraftPalette.steelBlue}'
      magenta = '${spacecraftPalette.steelBlue}'
      cyan = '${spacecraftPalette.liquidCool}'
      white = '${spacecraftPalette.moltenAmber}'

      [colors.bright]
      black = '${spacecraftPalette.steelBlue}'
      red = '${spacecraftPalette.redOxide}'
      green = '${spacecraftPalette.radiumGreen}'
      yellow = '${spacecraftPalette.moltenAmber}'
      blue = '${spacecraftPalette.liquidCool}'
      magenta = '${spacecraftPalette.liquidCool}'
      cyan = '${spacecraftPalette.liquidCool}'
      white = '${spacecraftPalette.moltenAmber}'
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # GHOSTTY — User configuration
    # ═══════════════════════════════════════════════════════════════════════════
    "ghostty/config".text = ''
      # Spacecraft Software Ghostty User Configuration

      font-family = JetBrains Mono
      font-size = 12

      background-opacity = 0.95
      window-padding-x = 10
      window-padding-y = 10

      background = ${spacecraftPalette.voidNavy}
      foreground = ${spacecraftPalette.moltenAmber}
      cursor-color = ${spacecraftPalette.moltenAmber}
      cursor-text = ${spacecraftPalette.voidNavy}
      selection-background = ${spacecraftPalette.steelBlue}
      selection-foreground = ${spacecraftPalette.voidNavy}

      palette = 0=${spacecraftPalette.voidNavy}
      palette = 1=${spacecraftPalette.redOxide}
      palette = 2=${spacecraftPalette.radiumGreen}
      palette = 3=${spacecraftPalette.moltenAmber}
      palette = 4=${spacecraftPalette.steelBlue}
      palette = 5=${spacecraftPalette.steelBlue}
      palette = 6=${spacecraftPalette.liquidCool}
      palette = 7=${spacecraftPalette.moltenAmber}
      palette = 8=${spacecraftPalette.steelBlue}
      palette = 9=${spacecraftPalette.redOxide}
      palette = 10=${spacecraftPalette.radiumGreen}
      palette = 11=${spacecraftPalette.moltenAmber}
      palette = 12=${spacecraftPalette.liquidCool}
      palette = 13=${spacecraftPalette.liquidCool}
      palette = 14=${spacecraftPalette.liquidCool}
      palette = 15=${spacecraftPalette.moltenAmber}
    '';
  };

  # dconf settings for GNOME-based terminals (Ptyxis, GNOME Console)
  dconf.settings = {
    "org/gnome/Ptyxis" = {
      default-profile-uuid = "spacecraft";
      font-name = "JetBrains Mono 12";
      use-system-font = false;
    };
    "org/gnome/Ptyxis/Profiles/spacecraft" = {
      label = "Spacecraft Software";
      palette = [
        spacecraftPalette.voidNavy      # black
        spacecraftPalette.redOxide      # red
        spacecraftPalette.radiumGreen   # green
        spacecraftPalette.moltenAmber   # yellow
        spacecraftPalette.steelBlue     # blue
        spacecraftPalette.steelBlue     # magenta
        spacecraftPalette.liquidCool    # cyan
        spacecraftPalette.moltenAmber   # white
        spacecraftPalette.steelBlue     # bright black
        spacecraftPalette.redOxide      # bright red
        spacecraftPalette.radiumGreen   # bright green
        spacecraftPalette.moltenAmber   # bright yellow
        spacecraftPalette.liquidCool    # bright blue
        spacecraftPalette.liquidCool    # bright magenta
        spacecraftPalette.liquidCool    # bright cyan
        spacecraftPalette.moltenAmber   # bright white
      ];
      background-color = spacecraftPalette.voidNavy;
      foreground-color = spacecraftPalette.moltenAmber;
      use-theme-colors = false;
      opacity = 0.95;
    };
  };
}
