{ pkgs, nix-vscode-extensions, ... }:

let
  vscode-with-extensions = pkgs.vscode-with-extensions.override
  {
    vscodeExtensions = with pkgs.nix-vscode-extensions.vscode-marketplace-release;
    [
      # Nix support.
      bbenoist.nix

      # Latex support.
      james-yu.latex-workshop

      # Haskell support.
      haskell.language-haskell
      haskell.haskell

      rocq-prover.vsrocq
      ms-vscode.wasm-wasi-core
      ejgallego.coq-lsp
      jetbrains-research.coqpilot

      # Preview of .dot Graphviz diagrams.
      efanzh.graphviz-preview

      meraymond.idris-vscode
      leanprover.lean4
      ivan-m.twelf-extension-pack

      # Unison support. Installation of Unison itself: https://github.com/ceedubs/unison-nix/
      unison-lang.unison

      # Athena support. Installation of Athena from source:
      # https://github.com/AthenaFoundation/athena/wiki/Building-Athena
      athenafoundation.athena-language
    ];
  };
in
{
  # Allow proprietary packages like vscode.
  nixpkgs =
  {
    config.allowUnfree = true;

    overlays =
    [
      nix-vscode-extensions.overlays.default
    ];
  };

  environment.systemPackages = with pkgs;
  [
    vscode-with-extensions
  ];
}
