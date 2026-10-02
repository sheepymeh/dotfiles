VSCODE_EXTENSIONS=(
	Catppuccin.catppuccin-vsc
	Catppuccin.catppuccin-vsc-icons

	eamodio.gitlens
	github.vscode-github-actions

	bazelbuild.vscode-bazel
	ms-azuretools.vscode-docker

	davidanson.vscode-markdownlint
	james-yu.latex-workshop

	charliermarsh.ruff
	ms-python.python

	timonwong.shellcheck

	hudson-river-trading.vscode-slang
	mshr-h.veriloghdl
)
# consider also
# github.vscode-pull-request-github
# astral-sh.ty
# detachhead.basedpyright
# meta.pyrefly
# ms-python.mypy-type-checker
# zuban.zubanls
# ms-toolsai.jupyter
# dbaeumer.vscode-eslint
# esbenp.prettier-vscode
# Vue.volar

git_config() {
	git config --global user.name 'sheepymeh'
	git config --global user.email 'sheepymeh@users.noreply.github.com'
	git config --global credential.helper store
	git config --global pull.rebase false
	git config --global init.defaultBranch main
}


firefox_config() {
	mkdir -p "$1"
	cp ../firefox/policies.json "$1"
	firefox --window-size=1,1 --screenshot /dev/null about:blank
	FF_PROFILE="$(find "$HOME/$2" -maxdepth 1 -type d -name '*.default-release' -print -quit)"
	cp ../firefox/user.js "$FF_PROFILE/user.js"
}

vscode_config() {
	mkdir -p "$HOME/$1"
	cp ../code/* "$HOME/$1"
}

vscode_install_ext() {
	for ext in "${VSCODE_EXTENSIONS[@]}"; do
		"$1" --install-extension "$ext"
	done
}
