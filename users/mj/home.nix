# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Home Manager Configuration
{
  config,
  pkgs,
  lib,
  steelborePalette,
  ...
}:

{
  home.username = "mj";
  home.homeDirectory = "/home/mj";
  home.stateVersion = "25.11";

  # Steelbore project symlink
  home.file."steelbore".source = config.lib.file.mkOutOfStoreSymlink "/steelbore";

  # Keyboard layout
  home.keyboard = {
    layout = "us,ara";
    options = [ "grp:ctrl_space_toggle" ];
  };

  # Session variables
  home.sessionVariables = {
    EDITOR = "edit";
    VISUAL = "edit";
    STEELBORE_THEME = "true";
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

    # Starship prompt (Steelbore theme)
    starship = {
      enable = true;
      settings = {
        format = "$directory$git_branch$git_status$cmd_duration$character";
        palette = "steelbore";

        palettes.steelbore = {
          void_navy = steelborePalette.voidNavy;
          molten_amber = steelborePalette.moltenAmber;
          steel_blue = steelborePalette.steelBlue;
          radium_green = steelborePalette.radiumGreen;
          red_oxide = steelborePalette.redOxide;
          liquid_coolant = steelborePalette.liquidCool;
        };

        directory = {
          style = "bold steel_blue";
          truncate_to_repo = true;
        };

        character = {
          success_symbol = "[➜](bold radium_green)";
          error_symbol = "[✗](bold red_oxide)";
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

        # Steelbore Telemetry Aliases
        alias ll = ls -l
        alias lla = ls -la
        alias telemetry = macchina
        alias sensors = ^watch -n 1 sensors
        alias sys-logs = journalctl -p 3 -xb
        alias network-diag = gping google.com
        alias top-processes = bottom
        alias disk-telemetry = yazi
        alias edit = msedit

        # Project Steelbore Identity
        def steelbore [] {
          print "╔══════════════════════════════════════════════════════╗"
          print "║  STEELBORE :: Rust-Centric Desktop Environment       ║"
          print "╠══════════════════════════════════════════════════════╣"
          print "║  STATUS    :: ACTIVE                                 ║"
          print "║  LOAD      :: NOMINAL                                ║"
          print "║  INTEGRITY :: VERIFIED                               ║"
          print "╚══════════════════════════════════════════════════════╝"
        }
      '';
    };

    # Alacritty (Steelbore theme)
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

  # XDG config files
  xdg.configFile = {
    "niri/config.kdl".text = ''

      // User-specific Niri overrides
      layout {
          focus-ring {
              enable
              width 2
              active-color "${steelborePalette.moltenAmber}"
              inactive-color "${steelborePalette.steelBlue}"
          }
          border { off }
          gaps 8
      }
      spawn-at-startup "swaybg" "-c" "${steelborePalette.voidNavy}"
      spawn-at-startup "ironbar"
      spawn-at-startup "wired"
      binds {
          Mod+Shift+E { quit; }
          Mod+Return { spawn "alacritty"; }
          Mod+D { spawn "onagre"; }
          Mod+Q { close-window; }
          Mod+F { maximize-column; }
          Mod+H { focus-column-left; }
          Mod+L { focus-column-right; }
          Mod+K { focus-window-up; }
          Mod+J { focus-window-down; }
          Mod+Shift+H { move-column-left; }
          Mod+Shift+L { move-column-right; }
          Mod+Shift+K { move-window-up; }
          Mod+Shift+J { move-window-down; }
          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
      }
    '';

    "ironbar/config.yaml".text = "... (unchanged) ";
    "ironbar/style.css".text = "... (unchanged) ";
    "wezterm/wezterm.lua".text = "... (unchanged) ";
    "rio/config.toml".text = "... (unchanged) ";
  };
}
