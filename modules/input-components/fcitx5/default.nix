{
  pkgs,
  vars,
  ...
}
: {
  home-manager.users.${vars.user} = {
    lib,
    config,
    ...
  }: {
    home.file.".config/fcitx5/profile".source = ./profile;

    # color schema
    #home.file.".local/share/fcitx5/themes".source = "${catppuccin-fcitx5}/src";
    home.file.".config/fcitx5/conf/classicui.conf".source = ./classicui.conf;

    # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile file,
    # which will override my config managed by home-manager
    # so we need to remove it before everytime we rebuild the config
    home.activation.removeExistingFcitx5Profile = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      rm -f "${config.xdg.configHome}/fcitx5/profile"
    '';

    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc # Japanese IME
        fcitx5-gtk # GTK Support
        fcitx5-configtool # GUI Config Tool
      ];
    };

    # NOTE: Fcitx5 still needs to be started manually
    # For example in the hyprland config with exec-once
  };
}
