#!/bin/sh
set -euo pipefail

if [ "$EUID" -eq 0 ]; then
	echo "Script must be run as user"
	exit
fi

sudo pacman -S ocaml opam dune

# https://github.com/akabe/ocaml-jupyter/pull/199
opam init --auto-setup --compiler=4.14.2
eval $(opam env --switch=4.14.2)
opam install -y ocamlformat jupyter ocaml-lsp-server
code --install-extension ocamllabs.ocaml-platform

touch ~/.ocamlinit
grep topfind ~/.ocamlinit || echo '#use "topfind";;' >> ~/.ocamlinit  # For using '#require' directive
grep Topfind.log ~/.ocamlinit || echo 'Topfind.log:=ignore;;' >> ~/.ocamlinit  # Suppress logging of topfind (recommended but not necessary)
ocaml-jupyter-opam-genspec
jupyter kernelspec install --user --name "ocaml-jupyter-$(opam var switch)" "$(opam var share)/jupyter"
