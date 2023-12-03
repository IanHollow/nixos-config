{
  pkgs,
  unstable,
  ...
}: {
  # TODO: add option to enable/disable discord
  environment.systemPackages = with unstable; [
    # override the discord package to add extensions
    (discord.override {
      # remove any overrides that you don't want
      withOpenASAR = true;
      withVencord = true;
    })
  ];
}
