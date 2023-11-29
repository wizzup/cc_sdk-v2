{
  description = "CodeCrafters's Course SDK v2";
  nixConfig.bash-prompt-suffix = "🔨";
  nixConfig.sandbox = "relaxed";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

  outputs = {
    self,
    nixpkgs,
  }: (
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {inherit system;};

      # need baseline cuz my CPU is old
      bun = pkgs.bun.overrideAttrs (prev: rec {
        version = "1.0.14";
        src = pkgs.fetchurl {
          url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64-baseline.zip";
          hash = "sha256-7vSYdYzhXdmw+s+HMPGOjVogIgnswu1jWdD3uQsPem8=";
        };
      });

      course-sdk = pkgs.stdenvNoCC.mkDerivation {
        pname = "course-sdk";
        version = "v2";
        src = ./.;
        nativeBuildInputs = [bun];
        dontPatch = true;
        dontConfigure = true;
        __noChroot = true;

        buildPhase = ''
          bun install --no-progress
          bun build ./cli.ts --compile --outfile ./course-sdk
        '';

        installPhase = ''
          mkdir -p $out/bin
          install ./course-sdk $out/bin
        '';
      };
    in {
      packages.${system} = {
        inherit course-sdk;

        default = course-sdk;
      };
      formatter.${system} = pkgs.alejandra;
    }
  );
}
