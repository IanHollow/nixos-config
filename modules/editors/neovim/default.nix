{
  pkgs,
  unstable,
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

      withPython3 = true;
      withNodeJs = true;

      extraPackages = with pkgs;
        [
          gnumake
          ripgrep
          fd
          xclip
          python3Full
          luarocks
          go
          nodejs
          shellcheck
          perl
        ]
        ++ (with unstable; [
          zulu # java
        ]);
    };
  };
}
