# Bravais -- A Steelbore NixOS Distribution

## What this is

A flake-based NixOS configuration implementing the Steelbore Standard. The `mkBravais` function in `flake.nix` generates **10 nixosConfigurations**: 5 stable (nixos-25.11) + 5 unstable (nixos-unstable), each with x86-64 march levels v1-v4. The default `bravais` target is stable v4.

## Build and test commands

```sh
nix flake check                                    # Evaluate all 10 configs
nix flake show                                     # List outputs
nixos-rebuild dry-build --flake .#bravais           # Dry run
sudo nixos-rebuild switch --flake .#bravais         # Apply (default: stable v4)
sudo nixos-rebuild switch --flake .#bravais-v3      # Stable v3
sudo nixos-rebuild switch --flake .#bravais-unstable # Unstable v4
```

## Rebuild commands (user's actual workflow)

These target `bravais-unstable-v3` and stage `/etc/nixos/` from the working
tree before rebuilding. Run as the user, not as root.

```nu
# Nushell
sudo nix-collect-garbage --verbose -d ; sudo journalctl --vacuum-time=7d ; sudo cp --verbose -r ...(glob /steelbore/bravais/*) /etc/nixos/ ; print "cd /etc/nixos/" ; cd /etc/nixos/ ; sudo rm --verbose -r ...( [v0 "*.md" "flake.*" LICENSE "*.docx" hosts lib modules overlays users "*.txt"] | each { |p| glob $p } | flatten ) ; cd /steelbore/bravais/ ; sudo nix-channel --verbose --update ; sudo nixos-rebuild switch --flake .#bravais-unstable-v3 --show-trace --verbose
```

```sh
# Brush / Bash
sudo nix-collect-garbage --verbose -d ; sudo journalctl --vacuum-time=7d ; sudo cp --verbose -r /steelbore/Bravais/* /etc/nixos/ ; pwd ; echo "cd /etc/nixos/" ; cd /etc/nixos/ ; pwd ; sudo rm --verbose -r v0 *.md flake.* LICENSE *.docx hosts lib modules overlays users *.txt ; sudo cp --verbose -r /steelbore/Bravais/* /etc/nixos/ ; sudo nix-channel --verbose --update ; cd /steelbore/bravais/ ; sudo nixos-rebuild switch --flake .#bravais-unstable-v3 --show-trace --verbose
```

## Architecture

- **Flake inputs**: nixpkgs (25.11), nixpkgs-unstable, home-manager (release-25.11), home-manager-unstable, nix-flatpak. No third-party flakes for DEs.
- **Module namespace**: All opt-in modules use `steelbore.*` with `lib.mkEnableOption`. Toggled in `hosts/bravais/default.nix`.
- **Color palette**: Defined as `steelborePalette` in `flake.nix`, passed via `specialArgs` and `extraSpecialArgs` to all modules and Home Manager.
- **Overlays**: Defined inline in `modules/core/nix.nix` (not imported from `overlays/default.nix`, which is a reference copy).
- **Home Manager**: Single user `mj`, config at `users/mj/home.nix`. Uses `useGlobalPkgs`, `useUserPackages`, `backupFileExtension = "backup"`.

## File layout

```
flake.nix                  # mkBravais, inputs, palette, 10 configs
hosts/bravais/default.nix  # Host: user, shell, steelbore.* toggles
hosts/bravais/hardware.nix # Generated hardware config
modules/core/              # Always-on: nix.nix, boot.nix, locale.nix, audio.nix, security.nix
modules/core/nix.nix       # Overlays live here (inline)
modules/theme/             # Palette env vars, TTY colors, fonts
modules/desktops/          # gnome, cosmic, plasma, niri, leftwm
modules/login/             # greetd + tuigreet + shell sessions
modules/packages/          # 12 opt-in bundles: ai, browsers, development, editors,
                           #   flatpak, multimedia, networking, productivity,
                           #   security, system, terminals
users/mj/default.nix       # System user definition
users/mj/home.nix          # Home Manager config (~900 lines)
overlays/                  # Reference overlay + claude-code-package-lock.json
lib/default.nix            # mkSteelboreModule helper, palette
```

## First-time bootstrap

The Steelbore Construct repo (`github:Steelbore/Construct`) lives at
`/steelbore/construct/` and is wired into a hub-and-spoke layout by Home
Manager: `~/.agents/skills/<skill>` is a per-skill symlink to
`/steelbore/construct/<skill>`, and `~/.agent/skills`, `~/.ai/skills`,
`~/.aichat/skills`, `~/.claude/skills`, `~/.codex/skills`, `~/.copilot/skills`,
`~/.opencode/skills` are each a single directory-level symlink to
`~/.agents/skills`. `.gemini` is intentionally omitted — Gemini reads
`~/.agents/` directly. See `users/mj/home.nix:16-72`. On a fresh machine,
clone the source repo before the first `nixos-rebuild`:

```sh
sudo mkdir -p /steelbore && sudo chown $USER /steelbore
git clone git@github.com:Steelbore/Construct.git /steelbore/construct
```

To pull updates later, run `skills-sync` (Nushell command). Sync is
intentionally decoupled from rebuild — rebuild stays offline-clean.

## Adding packages

Add to the appropriate `modules/packages/*.nix` file. Group by category, prefer Rust packages, add a comment with language. Example:

```nix
my-tool                    # Rust -- Description
```

After adding, update `PRD.md` (package inventory section) and `TODO.md` (relevant phase checklist).

## Key conventions

- **SPDX headers**: Every `.nix` file starts with `# SPDX-License-Identifier: GPL-3.0-or-later`
- **Rust-first**: Prefer memory-safe alternatives (sudo-rs over sudo, Sequoia over GnuPG, Nushell over bash, etc.)
- **Shells**: User shell = Nushell, root shell = Brush. Bash module stays enabled (PAM requirement) but is not assigned as any user's login shell.
- **Default terminal**: Rio (for Niri `Mod+Return` and LeftWM `Mod+Return`)
- **Default editor**: msedit (`EDITOR`/`VISUAL` in home.nix)
- **Terminal configs**: All 15 terminals get Steelbore-themed system-level configs in `/etc/` with Nushell as shell
- **ISO 8601**: All date/time displays use `%Y-%m-%d %H:%M:%S` 24h format

## Known constraints

1. **bash cannot be replaced via overlay** -- `pkgs.bash` is used by stdenv for building every derivation. Overriding it creates an infinite recursion. Workaround: exclude from login shells, assign Nushell/Brush instead.
2. **`programs.bash.enable` must stay true** -- Disabling it breaks PAM builds (`userdel.pam`). NixOS activation scripts depend on the bash module.
3. **task-master-ai** -- npm build is broken in nixpkgs and unfixable via overlay. Upstream's `package-lock.json` omits the platform-specific optionalDependencies of `@biomejs/biome` (devDep) and `esbuild` (workspace devDep). `npm ci` validates the lockfile against package.json before any `--omit=optional` or fetcher-v2 logic kicks in, so it always fails. Workaround: `modules/packages/ai.nix` ships a `task-master` shell wrapper that runs `npx -y --package=task-master-ai task-master "$@"` against `pkgs.nodejs`. First invocation populates `~/.npm/_npx`; later ones are near-instant. The nixpkgs `task-master-ai` line stays commented out.
4. **claude-code overlay** -- Pinned to latest npm release via `overrideAttrs` in `modules/core/nix.nix`. Lock file at `overlays/claude-code-package-lock.json`. Key gotchas: (a) Must explicitly override `npmDeps` (not just `npmDepsHash`) because `buildNpmPackage`'s internal `fetchNpmDeps` does not pick up overridden `src`/`npmDepsHash` from `overrideAttrs`. (b) Since ~2.1.113, claude-code uses a native binary architecture -- `bin/claude.exe` is a placeholder replaced by `install.cjs` (postinstall). Since `buildNpmPackage` doesn't run postinstall, the overlay runs `node install.cjs` in `postInstall`. (c) `package-lock.json` must be baked into `src` via `runCommand` so `fetchNpmDeps` can see it. To update: prefetch new tarball hash, regenerate lock file with `npm install --package-lock-only`, recompute `npmDepsHash` with `prefetch-npm-deps`, update the four values in the overlay (version, src hash, npmDepsHash, npmDeps).
5. **Stable/unstable package-name splits** -- Several packages were promoted from a sub-attr to top-level on unstable while still living under the old path on stable 25.11. Affected (so far): `xfce.xfce4-terminal`, `xorg.xinit`/`xauth`/`xrdb`/`xsetroot`, and the `swww` → `awww` rename. The repo handles these with the `or`-fallback idiom — e.g. `(pkgs.xfce4-terminal or pkgs.xfce.xfce4-terminal)`, `(pkgs.xinit or pkgs.xorg.xinit)`. For `swww`/`awww` the upstream rename also changed the binary names, so `wallpaperPkg = pkgs.awww or pkgs.swww;` is paired with `wallpaperBin = if pkgs ? awww then "awww" else "swww";` and spawn-at-startup uses `${wallpaperPkg}/bin/${wallpaperBin}-daemon`. New deprecations from a stable→unstable promotion should follow the same pattern.
6. **`useFetchCargoVendor` warnings** -- Come from upstream COSMIC packages. Harmless, cannot be suppressed from user config.
7. **External flakes are threaded via `specialArgs` / `extraSpecialArgs`** -- `gitway` (`github:Steelbore/Gitway`, tracks `main`) is the canonical example. Add the input in `flake.nix`, append it to the `outputs = { ... }` arg list, and inject it into both `specialArgs = { inherit steelborePalette gitway; }` and `home-manager.extraSpecialArgs = { inherit steelborePalette gitway; }` in `mkBravais`. Modules that consume it accept `gitway` in their function signature (e.g., `{ config, lib, pkgs, gitway, ... }:`) and reference its package as `gitway.packages.${pkgs.system}.default`. Do this for any future flake-input-derived package -- do NOT use overlays for it.
8. **`programs.ssh.startAgent` must stay `false`** -- `gitway-agent` (Home Manager service) owns `$SSH_AUTH_SOCK` at `${XDG_RUNTIME_DIR}/gitway-agent.sock` and conflicts with the system `ssh-agent.service`. Re-enabling `programs.ssh.startAgent` would race gitway-agent for the socket. `openssh_hpn` is still installed for general-purpose `ssh`/`scp`/`sftp`/`rsync -e ssh` against non-GitHub hosts -- those tools talk to `gitway-agent` over the OpenSSH agent wire protocol transparently.

## Documentation maintenance

When making changes, keep these in sync:
- **PRD.md** -- Product requirements, architecture details, package inventories
- **TODO.md** -- Implementation checklist with `[✓]` markers, known issues, phase progress table

Use `[✓]` (not `[x]`) for completed items in TODO.md.
