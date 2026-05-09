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
  imgSize  = "40G";
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
