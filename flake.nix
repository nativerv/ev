{
  description = "Little daemon that runs piped commands";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    forAllSystems = nixpkgs.lib.genAttrs systems;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in {
    # homeManagerModules = {
    #   default = self.homeManagerModules.ev;
    #   ev = import ./home-manager/modules/services/ev.nix { inherit self; };
    # };
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib;
    in {
      default = self.packages.${system}.ev;
      ev = pkgs.stdenv.mkDerivation {
        name = "ev";
        pname = "ev";
        src = ./.;

        nativeBuildInputs = with pkgs; [ makeWrapper ];

        installPhase = ''
          mkdir -p $out/bin
          install -t $out/bin -m 755 ev
        '';

        postFixup = with pkgs; ''
          for bin in $out/bin/*; do
            wrapProgram $bin \
              --suffix PATH : ${lib.makeBinPath [
                coreutils
                nmap
                socat
              ]}
          done
        '';
      };
    });
  };
}
