{
  pkgs,
  vars,
  ...
}: {
  # Set the default shell for the user
  users.users.${vars.user} = {
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # TODO: redo the config for zsh
  home-manager.users.${vars.user} = {config, ...}: {
    programs.zsh = {
      enable = true;

      # Default Plugins
      enableAutosuggestions = true;
      enableCompletion = true;
      historySubstringSearch.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        "ls" = "ls --color --group-directories-first";
      };

      history = {
        size = 99999;
        save = 99999;
      };

      # Oh My Zsh Plugins
      oh-my-zsh = {
        enable = true;
        plugins = ["git"];
      };

      # More Plugins
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];

      initExtra = ''
        [[ ! -f /home/${vars.user}/.p10k.zsh ]] || source /home/${vars.user}/.p10k.zsh
      '';
    };

    home.file."/home/${vars.user}/.p10k.zsh".source = ./.p10k.zsh;
  };
}
