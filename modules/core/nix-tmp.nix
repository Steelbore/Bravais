# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Bravais — Loop-mounted /mnt/nix-tmp for Nix builder TMPDIR
#
# Move Nix's working set off the system disk and onto a 40 GiB ext4
# loop image on the user's Expansion external drive. udisks2 mounts
# the drive at /run/media/mj/Expansion after login (no UUID-based
# fileSystems entry available — the drive is removable). A systemd
# path unit watches that directory; when it appears, a oneshot
# service creates the .img if missing, mkfs.ext4's it, mounts it
# loop-back at /mnt/nix-tmp, and chmods 1777.
#
# nix-daemon's TMPDIR is set to /mnt/nix-tmp unconditionally. With
# the drive unplugged, /mnt/nix-tmp is the empty local tmpfiles dir
# and builds fall back to the system disk transparently. With the
# drive plugged in, the same path resolves to the loop ext4.
{ config, lib, pkgs, ... }:

let
  imgPath  = "/run/media/mj/Expansion/nix-tmp.img";
  mountAt  = "/mnt/nix-tmp";
  # 80 GiB chosen because 40 GiB couldn't fit deno-2.7.13 + LTO +
  # codegen-units=1 + parallel cargo for sibling crates
  # (deno_core/deno_runtime/test_server/dcore) — peak ~50–55 GiB.
  # Sparse, so the .img only consumes what builds actually write.
  # Note: this only governs *fresh* image creation by the oneshot
  # service below; an already-existing .img must be grown imperatively
  # via truncate + e2fsck + resize2fs (see CLAUDE.md / Round 11 plan).
  imgSize  = "80G";
in
{
  systemd.tmpfiles.rules = [ "d ${mountAt} 1777 root root -" ];

  systemd.paths.nix-tmp-loop = {
    description = "Watch for Expansion drive auto-mount, then bring up nix-tmp loop";
    pathConfig = {
      PathExists = "/run/media/mj/Expansion";
      Unit = "nix-tmp-loop.service";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.nix-tmp-loop = {
    description = "Create and mount Nix builder loop image at ${mountAt}";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "nix-tmp-loop-up" ''
        set -eu
        if [ ! -f "${imgPath}" ]; then
          ${pkgs.coreutils}/bin/truncate -s ${imgSize} "${imgPath}"
          ${pkgs.e2fsprogs}/bin/mkfs.ext4 -F "${imgPath}"
        fi
        ${pkgs.util-linux}/bin/mountpoint -q "${mountAt}" || \
          ${pkgs.util-linux}/bin/mount -o loop "${imgPath}" "${mountAt}"
        ${pkgs.coreutils}/bin/chmod 1777 "${mountAt}"
      '';
      ExecStop = pkgs.writeShellScript "nix-tmp-loop-down" ''
        ${pkgs.util-linux}/bin/mountpoint -q "${mountAt}" && \
          ${pkgs.util-linux}/bin/umount "${mountAt}" || true
      '';
    };
  };

  systemd.services.nix-daemon.environment.TMPDIR = mountAt;
}
