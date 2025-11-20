# For Juspay work
{ pkgs, config, lib, ... }:
let
  cfg = config.programs.juspay;
in
{
  options.programs.juspay = {
    enable = lib.mkEnableOption "Juspay work configuration" // {
      default = true;
    };

    jumpHost = lib.mkOption {
      type = lib.types.str;
      default = "vanjaram.tail12b27.ts.net";
      description = ''
        Jump host (a machine in Juspay office) used to access Juspay services without VPN.
        Used as SSH proxy jump for Bitbucket and as SOCKS5 tunnel endpoint.
      '';
    };

    identityFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Optional path to SSH identity file used for authenticating to Juspay's Bitbucket (ssh.bitbucket.juspay.net).
        If not specified, SSH will use default authentication methods.
      '';
    };

    baseCodeDir = lib.mkOption {
      type = lib.types.str;
      default = "~/juspay";
      description = ''
        Base directory containing Juspay code repositories (git commits in subdirectories will use the configured email)
      '';
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "sridhar.ratnakumar@juspay.in";
      description = ''
        Email address to use for git commits within the baseCodeDir
      '';
    };

    socks5Proxy = {
      enable = lib.mkEnableOption "SOCKS5 proxy via SSH tunnel" // {
        default = true;
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 1080;
        description = ''
          Local port to bind the SOCKS5 proxy server (tunneled through jumpHost)
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        # For git cloning via another jump host
        "ssh.bitbucket.juspay.net" = {
          user = "git";

          # This is the magic line that routes traffic 
          # through the other machine
          proxyJump = cfg.jumpHost;

          identityFile = lib.mkIf (cfg.identityFile != null) cfg.identityFile;
        };
        "${cfg.jumpHost}" = {
          forwardAgent = true;
        };
      };
    };

    programs.git = {
      # Bitbucket git access and policies
      includes = [
        {
          condition = "gitdir:${cfg.baseCodeDir}/**";
          contents = {
            user.email = cfg.email;
          };
        }
      ];
    };

    # SOCKS5 proxy via SSH tunnel to jump host
    launchd.agents.juspay-socks5-proxy = lib.mkIf (cfg.socks5Proxy.enable && pkgs.stdenv.isDarwin) {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.openssh}/bin/ssh"
          "-D" # Dynamic port forwarding (SOCKS proxy)
          (toString cfg.socks5Proxy.port)
          "-N" # Don't execute remote command
          # "-q" # Quiet mode (suppress warnings)
          "-C" # Enable compression
          cfg.jumpHost
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/socks5-proxy.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/socks5-proxy.err";
      };
    };

    systemd.user.services.juspay-socks5-proxy = lib.mkIf (cfg.socks5Proxy.enable && pkgs.stdenv.isLinux) {
      Unit = {
        Description = "SOCKS5 proxy via SSH tunnel to Juspay jump host";
        After = [ "network.target" ];
      };

      Service = {
        ExecStart = "${pkgs.openssh}/bin/ssh -D ${toString cfg.socks5Proxy.port} -N -C ${cfg.jumpHost}";
        Restart = "always";
        RestartSec = "10s";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
