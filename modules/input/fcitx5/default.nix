{
  pkgs,
  vars,
  inputs,
  config,
  lib,
  ...
}
: {
  home-manager.users.${vars.user} = {
    lib,
    config,
    ...
  }: {
    # create profiel-backup file to backup fcitx5 profile
    home.file."${config.xdg.configHome}/fcitx5/profile-backup".source = ./profile.conf;
    home.file."${config.xdg.configHome}/fcitx5/profile".source = ./profile.conf;

    # Theme & color schema
    # TODO: change theme and test it
    home.file."/home/${vars.user}/.local/share/fcitx5/themes".source = "${inputs.catppuccin-fcitx5}/src";
    home.file."${config.xdg.configHome}/fcitx5/conf/classicui.conf".source = ./classicui.conf;

    # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile file,
    # which will override my config managed by home-manager
    # so we need to remove it before everytime we rebuild the config
    home.activation.removeExistingFcitx5Config = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      rm -f "${config.xdg.configHome}/fcitx5/profile-backup"
      rm -f "${config.xdg.configHome}/fcitx5/profile"
      rm -f "${config.xdg.configHome}/fcitx5/conf/classicui.conf"
    '';

    # enable fcitx5 input method
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc # Japanese IME
        fcitx5-gtk # GTK Support
        libsForQt5.fcitx5-qt # Qt Support
        fcitx5-lua # Lua Support
        fcitx5-configtool # GUI Config Tool
      ];
    };
  };

  # set environment variables to enable fcitx5
  environment.sessionVariables = let
    hyprlandSessionVariables =
      if (config.hyprland.enable)
      then {
        QT_IM_MODULE = "fcitx";
      }
      else {};
  in
    # Merge the base variables with the extra variables
    lib.mkMerge [
      # Base Variables
      {
        XMODIFIERS = "@im=fcitx";
        # GTK_IM_MODULE = "fcitx"; # since on wayland we leave this unset
      }

      # Optional Variables
      hyprlandSessionVariables
    ];

  # the profile config will be overwrited by fcitx5 every time we relogin
  # so we need to use the backup file to restore it every time we relogin
  # create a user service to copy profile-backup to profile at every login
  # TODO: make this a service inside of home-manager
  systemd.user.services.fcitx5-setup = let
    RestoreBackup = "${pkgs.coreutils}/bin/cp ${config.users.users.${vars.user}.home}/.config/fcitx5/profile-backup ${config.users.users.${vars.user}.home}/.config/fcitx5/profile";
  in {
    description = "Restore Backup fcitx5 profile";
    wantedBy = ["multi-user.target"];
    after = ["multi-user.target"]; # Ensures the service starts after the multi-user target
    serviceConfig = {
      Type = "oneshot"; # Only run once
      ExecStart = RestoreBackup;
    };
  };
}
