{
  self,
  ...
}:
{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ev;
  description = "Unix-way broadcast event manager";
in {
  options.services.ev = {
    enable = mkEnableOption "Enable `ev` - ${description}"; 
  };
  config = mkIf cfg.enable {
    systemd.user.services.ev = {
      Unit.Description = description;
      Unit.After = [ "network.target" ];

      Install.WantedBy = [ "default.target" ];

      Service.Type = "exec";
      Service.MemorySwapMax = 0;
      Service.ExecStart = ''
        ${self.packages.${pkgs.system}.ev}/bin/ev serve
      '';
      Service.Restart = "always";
    };
  };
}
