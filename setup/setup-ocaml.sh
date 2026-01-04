#!/bin/sh
set -euo pipefail

if [ "$EUID" -eq 0 ]; then
	echo "Script must be run as user"
	exit
fi

sudo pacman -S ocaml opam dune

opam init --auto-setup
eval $(opam env --switch=default)
opam install -y ocamlformat jupyter ocaml-lsp-server
code --install-extension ocamllabs.ocaml-platform

touch ~/.ocamlinit
grep -q topfind ~/.ocamlinit || echo '#use "topfind";;' >> ~/.ocamlinit  # For using '#require' directive
grep -q Topfind.log ~/.ocamlinit || echo 'Topfind.log:=ignore;;' >> ~/.ocamlinit  # Suppress logging of topfind (recommended but not necessary)
ocaml-jupyter-opam-genspec
jupyter kernelspec install --user --name "ocaml-jupyter-$(opam var switch)" "$(opam var share)/jupyter"
