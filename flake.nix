{
  description = "Yet another RSS reader";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system:
          let
            pkgs = import nixpkgs { inherit system; };
          in
          f { inherit pkgs; }
        );

      version = "2.6";

      yarr =
        pkgs:
        pkgs.buildGoModule {
          pname = "yarr";
          inherit version;

          src = ./.;
          vendorHash = null;
          subPackages = [ "cmd/yarr" ];

          ldflags = [
            "-s"
            "-X main.Version=${version}"
            "-X main.GitHash=none"
          ];

          tags = [
            "sqlite_foreign_keys"
            "sqlite_json"
          ];
        };
    in
    {
      formatter = forSystems ({ pkgs }: pkgs.nixfmt-tree);

      packages = forSystems (
        { pkgs }:
        {
          default = yarr pkgs;
        }
      );

      devShells = forSystems (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              go
              gnumake
            ];
          };
        }
      );
    };
}
