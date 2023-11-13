{
  pkgs,
  unstable,
  vars,
  inputs,
  ...
}: {
  home-manager.users.${vars.user} = {
    programs.vscode = {
      enable = true;
      enableUpdateCheck = false;
      mutableExtensionsDir = false;
      enableExtensionUpdateCheck = false;

      userSettings = {
        "git.openRepositoryInParentFolders" = "always";
        "files.autoSave" = "onFocusChange";
        "editor.tabSize" = 4;
        "editor.fontLigatures" = true;
        "editor.fontFamily" = "CaskaydiaCove NF";
        "terminal.integrated.fontFamily" = "CaskaydiaCove NF";
        "files.exclude" = {"**/node_modules/**" = true;};
        "editor.formatOnSave" = true;
        "workbench.colorTheme" = "Gruvbox Dark Hard";
        "window.titleBarStyle" = "custom";
        "window.zoomLevel" = 1;
      };

      package = pkgs.vscode;
    };
  };

  # needed for store VS Code auth token
  programs.seahorse.enable = true;
  services.gnome.gnome-keyring.enable = true;
  nixpkgs.config.vscode.commandLineArgs = "--password-store='gnome'";
}
