{
  pkgs,
  unstable,
  ...
}: {
  fonts = {
    # use fonts specified by user rather than default ones
    enableDefaultFonts = false;
    fontDir.enable = true;

    fonts = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome

      # Noto Fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-extra

      # Adobe Fonts
      source-sans
      source-serif
      source-han-sans
      source-han-serif

      # Google Fonts
      google-fonts

      # Nerdfonts
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "JetBrainsMono"
          "Iosevka"
          "CascadiaCode"
        ];
      })
    ];

    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojis that would sometimes show instead of some Color emojis
    fontconfig.defaultFonts = {
      serif = ["Noto Serif" "Noto Color Emoji"];
      sansSerif = ["Noto Sans" "Noto Color Emoji"];
      monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
      emoji = ["Noto Color Emoji"];
    };
  };
}
