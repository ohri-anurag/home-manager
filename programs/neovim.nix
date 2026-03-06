{ pkgs }:
{
  enable = true;
  defaultEditor = true;
  extraLuaConfig = ''
    -- LSP keybindings
    vim.keymap.set("n", "<F12>", "<cmd>lua vim.lsp.buf.definition()<CR>")
    vim.keymap.set("n", "<C-t>", "<cmd>lua vim.lsp.buf.references()<CR>")
    vim.opt.completeopt={"menuone","popup","noinsert"}

    -- LSP Setup
    vim.lsp.config("typescript", {
      cmd = { "npx", "typescript-language-server", "--stdio" },
      filetypes = { "typescript", "javascript" },
      root_markers = { ".git" },
    })
    vim.lsp.config("dhall", {
      cmd = { "dhall-lsp-server" },
      filetypes = { "dhall" },
      root_markers = { ".git" },
    })
    vim.lsp.config("nix", {
      cmd = { "nil" },
      filetypes = { "nix" },
      root_markers = { ".git" },
    })
    vim.lsp.config("elm", {
      cmd = { "elm-language-server" },
      filetypes = { "elm" },
      root_markers = { ".git" },
    })
    vim.lsp.config("ruby", {
      cmd = {
        "bash",
        "-c",
        "$(bundle info --path sorbet-static)/libexec/sorbet tc --lsp --enable-all-beta-lsp-features --disable-watchman",
      },
      filetypes = { "ruby" },
      root_markers = { ".git" },
    })
    vim.lsp.enable("dhall")
    vim.lsp.enable("elm")
    vim.lsp.enable("nix")
    vim.lsp.enable("ruby")
    vim.lsp.enable("typescript")

    -- Enable LSP diagnostics
    vim.diagnostic.config({
      virtual_text = true, -- Enable virtual text at end of line
      signs = true, -- Show signs in the sign column
      underline = true, -- Underline text with issues
      update_in_insert = false, -- Only update diagnostics after leaving insert mode
      severity_sort = true, -- Sort diagnostics by severity
      float = { -- Configure the floating window
        source = "always", -- Always show source of the diagnostic
        border = "rounded", -- Add a rounded border
        header = "", -- No header
        prefix = "", -- No prefix
      },
    })

    -- Setup keybindings for copying current filepath relative to VIM's cwd
    vim.api.nvim_set_keymap("n", "<F2>", ':let @" = expand("%")<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<F3>", ':let @+ = expand("%")<CR>', { noremap = true, silent = true })

    -- Vim Window navigation keybindings
    vim.keymap.set("n", "<C-h>", "<Cmd>wincmd h<CR>")
    vim.keymap.set("n", "<C-j>", "<Cmd>wincmd j<CR>")
    vim.keymap.set("n", "<C-k>", "<Cmd>wincmd k<CR>")
    vim.keymap.set("n", "<C-l>", "<Cmd>wincmd l<CR>")

    -- Set the leader key
    vim.g.mapleader = " " -- Here, the spacebar is set as the leader key

    -- Keybinding for clearing the search highlight
    vim.keymap.set("n", "<leader>;", "<Cmd>nohlsearch<CR>")

    -- Keybinding to select till the end of line
    vim.keymap.set("n", "<S-v>", "v$h")

    -- Keybinding to select entire line
    vim.keymap.set("n", "vv", "<S-v>")

    -- Enable line numbers
    vim.o.number = true

    -- Enable the display of whitespace characters
    vim.o.list = true

    -- Customize the symbols for spaces, tabs, etc.
    vim.o.listchars = "space:·,tab:→ ,eol:↲"

    -- The width of an actual tab character.
    vim.o.tabstop = 2

    -- Use value of 'tabstop' for all indenting operations.
    vim.o.shiftwidth = vim.o.tabstop

    -- Disable combining tabs and spaces to achieve an indent.
    vim.o.softtabstop = 0

    -- Indenting, unindenting, and pressing tab in insert-mode all use spaces
    -- instead of tabs.
    vim.o.expandtab = true

    -- Beginning-of-line tab (backspace) behaves like indent (unindent).
    vim.o.smarttab = true

    -- Round indent to nearest shiftwidth multiple.
    vim.o.shiftround = true

    -- Case-insensitive search.
    vim.o.ignorecase = false

    -- ...unless the search phrase contains a capital.
    vim.o.smartcase = false

    -- To enable syntax based closing/folding of code
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt.foldlevelstart = 99

    -- To see the cursor more clearly
    vim.o.cursorline = true
    vim.o.cursorcolumn = true

    -- Comment settings for Dhall
    vim.api.nvim_exec(
      [[
        autocmd FileType dhall setlocal commentstring=--\ %s
    ]],
      false
    )
  '';
  plugins = with pkgs.vimPlugins; [
    {
      plugin = lualine-nvim; # Status bar
      type = "lua";
      config = ''
        require("lualine").setup({
          sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff", "diagnostics" },
            lualine_c = { { "filename", path = 1 } },
            lualine_x = { { "searchcount", maxcount = 999999 }, "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" },
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { { "filename", path = 1 } },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {},
          },
        })
      '';
    }
    # Moonfly colorscheme
    {
      plugin = pkgs.vimUtils.buildVimPlugin {
        pname = "moonfly";
        version = "2025-04-27";
        src = pkgs.fetchFromGitHub {
          owner = "bluz71";
          repo = "vim-moonfly-colors";
          rev = "e356d55cedb24a6c4251d83ce28e0e2010e99d2f";
          sha256 = "sha256-dW/pswtVR0HEgbDZRynQH/83whK0YcKzc3J7lH26MVE=";
        };
        meta.homepage = "https://github.com/bluz71/vim-moonfly-colors/";
        meta.hydraPlatforms = [ ];
      };
      type = "lua";
      config = "vim.cmd('colorscheme moonfly')";
    }
    {
      plugin = conform-nvim; # Code formatter
      type = "lua";
      config = ''
        require("conform").setup({
          formatters = {
            syntax_tree = {
              args = { "write", "--plugins=plugin/single_quotes", "--print-width=100", "$FILENAME" },
              stdin = false,
            },
            dhall_format = {
              command = "dhall",
              args = {  "--unicode", "format", "$FILENAME" },
              stdin = false,
            }
          },
          formatters_by_ft = {
            lua = { "stylua" },
            ruby = { "syntax_tree" },
            typescript = { "prettier" },
            css = { "prettier" },
            json = { "prettier" },
            javascript = { "prettier" },
            markdown = { "prettier" },
            html = { "prettier" },
            elm = { "elm_format" },
            nix = { "nixfmt" },
            haskell = { "ormolu" },
            cabal = { "cabal_fmt" },
            dhall = { "dhall_format" },
          },
          format_on_save = {},
        })
      '';
    }
    {
      plugin = nvim-web-devicons; # Icons for fzf-lua
      type = "lua";
      config = ''
        require("nvim-web-devicons").setup({
          color_icons = true,
          default = true,
          strict = true,
        })
      '';
    }
    {
      plugin = fzf-lua; # FZF integration for Neovim
      type = "lua";
      config = ''
        local fzf = require("fzf-lua")
        local actions = require("fzf-lua").actions
        fzf.register_ui_select()
        fzf.setup({
          "telescope",
          fzf_opts = { ["--cycle"] = "" },
          grep = { RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH },
          buffers = {
            actions = {
              ["ctrl-d"] = false,
            },
            keymap = {
              builtin = {
                ["<C-d>"] = "preview-page-down",
                ["<C-u>"] = "preview-page-up",
              },
            },
          },
        })
        vim.keymap.set("n", "<leader>fg", fzf.grep_cword, {})
        vim.keymap.set("n", "<leader>lg", fzf.live_grep, {})
        vim.keymap.set("n", "<leader>ft", fzf.tags_grep_cword, {})
        vim.keymap.set("n", "<leader>lt", fzf.tags, {})
        vim.keymap.set("n", "<leader>ff", fzf.files, {})
        vim.keymap.set("n", "<leader>fb", fzf.buffers, {})
        vim.keymap.set("n", "<leader>c", fzf.git_commits, {})

      '';
    }
    nvim-treesitter-parsers.haskell
    nvim-treesitter-parsers.dhall
    {
      plugin = nvim-treesitter; # Syntax highlighting
      type = "lua";
      config = ''
        require("nvim-treesitter.configs").setup({
          highlight = {
            enable = true,
            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
          },
        })
      '';
    }
    # Auto completion of pairs
    auto-pairs
    {
      plugin = indent-blankline-nvim; # Indentation guides
      type = "lua";
      config = "require('ibl').setup()";
    }
    {
      plugin = yanky-nvim; # Yank history
      type = "lua";
      config = ''
        require("yanky").setup({ highlight = { timer = 200 } })
        vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
        vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
        vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
        vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")
      '';
    }
    {
      plugin = yazi-nvim; # Yazi integration for Neovim
      type = "lua";
      config = "vim.keymap.set('n', '<leader>cw', '<cmd> Yazi cwd <cr>', {})";
    }
    {
      plugin = todo-comments-nvim; # TODO comments
      type = "lua";
      config = "require('todo-comments').setup()";
    }
    {
      plugin = litee-nvim; # Dependency for gh.nvim
      type = "lua";
      config = "require('litee.lib').setup()";
    }
    {
      plugin = pkgs.vimUtils.buildVimPlugin {
        pname = "gh.nvim";
        version = "2025-04-27";
        buildInputs = [ litee-nvim ];
        src = pkgs.fetchFromGitHub {
          owner = "ldelossa";
          repo = "gh.nvim";
          rev = "ebbaac254ef7dd6f85b439825fbce82d0dc84515";
          sha256 = "sha256-5MWv/TpJSJfPY3y2dC1f2T/9sP4wn0kZ0Sed5OOFM5c=";
        };
        meta.homepage = "https://github.com/ldelossa/gh.nvim";
        meta.hydraPlatforms = [ ];
      };
      type = "lua";
      config = ''
        require('litee.gh').setup()
        vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#1C391C' })
        vim.api.nvim_set_hl(0, 'DiffText', { bg = '#12437F' })
      '';
    }
    linediff-vim # Line diffing
  ];
}
