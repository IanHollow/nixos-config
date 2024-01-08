{
  pkgs,
  unstable,
  vars,
  config,
  lib,
  host,
  ...
}:
with lib; {
  options = {
    custom_networking = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable networking
        '';
      };
      autoHostId = mkOption {
        type = types.bool;
        default = true;
      };
      wireguard = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable wireguard.
          Command to load wireguard cert in nm-applet "nmcli connection import type wireguard file <config file>".
          Make sure the config file name is short otherwise the command will fail.
        '';
      };
      cloudflareDNS = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable cloudflare DNS.
        '';
      };
      radomizeMacAddress = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable randomize mac address.
        '';
      };
      wifiPowersave = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable wifi powersave.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf (config.custom_networking.enable) {
      # Add users to the network manager group
      users.users.${vars.user}.extraGroups = ["networkmanager"];

      # Enable Networking
      networking = {
        # Network Manager
        networkmanager = {
          # Enable Network Manager
          enable = mkDefault true;

          # Change wifi backend of Network Manager to iwd
          wifi.backend = mkDefault "iwd";

          # Set random mac address
          wifi.macAddress = mkDefault "random";
          ethernet.macAddress = mkDefault "random";

          # Enable wifi powersave
          wifi.powersave = mkDefault config.custom_networking.wifiPowersave;
        };

        # Enable and config iwd
        wireless.iwd = {
          # Enable iwd
          enable = mkDefault true;

          # Define iwd settings
          settings = {
            General = {
              # Must be set to "network" to enable Random MAC Address
              AddressRandomization = mkIf (config.custom_networking.radomizeMacAddress) "network";
            };

            Network = {
              EnableIPv6 = mkDefault (config.networking.enableIPv6 && !config.custom_networking.wireguard);
            };

            Settings = {
              # Enable Auto Connect to WiFi
              AutoConnect = true;

              # Randomize MAC Address
              AlwaysRandomizeAddress = mkIf (config.custom_networking.radomizeMacAddress) true;
            };
          };
        };

        # Define Hostname
        # host var is from custom var in hosts/default.nix
        hostName = mkDefault host.hostName;

        # Host ID config from: github:colemickens/nixcfg/mixins/common.nix
        hostId = with lib.strings; let
          condition = config.custom_networking.autoHostId;
          hostName = config.networking.hostName;
        in
          mkIf condition (concatStrings (lists.take 8 (stringToCharacters (builtins.hashString "sha256" hostName))));

        # Enable Firewall
        firewall = {
          enable = mkDefault true;
          logReversePathDrops = true; # if packets are still dropped they will show up in dmesg
        };

        # Enable DHCP
        useDHCP = mkDefault true;

        # Enable Cloudflare DNS
        nameservers = let
          IPv4_DNS = ["1.1.1.1" "1.0.0.1"];
          IPv6_DNS =
            if config.networking.enableIPv6
            then ["2606:4700:4700::1111" "2606:4700:4700::1001"]
            else [];
        in
          mkIf config.custom_networking.cloudflareDNS (IPv4_DNS ++ IPv6_DNS);
      };
    })

    # Wireguard config
    (mkIf (config.custom_networking.wireguard && config.custom_networking.enable && config.networking.networkmanager.enable) {
      # Disable IPv6
      networking.enableIPv6 = mkForce false;

      # Enforce IPv6 disable
      # Fix for Related Issue: https://github.com/NixOS/nixpkgs/issues/87802
      boot.kernelParams = ["ipv6.disable=1"];

      # Enable Wireguard on Network Manager
      networking = {
        firewall = {
          extraCommands = ''
            ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
            ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
          '';
          extraStopCommands = ''
            ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
            ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
          '';
        };
      };
    })
  ];
}
