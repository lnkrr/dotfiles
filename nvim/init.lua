local o = vim.opt

o.number = true
o.relativenumber = true
o.ignorecase = true
o.hlsearch = true
o.incsearch = true
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.wrap = false
o.signcolumn = "no"
o.swapfile = false
o.scrolloff = 8
o.mouse = ""
o.winborder = "rounded"

vim.g.mapleader = " "

local set = vim.keymap.set

set({ "n", "v" }, "<leader>y", '"+y')
set({ "n", "v" }, "<leader>Y", '"+Y')
set({ "n", "v" }, "<leader>d", '"+d')
set({ "n", "v" }, "<leader>D", '"+D')
set({ "n", "v" }, "<leader>p", '"+p')
set({ "n", "v" }, "<leader>P", '"+P')

set("n", "x", '"_x')

set("v", "J", ":move '>+1<cr>gv=gv")
set("v", "K", ":move '<-2<cr>gv=gv")
set("n", "J", ":move +1<cr>==")
set("n", "K", ":move -2<cr>==")

set("n", "<leader>o", "o<esc>")
set("n", "<leader>O", "O<esc>")

set("n", "<cr>", ":nohlsearch<cr>")

set("n", "-", ":Oil<cr>")

set("n", "<leader>f", ":Telescope find_files<cr>")
set("n", "<leader>g", ":Telescope live_grep<cr>")

set("n", "<leader>h", vim.lsp.buf.hover)
set("n", "<leader>r", vim.lsp.buf.rename)

set("n", "<leader>n", function()
    vim.diagnostic.jump({ count = 1, float = true })
end)

set("n", "<leader>N", function()
    vim.diagnostic.jump({ count = -1, float = true })
end)

vim.pack.add({
    {
        src = "https://github.com/catppuccin/nvim",
        name = "catppuccin",
    },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/hrsh7th/nvim-cmp" },
    { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-lualine/lualine.nvim" },
    { src = "https://github.com/windwp/nvim-autopairs" },
    { src = "https://github.com/stevearc/oil.nvim" },
})

vim.cmd.colorscheme("catppuccin-mocha")

require("lualine").setup()
require("nvim-autopairs").setup()

require("nvim-treesitter.configs").setup({
    ensure_installed = { "cpp", "lua", "python", "gitcommit" },
    highlight = { enable = true },
})

local cmp = require("cmp")

cmp.setup({
    sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
    },
    mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping.confirm({ select = true }),
    }),
})

vim.diagnostic.config({ update_in_insert = true })

vim.lsp.enable({ "clangd", "lua_ls", "pyright" })

vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buffer,
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

-- https://github.com/stevearc/oil.nvim/blob/master/doc/recipes.md#hide-gitignored-files-and-show-git-tracked-hidden-files

local function parse_output(proc)
    local result = proc:wait()
    local ret = {}
    if result.code == 0 then
        for line in
            vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true })
        do
            line = line:gsub("/$", "")
            ret[line] = true
        end
    end
    return ret
end

local function new_git_status()
    return setmetatable({}, {
        __index = function(self, key)
            local ignore_proc = vim.system({
                "git",
                "ls-files",
                "--ignored",
                "--exclude-standard",
                "--others",
                "--directory",
            }, {
                cwd = key,
                text = true,
            })
            local tracked_proc = vim.system(
                { "git", "ls-tree", "HEAD", "--name-only" },
                {
                    cwd = key,
                    text = true,
                }
            )
            local ret = {
                ignored = parse_output(ignore_proc),
                tracked = parse_output(tracked_proc),
            }

            rawset(self, key, ret)
            return ret
        end,
    })
end
local git_status = new_git_status()

local refresh = require("oil.actions").refresh
local orig_refresh = refresh.callback
refresh.callback = function(...)
    git_status = new_git_status()
    orig_refresh(...)
end

require("oil").setup({
    view_options = {
        is_hidden_file = function(name, bufnr)
            local dir = require("oil").get_current_dir(bufnr)
            local is_dotfile = vim.startswith(name, ".") and name ~= ".."
            if not dir then
                return is_dotfile
            end
            if is_dotfile then
                return not git_status[dir].tracked[name]
            else
                return git_status[dir].ignored[name]
            end
        end,
    },
})
