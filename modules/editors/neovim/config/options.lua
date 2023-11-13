-- NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
-- the purpose is allow the rebinding of keys with a leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Disable highlighting on search
vim.o.hlsearch = false
-- Make line numbers default
vim.wo.number = true
-- Set the line numbers above and below to be relative
vim.wo.relativenumber = true
-- Enable mouse mode
vim.o.mouse = 'a'
-- Sync clipboard between OS and Neovim.
vim.o.clipboard = 'unnamedplus'
-- Enable break indent
vim.o.breakindent = true
-- Save undo history
vim.o.undofile = true
vim.opt.undodir = vim.fn.expand('~/.vim/undo')
-- enable ignore case on search
vim.o.ignorecase = true
-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'
-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300
-- Set completeopt to have a better completion experience
-- menuone shows a menu even if there is only one completion
-- noselect gives ability to select completions other than first
vim.o.completeopt = 'menuone,noselect'
-- enable terminal colors for better colors
vim.o.termguicolors = true
-- set the tab width
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
-- enable expandtab (tabs to spaces)
vim.opt.expandtab = true -- will require workaround for Makefiles