{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  options.python = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable python support.";
    };
    finalPackage = mkOption {
      type = with types; nullOr package;
      readOnly = true;
      description = "Resulting python package.";
    };
  };

  config = let
    my-python-packages = ps:
      with ps; [
        black # python formatter
        yapf # python formatter
      ];
    finalPackage = pkgs.python3.withPackages my-python-packages;
  in
    mkIf (config.python.enable) {
      # Install the final python package
      environment.systemPackages = [
        finalPackage
      ];

      # Set the final python package
      python.finalPackage = finalPackage;
    };
}
