{pkgs, unstable, ...}:{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    package = unstable.pipewire;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    wireplumber.package = unstable.wireplumber;
  };
}