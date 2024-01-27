{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    breeze-gtk
    breeze-qt5
    breeze-icons
  ];
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
}
