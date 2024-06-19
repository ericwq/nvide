FROM alpine:3.20
LABEL maintainer="ericwq057@qq.com"
LABEL build_date="2024-06-19"

# 1. go and docs
# 2. LazyVim starter depends
# 3. lazy.nvim depends
RUN apk add -U icu-data-full docs go \
	git lazygit neovim ripgrep alpine-sdk \
	curl wget fzf fd tree-sitter-cli nodejs bash npm py3-pip py3-pynvim py3-wheel gzip unzip

RUN npm install -g neovim
RUN git clone https://github.com/LazyVim/starter ~/.config/nvim

# https://github.com/LazyVim/LazyVim/discussions/2862 transparent
# run :LazyHealth after installation.
RUN nvim --headless "+Lazy! sync" -c "MasonInstall stylua shfmt" -c qall

CMD ["/bin/ash"]
