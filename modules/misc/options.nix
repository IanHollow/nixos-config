{lib, ...}:
with lib; {
  # Define options that do not fit into a specific module
  options = {
    laptop = {
      # Condition if host is a laptop
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
}
