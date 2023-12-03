{
  pkgs,
  unstable,
  vars,
  inputs,
  config,
  system,
  nix-vscode-extensions,
  ...
}: {
  home-manager.users.${vars.user} = let
    vscode-flake-extensions = inputs.nix-vscode-extensions.extensions.${system};
  in {
    programs.vscode = {
      enable = true;
      enableUpdateCheck = false;
      mutableExtensionsDir = false;
      enableExtensionUpdateCheck = false;
      userSettings = {
        # Miscellanious
        "window.titleBarStyle" = "custom"; # Helps with stability on wayland
        "files.autoSave" = "onFocusChange"; # Save on change of focus i.e. switching files/windows
        "editor.formatOnSave" = true; # Format on save (may be annoying for some people)
        "editor.inlineSuggest.enabled" = true;
        "extensions.ignoreRecommendations" = true;
        "explorer.confirmDragAndDrop" = false;

        # Font
        "editor.fontLigatures" = true;
        "editor.fontFamily" = "CaskaydiaCove NF";
        "terminal.integrated.fontFamily" = "CaskaydiaCove NF";

        # Theme
        "workbench.colorTheme" = "Gruvbox Dark Hard";
        "workbench.iconTheme" = "material-icon-theme";

        # Git
        "git.openRepositoryInParentFolders" = "always";
        "git.autofetch" = true;
        "git.confirmSync" = false;

        # Nix
        "[nix]"."editor.tabSize" = 2;
        "nix.enableLanguageServer" = true;

        # C and CPP
        "[c]"."editor.tabSize" = 4;
        "[cpp]"."editor.tabSize" = 4;
        "C_Cpp.default.intelliSenseMode" = "linux-gcc-x64";
        "C_Cpp.default.cStandard" = "c99";
        "C_Cpp.codeAnalysis.clangTidy.enabled" = true;

        # Python
        "[python]"."editor.tabSize" = 4;

        # HTML & CSS
        "[html]"."editor.tabSize" = 2;
        "[css]"."editor.tabSize" = 2;

        # JavaScript & TypeScript
        "[javascript]"."editor.tabSize" = 2;
        "[javascriptreact]"."editor.tabSize" = 2;
        "[typescript]"."editor.tabSize" = 2;
        "[typescriptreact]"."editor.tabSize" = 2;

        # Markdown
        "[markdown]"."editor.tabSize" = 2;
      };

      # Extensions
      # the package vscode-flake-extensions has multiple options for extensions
      # most importantly there are vscode marketplace extensions and open vsx extensions
      # additionally there are release versions and pre-release versions
      # however the release do not seem to work
      # here is a link to the documentation for the flake:
      # https://github.com/nix-community/nix-vscode-extensions#extensions
      # NOTE: make sure that the author names are in lowercase
      extensions = with vscode-flake-extensions.vscode-marketplace; [
        # C and CPP
        ms-vscode.cpptools

        # Python
        ms-python.python
        ms-python.vscode-pylance
        ms-toolsai.jupyter

        # JavaScript & TypeScript
        ms-vscode.vscode-typescript-next
        dbaeumer.vscode-eslint
        wix.vscode-import-cost

        # Nix
        jnoortheen.nix-ide
        kamadorueda.alejandra

        # Theming
        jdinhlife.gruvbox
        pkief.material-icon-theme

        # Extra
        christian-kohler.path-intellisense
        visualstudioexptteam.vscodeintellicode
        github.copilot
        github.copilot-chat

        # HTML & CSS
        bradlc.vscode-tailwindcss

        # Language Packs
        ms-ceintl.vscode-language-pack-ja # TODO: enable this if user wants japanese
      ];

      package = unstable.vscodium.override {
        commandLineArgs = "--password-store='gnome' --enable-wayland-ime";
      };
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

    # ms-python.python
    python3

    # jnoortheen.nix-ide
    rnix-lsp
  ];

  # needed for store VS Code auth token
  programs.seahorse.enable = !config.plasma.enable;
  services.gnome.gnome-keyring.enable = true;
}
