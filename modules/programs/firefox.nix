{
  pkgs,
  unstable,
  config,
  lib,
  vars,
  ...
}:
with lib; {
  # define custom option for firefox
  options = {
    firefox = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  # TODO: improve config for firefox

  config = mkIf (config.firefox.enable) {
    home-manager.users.${vars.user} = let
      nixos_config = config; # to prevent home-manager from overwriting the config
    in
      {
        config,
        lib,
        ...
      }: {
        programs.firefox = {
          enable = true;
          package = unstable.firefox; # must use wrapped (not unwrapped) version if state version >= 19.09
          enableGnomeExtensions = false; # disable for security reasons

          # Configure firefox policies
          # Documentation:
          # https://mozilla.github.io/policy-templates/
          policies = {
            DisablePocket = true;
            DisableTelemetry = true;
            HardwareAcceleration = true;
            DisableFirefoxStudies = true;
            NoDefaultBookmarks = true;
            SearchSuggestEnabled = false;
            FirefoxSuggest = {
              WebSuggestions = false;
              SponsoredSuggestions = false;
              ImproveSuggest = false;
              Locked = true;
            };
            EnableTrackingProtection = {
              Value = true;
              Locked = true;
              Cryptomining = true;
              Fingerprinting = true;
              EmailTracking = true;
            };
          };

          # TODO: enable https only mode in firefox

          profiles = let
            inherit (builtins) toJSON;
            inherit (lib) concatLines mapAttrsToList;
            toUserJs = kv: concatLines (mapAttrsToList (k: v: "user_pref(${toJSON k}, ${toJSON v});") kv);
          in {
            # default profile
            default = {
              name = "${vars.user}";
              isDefault = true;

              extensions = with nixos_config.nur.repos.rycee.firefox-addons; [
                # Privacy
                ublock-origin # adblocker # TODO: configure the settings for this extension
                canvasblocker # prevent canvas fingerprinting
                decentraleyes # load cdn resources locally

                # YouTube
                sponsorblock # skip parts of youtube videos
                # improved-tube # improve youtube experience # TODO: look for alternatives as this broke my youtube at one point

                # GitHub
                octotree
                refined-github

                # Website Themes
                darkreader
                stylus

                # Passwords
                bitwarden # password manager

                # Language
                simple-translate # translate text

                # Other
                tampermonkey # userscripts (this can be unsafe if you install unsafe scripts)
              ];

              # Set extra preferences for security, privacy, simplicity, and performance
              # some options are set in the policies section
              extraConfig = toUserJs {
                # Homepage
                "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
                "browser.newtabpage.activity-stream.feeds.topsites" = false;
                "browser.newtabpage.activity-stream.default.sites" = "";
                "browser.newtabpage.activity-stream.showSponsored" = false;
                "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

                # Startup
                # "browser.startup.page" = 0;
                # "browser.startup.homepage" = "about:blank";
                # "browser.newtabpage.enabled" = false;

                # GeoLocation
                "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
                "geo.provider.ms-windows-location" = false;
                "geo.provider.use_corelocation" = false;
                "geo.provider.use_gpsd" = false;
                "geo.provider.use_geoclue" = false;

                # Disable extension recommendations
                "extensions.getAddons.showPane" = false;
                "browser.discovery.enabled" = false;
                "extensions.htmlaboutaddons.recommendations.enabled" = false;
                "browser.shopping.experience2023.enabled" = false;

                # Disable telemetry
                "datareporting.policy.dataSubmissionEnabled" = false;
                "datareporting.healthreport.uploadEnabled" = false;
                "toolkit.telemetry.unified" = false;
                "toolkit.telemetry.enabled" = false;
                "toolkit.telemetry.server" = "data:,";
                "toolkit.telemetry.archive.enabled" = false;
                "toolkit.telemetry.newProfilePing.enabled" = false;
                "toolkit.telemetry.shutdownPingSender.enabled" = false;
                "toolkit.telemetry.updatePing.enabled" = false;
                "toolkit.telemetry.bhrPing.enabled" = false;
                "toolkit.telemetry.firstShutdownPing.enabled" = false;
                "toolkit.telemetry.coverage.opt-out" = true;
                "toolkit.coverage.opt-out" = true;
                "toolkit.coverage.endpoint.base" = "";
                "browser.ping-centre.telemetry" = false;
                "browser.newtabpage.activity-stream.feeds.telemetry" = false;
                "browser.newtabpage.activity-stream.telemetry" = false;

                # Disable user experiments and studies
                "app.normandy.enabled" = false;
                "app.normandy.api_url" = "";
                "app.shield.optoutstudies.enabled" = false;

                # Disable crash reports
                "breakpad.reportURL" = "";
                "browser.tabs.crashReporting.sendReport" = false;
                "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

                # Other
                "captivedetect.canonicalURL" = "";
                "network.capaptive-portal-service.enabled" = false;
                "network.connectivity-service.enabled" = false;

                # Disable prefetching
                "network.prefetch-next" = false;
                "network.dns.disablePrefetch" = true;
                "network.predictor.enabled" = false;
                "network.predictor.enable-prefetch" = false;
                "network.http.speculative-parallel-limit" = 0;
                "browser.places.speculativeConnect.enabled" = false;

                # DNS
                "network.proxy.socks_remote_dns" = true;
                "network.file.disable_unc_paths" = true;
                "network.gio.supported-protocols" = "";
                "network.trr.mode" = 3; # Max Protection Setting with Cloudflare DNS

                # LOCATION BAR / SEARCH BAR / SUGGESTIONS / HISTORY
                "browser.urlbar.speculativeConnect.enabled" = false;
                "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
                "browser.urlbar.suggest.quicksuggest.sponsored" = false;
                "browser.urlbar.search.suggest.enabled" = false;
                "browser.urlbar.suggest.searches" = false;
                "browser.urlbar.trending.featureGate" = false;
                "browser.urlbar.addons.featureGate" = false;
                "browser.urlbar.mdn.featureGate" = false;
                "browser.urlbar.pocket.featureGate" = false;
                "browser.urlbar.weather.featureGate" = false;

                # Seperate Private Search Engines
                "browser.search.separatePrivateDefault" = true;
                "browser.search.separatePrivateDefault.ui.enabled" = true;

                # Disk Avoidance
                "browser.cache.disk.enable" = false;
                "browser.privatebrowsing.forceMediaMemoryCache" = true;
                "media.memory_cache_max_size" = 65536;
                "browser.sessionstore.privacy_level" = 2;
                "toolkit.winRegisterApplicationRestart" = false;
                "browser.shell.shortcutFavicons" = false;

                # HTTPS
                "security.ssl.require_safe_negotiation" = true;
                "security.tls.enable_0rtt_data" = false;
                "security.OCSP.enabled" = 1;
                "security.OCSP.require" = true;

                # CERTS / HTKP (HTTP Public Key Pinning)
                "security.cert_pinning.enforcement_level" = 2;
                "security.remote_settings.crlite_filters.enabled" = true;
                "security.pki.crlite_mode" = 2;

                # Mixed Content
                "dom.security.https_only_mode" = true;
                "dom.scurity.https_only_mode_send_http_background_request" = false;

                # UI
                "security.ssl.treat_unsafe_negotiation_as_broken" = true;
                "browser.xul.error_pages.expert_bad_cert" = true;

                # Referers
                "network.http.referer.XOriginTrimmingPolicy" = 2;

                # Containers
                "privacy.userContext.enabled" = true;
                "privacy.userContext.ui.enabled" = true;

                # Plugins / Media ? WebRTC
                "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;
                "media.peerconnection.ice.default_address_only" = true;

                # DOM
                "dom.disable_window_move_resize" = true;

                # Miscellanious
                "browser.download.start_downloads_in_tmp_dir" = true;
                "browser.helperApps.deleteTempFileOnExit" = true;
                "browser.uitour.enabled" = false;
                "devtools.debugger.remote-enabled" = false;
                "permissions.manager.defaultsUrl" = "";
                "webchannel.allowObject.urlWhitelist" = "";
                "network.IDN_show_punycode" = true;
                "pdfjs.disabled" = false;
                "pdfjs.enableScripting" = false;
                "browser.tabs.searchclipboardfor.middleclick" = false;

                # Downloads
                # "browser.download.useDownloadDir" = false; # This could be annoying
                "browses.download.alwaysOpenPanel" = false;
                "browser.download.manager.addToRecentDocs" = false;
                # "browser.download.always_ask_before_handling_new_types" = false; # This could be annoying

                # Extensions
                "extensions.enabledScopes" = 5;
                "extensions.postDownloadThirdPartyPrompt" = false;

                # ETP (Enhanced Tracking Protection)
                # Handled by Firefox policies

                # Enable RFP
                "privacy.resistFingerprinting" = true;
                "privacy.resistFingerprinting.block_mozAddonManager" = true;
                # "privacy.resistFingerprinting.letterboxing" = true; # This could be annoying
                "browser.link.open_newwindow" = 3;
                "browser.link.open_newwindow.restriction" = 0;

                # Extra
                "browser.startup.homepage_override.mstone" = "ignore";
                "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
                "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
                "browser.messaging-system.whatsNewPanel.enabled" = false;
                "browser.urlbar.showSearchTerms.enabled" = false;

                # Hardware Acceleration
                # TODO: check if NVIDIA drivers are installed
                # TODO: Add option to NVIDIA drivers to enable AV1
                "gfx.webrender.all" = true;
                "media.ffmpeg.vaapi.enabled" = true;
                "media.rdd-ffmpeg.enabled" = true;
                "media.av1.enabled" = true;
                "gfx.x11-egl.force-enabled" = true;
                "widget.dmabuf.force-enabled" = true;

                # Fonts
                "gfx.font_rendering.fontconfig.max_generic_substitutions" = 127;
                "gfx.font_rendering.opentype_svg.enabled" = false;
                "font.name-list.emoji" = "Noto Color Emoji";

                # Enable pre-release CSS
                "layout.css.has-selector.enabled" = true;
              };

              # search engines
              search = {
                # Define additional search engines
                engines = {
                  "Nix Packages" = {
                    urls = [
                      {
                        template = "https://search.nixos.org/packages";
                        params = [
                          {
                            name = "type";
                            value = "packages";
                          }
                          {
                            name = "query";
                            value = "{searchTerms}";
                          }
                        ];
                      }
                    ];

                    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                    definedAliases = ["@np"];
                  };

                  "NixOS Wiki" = {
                    urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
                    iconUpdateURL = "https://nixos.wiki/favicon.png";
                    updateInterval = 24 * 60 * 60 * 1000; # every day
                    definedAliases = ["@nw"];
                  };

                  "Brave" = {
                    urls = [{template = "https://search.brave.com/search?q={searchTerms}";}];
                    iconUpdateURL = "https://brave.com/static-assets/images/brave-favicon.png";
                    updateInterval = 24 * 60 * 60 * 1000; # every day
                    definedAliases = ["@brave"];
                  };

                  "YouTube" = {
                    urls = [{template = "https://www.youtube.com/results?search_query={searchTerms}";}];
                    iconUpdateURL = "https://www.youtube.com/favicon.ico";
                    updateInterval = 24 * 60 * 60 * 1000; # every day
                    definedAliases = ["@yt"];
                  };

                  # builtin engines only support specifying one additional alias
                  "Google".metaData.alias = "@g";
                };

                # force replace existing search configuration
                force = true;

                # Set default search engine
                default = "Google";

                # Set private default search engine
                privateDefault = "DuckDuckGo"; # TODO: Test doesn't seem to work
              };
            };
          };
        };
      };

    # environment variables
    environment.sessionVariables = let
      extraWaylandSessionVariables =
        # check if wayland is enabled
        if (config.wlwm.enable)
        then {
          MOZ_ENABLE_WAYLAND = "1";
        }
        else {};

      extraNvidiaSessionVariables =
        # check if nvidia drivers are installed
        if (config.nvidia_gpu.enable)
        then {
          MOZ_DISABLE_RDD_SANDBOX = "1";
          LIBVA_DRIVER_NAME = "nvidia";
        }
        else {};
    in
      # Merge the base variables with the extra variables
      mkMerge [
        # Base Variables
        {
          MOZ_USE_XINPUT2 = "1";
        }

        # Extra Variables
        extraWaylandSessionVariables
        extraNvidiaSessionVariables
      ];
  };
}
