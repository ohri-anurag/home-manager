{ pkgs }:
{
  enable = true;
  defaultEditor = true;
  extraLuaConfig = ''
    -- LSP keybindings
    vim.keymap.set("n", "<F12>", "<cmd>lua vim.lsp.buf.definition()<CR>")

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

    local function reload_current_file()
      -- Save the current cursor position
      local cursor_pos = vim.api.nvim_win_get_cursor(0)

      -- Save the current viewport (scroll position)
      local view = vim.fn.winsaveview()

      -- Reload the current file from disk
      vim.cmd("edit!")

      -- Get the total number of lines
      local num_lines = vim.fn.line("$")

      if cursor_pos[1] > num_lines then
        cursor_pos[1] = num_lines
      end

      -- Restore the cursor position
      vim.api.nvim_win_set_cursor(0, cursor_pos)

      -- Restore the viewport (scroll position)
      vim.fn.winrestview(view)
    end

    function create_format_on_save(file_regex, gen_command)
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = file_regex,
        callback = function(args)
          vim.system(gen_command(args.file), function(event)
            vim.schedule(function()
              reload_current_file()
            end)
          end)
        end,
      })
    end

    create_format_on_save("*.dhall", function(file)
      return { "dhall", "--unicode", "format", file }
    end)

    create_format_on_save("*.lua", function(file)
      return { "stylua", "--indent-type", "Spaces", "--indent-width", "2", file }
    end)

    create_format_on_save("*.nix", function(file)
      return { "nixfmt", file }
    end)

    -- Comment settings for Dhall
    vim.api.nvim_exec(
      [[
        autocmd FileType dhall setlocal commentstring=--\ %s
    ]],
      false
    )

    -- Source a local .nvimrc.lua file if it is present
    if vim.fn.filereadable(".nvimrc.lua") == 1 then
      vim.cmd("source .nvimrc.lua")
    end
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
      plugin = nvim-web-devicons; # Icons for telescope/fzf-lua
      type = "lua";
      config = ''
        require("nvim-web-devicons").setup({
          color_icons = true,
          default = true,
          strict = true,
        })
      '';
    }
    plenary-nvim # Telescope dependency
    {
      plugin = telescope-nvim; # Fuzzy finder, only used for Hoogle
      type = "lua";
      config = ''
        require("telescope").setup({
          defaults = {
            mappings = {
              i = {
                ["<Esc>"] = require("telescope.actions").close,
              },
            },
          },
        })
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local previewers = require("telescope.previewers")
        local putils = require("telescope.previewers.utils")

        local write_lines = function(bufnr, begin, lines)
          vim.api.nvim_buf_set_lines(bufnr, begin, -1, true, lines)
          return begin + #lines
        end

        local write_docs = function(bufnr, begin, docs)
          local ctr = begin
          ctr = write_lines(bufnr, ctr, { "{- Documentation:" })
          ctr = write_lines(bufnr, ctr, docs)
          ctr = write_lines(bufnr, ctr, { "-}" })
          return ctr
        end

        local function open_browser(url)
          vim.cmd(":silent !firefox " .. vim.fn.fnameescape(url))
        end

        local show_preview = function(self, entry, status)
          local lines
          local item = entry.value
          local docs = vim.split(item.docs, "\n")
          local counter
          local bufnr = self.state.bufnr
          if item.type == "package" then
            counter = write_lines(bufnr, 0, { item.item, "" })
            counter = write_docs(bufnr, counter, docs)
          elseif item.type == "module" then
            counter = write_lines(bufnr, 0, { "-- PACKAGE: " .. item.package.name, "", item.item .. " where", "" })
            counter = write_docs(bufnr, counter, docs)
          else
            counter =
              write_lines(bufnr, 0, { "-- PACKAGE: " .. item.package.name, "", "module " .. item.module.name .. " where", "" })
            counter = write_docs(bufnr, counter, docs)
            counter = write_lines(bufnr, counter, { "", item.item })
          end
          vim.api.nvim_set_option_value("wrap", true, { win = self.state.winid })
          vim.api.nvim_set_option_value("number", true, { win = self.state.winid })
          putils.highlighter(bufnr, "haskell")
        end

        local hoogle = function(opts)
          opts = opts or {}
          local function_name = opts.function_name or ""
          if function_name == "" then
            function_name = vim.fn.input("Hoogle search: ")
          end
          local on_exit = function(obj)
            local output = obj.stdout
            local items = vim.json.decode(output)
            vim.schedule(function()
              pickers
                .new(opts, {
                  prompt_title = "Hoogle Search: " .. function_name,
                  previewer = previewers.new_buffer_previewer({
                    define_preview = show_preview,
                  }),
                  finder = finders.new_table({
                    results = items,
                    entry_maker = function(entry)
                      return {
                        value = entry,
                        display = entry.module.name or entry.item,
                        ordinal = entry.module.name or entry.item,
                      }
                    end,
                  }),
                  sorter = conf.generic_sorter(opts),
                  attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                      actions.close(prompt_bufnr)
                    end)
                    map({ "i", "n" }, "<C-b>", function()
                      local entry = action_state.get_selected_entry()
                      open_browser(entry.value.url)
                      actions.close(prompt_bufnr)
                    end)
                    return true
                  end,
                })
                :find()
            end)
          end
          vim.system({ "hoogle", "search", "--json", function_name }, on_exit)
        end

        local function word_hoogle()
          local word = vim.fn.expand("<cword>")
          hoogle({ function_name = word })
        end
        vim.keymap.set("n", "<leader>fh", word_hoogle, {})
        vim.keymap.set("n", "<leader>lh", hoogle, {})
      '';
    }
    telescope-fzf-native-nvim # FZF integration for telescope
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
    # Library for autocompletion support
    {
      plugin = pkgs.vimUtils.buildVimPlugin {
        pname = "L9";
        version = "2025-04-27";
        src = pkgs.fetchFromGitHub {
          owner = "vim-scripts";
          repo = "L9";
          rev = "c822b05ee0886f9a9703227dc85a6d47612c4bf1";
          sha256 = "sha256-5cy7bfflLgv+1sG7ZPbSpmX2J/e+ZBomGWt0xVqC0rw=";
        };
        meta.homepage = "https://github.com/vim-scripts/L9";
        meta.hydraPlatforms = [ ];
      };
    }
    # Autocompletion support for Neovim
    {
      plugin = pkgs.vimUtils.buildVimPlugin {
        pname = "vim-autocomplpop";
        version = "2025-04-27";
        src = pkgs.fetchFromGitHub {
          owner = "othree";
          repo = "vim-autocomplpop";
          rev = "5ceb2dfd368b36af029fabaed1bef3c5c4306d34";
          sha256 = "sha256-7aVrA7bLodKuXruQJdVzc2v9CB8tInJWlcpG3B6XHo0=";
        };
        meta.homepage = "https://github.com/othree/vim-autocomplpop";
        meta.hydraPlatforms = [ ];
      };
    }
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
    copilot-vim # Copilot integration
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
