{pkgs, ...}: {
  i18n = {
    defaultLocale = "en_US.UTF-8";
    # TODO: only add Japanese if the user wants it
    supportedLocales = ["en_US.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8"];
  };

  console = {
    keyMap = "us";
  };
}
