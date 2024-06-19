FROM alpine:3.20
LABEL maintainer="ericwq057@qq.com"


## prepare for lazy.nvim
RUN apk add -U build-base git neovim go npm \
	curl wget ripgrep fzf fd tree-sitter-cli nodejs bash icu-data-full \
	lazygit py3-pip py3-pynvim py3-wheel && \
	npm install -g neovim

RUN git clone https://github.com/LazyVim/starter ~/.config/nvim
RUN	nvim --headless "+Lazy! sync" -c "MasonInstall stylua shfmt" -c qall

RUN apk add -U gzip unzip docs clang-dev

# run :LazyHealth after installation.
#nvim --headless "+MasonUpdate sync" +qa
CMD ["/bin/ash"]
