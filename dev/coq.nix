{ pkgs ? import <nixpkgs> {} }:

let
  mkCoqBuild = { coq, stdlib }: { name, src }:

    pkgs.stdenv.mkDerivation
    {
      inherit name src;

      enableParallelBuilding = true;

      buildInputs =
      [
        coq
        stdlib
      ];

      buildPhase =
      ''
        patchShebangs build.sh
        ./build.sh
      '';

      installPhase =
      ''
        INSTALLPATH=$out/lib/coq/${coq.coq-version}/user-contrib/${name}

        mkdir -p $INSTALLPATH
        cp -r src/* $INSTALLPATH/

        find $INSTALLPATH \
          -name "*.vos" -o \
          -name "*.vok" -o \
          -name ".*.aux" |
          xargs rm -f
      '';
    };

  mkCoqShell = packages: { header, description }:
    pkgs.mkShell
    {
      inherit packages;

      shellHook =
      ''
        GREEN="\033[1;32m"
        RESET="\033[0m"

        export PROJECT_ROOT=$(pwd)
        export PS1="\n\[''${GREEN}\]${header}\''${PWD#\''$PROJECT_ROOT}>\[''${RESET}\] "

        echo ""
        echo -e "${description}"
        echo ""
        echo -e "''${GREEN}nix build''${RESET}    — Build and install (requires Nix flakes)"
        echo -e "''${GREEN}nix develop''${RESET}  — Enter a Nix dev shell (requires Nix flakes)"
        echo -e "''${GREEN}nix-shell''${RESET}    — Enter a legacy Nix dev shell"
        echo -e "''${GREEN}./build.sh''${RESET}   — Regenerate the makefile, then build"
        echo -e "''${GREEN}make''${RESET}         — Build"
        echo -e "''${GREEN}make clean''${RESET}   — Clean build artifacts"
        echo -e "''${GREEN}coqide''${RESET}       — Start CoqIDE"
      '';
    };

in
{
  coq820.build = mkCoqBuild
  {
    coq = pkgs.coq_8_20;
    stdlib = pkgs.coqPackages_8_20.stdlib;
  };

  coq820.shell = mkCoqShell
  [
    pkgs.coq_8_20
    pkgs.coqPackages_8_20.stdlib
  ];

  coq91.build = mkCoqBuild
  {
    coq = pkgs.coq_9_1;
    stdlib = pkgs.rocqPackages_9_1.stdlib;
  };

  coq91.shell =
    let
      # Coq with CoqIDE.
      coq-with-ide = pkgs.coq_9_1.override { buildIde = true; };

        # Make "coqide" an alias for "rocqide".
      coqide-alias = pkgs.writeShellScriptBin "coqide"
      ''
        exec ${coq-with-ide}/bin/rocqide "$@"
      '';
    in
      mkCoqShell
      [
          coq-with-ide
          coqide-alias
          pkgs.rocqPackages_9_1.stdlib
      ];
}
