{
  pkgs ? (import <nixpkgs> {}),
  ruby ? pkgs.ruby_2_6,
  bundler ? (pkgs.bundler.override { inherit ruby; }),
  nix ? pkgs.nix,
  nix-shopify-prefetchers ? pkgs.nix-shopify-prefetchers
}:
pkgs.stdenv.mkDerivation rec {
  version = "2.5.0";
  name = "bundix";
  src = ./.;
  phases = "installPhase";
  installPhase = ''
    mkdir -p $out
    makeWrapper $src/bin/bundix $out/bin/bundix \
      --prefix PATH : "${nix.out}/bin" \
      --prefix PATH : "${nix-shopify-prefetchers.out}/bin" \
      --prefix PATH : "${bundler.out}/bin" \
      --set GEM_PATH "${bundler}/${bundler.ruby.gemPath}"
  '';

  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [ ruby bundler ];

  meta = {
    inherit version;
    description = "Creates Nix packages from Gemfiles";
    longDescription = ''
      This is a tool that converts Gemfile.lock files to nix expressions.

      The output is then usable by the bundlerEnv derivation to list all the
      dependencies of a ruby package.
    '';
    homepage = "https://github.com/manveru/bundix";
    license = "MIT";
    maintainers = with pkgs.lib.maintainers; [ manveru zimbatm ];
    platforms = pkgs.lib.platforms.all;
  };
}
