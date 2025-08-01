{ pkgs, lib, config, ... }:
let 
  defaultPkg = (pkgs.microsoft-azurevpnclient
        or pkgs.callPackage ../packages/microsoft-azurevpnclient.nix { });
in
{
  options.programs.azurevpnclient = {
    enable = lib.mkEnableOption "Azure VPN Client";
    package = lib.mkOption {
      type        = lib.types.package;
      default     = defaultPkg;
      defaultText = lib.literalExpression "pkgs.microsoft-azurevpnclient";
      description = "Derivation to install for Azure VPN Client.";
    };
    polkitGroup = lib.mkOption {
      type        = lib.types.str;
      default     = "wheel";
      description = ''
        Unix group whose members may control systemd-resolved through
        polkit and thus use Azure VPN Client.  Change if you do not use
        the standard *wheel* administrative group.
      '';
    };
  };

  config = lib.mkIf config.programs.azurevpnclient.enable {
    environment.systemPackages = [ config.programs.azurevpnclient.package ];
    services.resolved.enable = true;

    security.wrappers.azurevpnclient = lib.mkForce {
      source       = "${config.programs.azurevpnclient.package}/bin/azurevpnclient";
      owner        = "root";
      group        = "root";
      capabilities = "cap_net_admin+eip";
    };

    environment.etc."polkit-1/rules.d/90-azurevpnclient.rules".text = ''
      polkit.addRule(function (action, subject) {
        if (subject.isInGroup("${config.programs.azurevpnclient.polkitGroup}") &&
            action.id.startsWith("org.freedesktop.resolve1.")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
