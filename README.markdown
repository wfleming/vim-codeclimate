# vim-codeclimate

[![Code Climate](https://codeclimate.com/github/wfleming/vim-codeclimate/badges/gpa.svg)](https://codeclimate.com/github/wfleming/vim-codeclimate)

A vim plugin that runs the [Code Climate CLI][cli] & displays the results in vim.

![Demo gif](https://github.com/wfleming/vim-codeclimate/wiki/images/demo.gif)

## Requirements

The [Code Climate CLI][cli] must be installed and the `codeclimate` binary must be in your `PATH`.

## Installation

### Pathogen

```
$ git clone https://github.com/wfleming/vim-codeclimate ~/.vim/bundle/vim-codeclimate.com
```

### Vundle

```
Plugin 'wfleming/vim-codeclimate'
```

## Usage

```
:CodeClimateAnalyzeProject
:CodeClimateAnalyzeOpenFiles
:CodeClimateAnalyzeCurrentFile
```

The plugin exposes the three commands above.
By default, no shortcuts are bound to these commands to avoid interfering with other plugins, but you can easily add some in your `.vimrc` or `init.vim`:

```
nmap <Leader>aa :CodeClimateAnalyzeProject<CR>
nmap <Leader>ao :CodeClimateAnalyzeOpenFiles<CR>
nmap <Leader>af :CodeClimateAnalyzeCurrentFile<CR>
```

### Variables

`CodeClimateAnalyzeOpenFiles` & `CodeClimateAnalyzeCurrentFile` will both look for buffer-level `b:codeclimateflags` variables in the buffers they'll analyze, and include those in the invocation of the Code Climate CLI.

For example, in a large web project you're likely to have many different engines enabled (to cover your backend, styles, front-end, etc.), but for any given file you're editing most of those engines are probably not applicable.
By using `autocmd`, you can declare which engines you want run for specific filetypes, which can help analysis run noticeably faster. As a concrete example, I use the following configuration for a Ruby on Rails project:

```
autocmd FileType javascript let b:codeclimateflags="--engine eslint"
autocmd FileType ruby let b:codeclimateflags="--engine rubocop"
autocmd FileType scss let b:codeclimateflags="--engine scss-lint"
```

### Keyboard Shortcuts

Keyboard Shortcuts are available in the quickfix window, borrowed from the [ack.vim][ackvim] plugin.

```
?    a quick summary of these keys, repeat to close
o    to open (same as Enter)
O    to open and close the quickfix window
go   to preview file, open but maintain focus on results
t    to open in new tab
T    to open in new tab without moving to it
h    to open in horizontal split
H    to open in horizontal split, keeping focus on the results
v    to open in vertical split
gv   to open in vertical split, keeping focus on the results
q    to close the quickfix window
```

### Limitations

Because of how the CLI is run by the plugin, it expects to find the `.codeclimate.yml` configuration file in the current working directory.
So you'll generally need to start vim from the root of your repository for this plugin to work properly.

[cli]: https://github.com/codeclimate/codeclimate
[ackvim]: https://github.com/mileszs/ack.vim
