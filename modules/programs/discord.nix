{
  pkgs,
  unstable,
  ...
}: {
  environment.systemPackages = with unstable; [
    # override the discord package to add extensions
    (discord.override {
      # remove any overrides that you don't want
      withOpenASAR = true;
      withVencord = true;
    })
  ];
}
