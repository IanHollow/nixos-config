{
  pkgs,
  unstable,
  vars,
  inputs,
  config,
  nix-vscode-extensions,
  ...
}: {
  home-manager.users.${vars.user} = {
    programs.vscode = {
      enable = true;
      enableUpdateCheck = false;
      mutableExtensionsDir = false;
      enableExtensionUpdateCheck = false;
      userSettings = {
        # Miscellanious
        "files.autoSave" = "onFocusChange"; # Save on change of focus i.e. switching files/windows
        "editor.formatOnSave" = true; # Format on save (may be annoying for some people)
        "editor.inlineSuggest.enabled" = true;
        "extensions.ignoreRecommendations" = true;
        "explorer.confirmDragAndDrop" = false;
        "editor.fontSize" = 14;
        "terminal.integrated.fontSize" = 13;
        "workbench.activityBar.location" = "top";
        "editor.minimap.enabled" = false;

        # Font
        "editor.fontLigatures" = true;
        "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";

        # Theming
        "window.titleBarStyle" = "custom"; # Helps with stability on wayland
        "workbench.iconTheme" = "material-icon-theme";
        "terminal.integrated.cursorStyle" = "line";
        "workbench.colorTheme" = "Catppuccin Mocha";
        "catppuccin.accentColor" = "lavender";
        "editor.semanticHighlighting.enabled" = true;

        # Git
        "git.openRepositoryInParentFolders" = "always";
        "git.autofetch" = true;
        "git.confirmSync" = false;

        # Nix
        "[nix]"."editor.tabSize" = 2;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "rnix-lsp";

        # C and CPP
        "[c]"."editor.tabSize" = 4;
        "[cpp]"."editor.tabSize" = 4;
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

        # Go
        "gopls"."ui.semanticTokens" = true;

        # Markdown
        "[markdown]"."editor.tabSize" = 2;
      };

      # Extensions
      extensions = with unstable.vscode-extensions;
        [
          # C and CPP
          ms-vscode.cpptools # If installed from vscode flake it will not work

          # Python
          ms-python.python # Not tested yet
          ms-python.vscode-pylance # Not tested yet
          ms-toolsai.jupyter # Not tested yet

          # JavaScript & TypeScript
          dbaeumer.vscode-eslint # Not tested yet
          wix.vscode-import-cost # Not tested yet

          # Nix
          jnoortheen.nix-ide
          kamadorueda.alejandra

          # Theming
          catppuccin.catppuccin-vsc
          pkief.material-icon-theme

          # Extra
          github.copilot
          ms-vscode-remote.remote-ssh
        ]
        # the package vscode-flake-extensions has multiple options for extensions
        # most importantly there are vscode marketplace extensions and open vsx extensions
        # additionally there are release versions and pre-release versions
        # however the release do not seem to work
        # here is a link to the documentation for the flake:
        # https://github.com/nix-community/nix-vscode-extensions#extensions
        # NOTE: make sure that the author names are in lowercase
        ++ (with inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
          # JavaScript & TypeScript
          ms-vscode.vscode-typescript-next # Not tested yet

          # Extra
          christian-kohler.path-intellisense # Not tested yet
          visualstudioexptteam.vscodeintellicode # Not tested yet

          # HTML & CSS
          bradlc.vscode-tailwindcss # Not tested yet

          # Language Packs
          # TODO: enable this if user wants a specific language for nixos
          ms-ceintl.vscode-language-pack-ja # Not tested yet
        ]);

      package = unstable.vscode.override {
        # TODO: only add commandLineArgs based on config options
        commandLineArgs = "--password-store=gnome --enable-wayland-ime";
      };
    };
  };

  # Extra Packages that vscode extensions will fail without
  # TODO: add options to enable and disable programming languages
  #       so that most of these are already installed
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

  # kering needed for some extensions
  keyring.enable = true;

  # enable nix-ld for extenstions with non-nix binaries
  programs.nix-ld.enable = true;
}
