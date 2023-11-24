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
        "[nix]"."editor.tabSize" = 2;
        "editor.fontLigatures" = true;
        "editor.fontFamily" = "CaskaydiaCove NF";
        "terminal.integrated.fontFamily" = "CaskaydiaCove NF";
        "files.exclude" = {"**/node_modules/**" = true;};
        "editor.formatOnSave" = true;
        "workbench.colorTheme" = "Gruvbox Dark Hard";
        "workbench.iconTheme" = "material-icon-theme";
        "window.titleBarStyle" = "custom";
        "C_Cpp.default.intelliSenseMode" = "linux-gcc-x64";
        "C_Cpp.default.cStandard" = "c99";
        "C_Cpp.codeAnalysis.clangTidy.enabled" = true;
        "editor.inlineSuggest.enabled" = true;
        "git.autofetch" = true;
      };
      extensions = with pkgs.vscode-extensions; [
        # C and CPP
        ms-vscode.cpptools

        # Nix
        jnoortheen.nix-ide
        kamadorueda.alejandra

        # Theming
        jdinhlife.gruvbox
        pkief.material-icon-theme

        # Extra
        github.copilot
      ];

      package = pkgs.vscode;
    };
  };

  # Extra Packages that vscode extensions will fail without
  environment.systemPackages = with pkgs; [
    # kamadorueda.alejandra
    alejandra

    # ms-vscode.cpptools
    gnumake
    valgrind
    gdb
  ];

  # needed for store VS Code auth token
  programs.seahorse.enable = true;
  services.gnome.gnome-keyring.enable = true;
  nixpkgs.config.vscode.commandLineArgs = "--password-store='gnome'";
}
