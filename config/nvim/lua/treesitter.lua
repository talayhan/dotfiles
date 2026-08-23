require('nvim-treesitter').setup {}

-- markdown_inline isn't a filetype on its own; it's pulled in via markdown's
-- injections, but still needs to be installed explicitly on this branch.
local parsers = { 'c', 'cpp', 'python', 'rust', 'zig', 'markdown', 'markdown_inline', 'lua' }
require('nvim-treesitter').install(parsers)

local highlight_filetypes = { 'c', 'cpp', 'python', 'rust', 'zig', 'markdown' }

vim.api.nvim_create_autocmd('FileType', {
    pattern = highlight_filetypes,
    callback = function(args)
        vim.treesitter.start(args.buf)
    end,
})

require('nvim-treesitter-textobjects').setup {
    select = {
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
    },
    move = {
        set_jumps = true, -- whether to set jumps in the jumplist
    },
}

local select = require 'nvim-treesitter-textobjects.select'
local move = require 'nvim-treesitter-textobjects.move'
local swap = require 'nvim-treesitter-textobjects.swap'

local function select_keymap(keys, capture)
    vim.keymap.set({ 'x', 'o' }, keys, function()
        select.select_textobject(capture, 'textobjects')
    end)
end

-- You can use the capture groups defined in textobjects.scm
select_keymap('af', '@function.outer')
select_keymap('if', '@function.inner')
select_keymap('ac', '@class.outer')
select_keymap('ic', '@class.inner')

local function move_keymap(keys, fn, capture)
    vim.keymap.set({ 'n', 'x', 'o' }, keys, function()
        fn(capture, 'textobjects')
    end)
end

move_keymap(']m', move.goto_next_start, '@function.outer')
move_keymap(']M', move.goto_next_end, '@function.outer')
move_keymap('[m', move.goto_previous_start, '@function.outer')
move_keymap('[M', move.goto_previous_end, '@function.outer')

vim.keymap.set('n', '<leader>a', function()
    swap.swap_next '@parameter.inner'
end)
vim.keymap.set('n', '<leader>A', function()
    swap.swap_previous '@parameter.inner'
end)
