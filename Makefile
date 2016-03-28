.PHONY: test citest vim_info

test:
	bundle exec vim-flavor test

vim_info:
	vim --version

citest: vim_info test
