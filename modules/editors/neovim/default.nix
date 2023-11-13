{
  pkgs,
  vars,
  ...
}: {
  home-manager.users.${vars.user} = {
    programs.neovim = let
      # functions to convert lua into vimscript that calls lua
      toLua = str: "lua << EOF\n${str}\nEOF\n";
      toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
    in {
      enable = true;

      plugins = with pkgs.vimPlugins; [
        # git related plugins
        vim-fugitive
        vim-rhubarb

        # detect tabstop and shiftwidth automatically for file
        vim-sleuth

        # LSP
        {
          plugin = nvim-lspconfig;
          config = toLuaFile ./config/plugins/lsp.lua;
        }

        # LSP Dependencies
        # Automatically install LSPs to stdpath for neovim
        {
          plugin = mason-nvim;
          config = toLua "config = true";
        }
        mason-lspconfig-nvim
        # Useful status updates for LSP
        # NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
        {
          plugin = fidget-nvim;
          config = toLua ''
            tag = 'legacy'
            opts = {}
          '';
        }
        # Additional lua configuration, makes nvim stuff amazing!
        neodev-nvim

        # Autocompletion
        {
          plugin = nvim-cmp;
          config = toLuaFile ./config/plugins/cmp.lua;
        }
        # Autocompletion Dependencies
        # Snippet Engine & its associated nvim-cmp source
        luasnip
        cmp_luasnip
        # Adds LSP completion capabilities
        cmp-nvim-lsp
        # Adds a number of user-friendly snippets
        friendly-snippets

        # Adds git related signs to the gutter, as well as utilities for managing changes
        {
          plugin = gitsigns-nvim;
          config = toLuaFile ./config/plugins/gitsigns.lua;
        }

        # Set lualine as statusline
        {
          plugin = lualine-nvim;
          config = toLuaFile ./config/plugins/lualine.lua;
        }
      ];

      extraLuaConfig = ''
        ${builtins.readFile ./config/options.lua}
      '';
    };
  };
}
