{
  description = "Standard ML convenience wrapper around posix subprocesses, modeled after the python module";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nix-github-actions.url = "github:nix-community/nix-github-actions";
  inputs.nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      self,
      nixpkgs,
      nix-github-actions,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "sml-subprocess";
        version = "0.1.0";
        src = ./.;

        dontBuild = true;
        dontInstall = true;
      };

      checks.${system}.tests = pkgs.stdenv.mkDerivation {
        pname = "sml-subprocess-tests";
        version = "0.1.0";
        src = ./.;

        nativeBuildInputs = with pkgs; [
          mlton
          unzip
          smlpkg
        ];

        buildPhase = ''
          runHook preBuild
          mlton -output test-runner lib/github.com/gattschardo/sml-subprocess/test/test.mlb
          runHook postBuild
        '';

        doCheck = true;
        checkPhase = ''
          runHook preCheck
          ./test-runner
          runHook postCheck
        '';

        installPhase = ''
          mkdir -p $out
          echo "ok" > $out/result
        '';
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt
          mlton
          smlfmt
          unzip
          smlpkg
        ];
      };

      formatter.${system} = pkgs.treefmt;

      githubActions = nix-github-actions.lib.mkGithubMatrix { inherit (self) checks; };
    };
}
