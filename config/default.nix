{self, pkgs, ...}: 
let
  get_bufnrs.__raw = #Lua
  ''
    function()
      local buf_size_limit = 1024 * 1024 -- 1MB size limit
      local bufs = vim.api.nvim_list_bufs()
      local valid_bufs = {}
      for _, buf in ipairs(bufs) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) < buf_size_limit then
          table.insert(valid_bufs, buf)
        end
      end
      return valid_bufs
    end
  '';
in
{
  # Import all your configuration modules here
  imports = [ ./bufferline.nix ];
  plugins = {
    lualine.enable = true;
    lsp = {
      enable = true;
      servers = {
        lua_ls.enable = true;
        nil_ls.enable = true;
        # rnix_ls.enable = true;
        rust-analyzer.enable = true;
        ruff.enable = true;
        clangd.enable = true;
        typst_lsp.enable = true;
      };
    };
    cmp = {
      enable = true;
      settings = {
        autoEnableSources = true;
        sources = [
          {
            name = "nvim_lsp";
            priority = 1000;
            option = {
              inherit get_bufnrs;
            };
          }
          {
            name = "nvim_lsp_signature_help";
            priority = 1000;
            option = {
              inherit get_bufnrs;
            };
          }
          {
            name = "nvim_lsp_document_symbol";
            priority = 1000;
            option = {
              inherit get_bufnrs;
            };
          }
          { 
            name = "copilot";
            priority = 900;
          }
          {
            name = "treesitter";
            priority = 850;
            option = {
              inherit get_bufnrs;
            };
          }
          {
            name = "luasnip";
            priority = 750;
          }
          {
            name = "codeium";
            priority = 600;
          }
          {
            name = "buffer";
            priority = 500;
            option = {
              inherit get_bufnrs;
            };
          }
          {
            name = "path";
            priority = 300;
          }
          {
            name = "emoji";
            priority = 100;
          }
        ];
        # window = {
        #   completion = {
        #     border = "solid";
        #   };
        #   documentation = {
        #     border = "solid";
        #   };

        # };
        window = {
          completion.__raw = #Lua
          ''cmp.config.window.bordered()'';
          documentation.__raw = #Lua
          ''cmp.config.window.bordered()'';
        };
        snippet = {
          expand = #Lua
          ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
        };
        mapping = {
          "<C-n>" = "cmp.mapping.select_next_item()";
          "<C-p>" = "cmp.mapping.select_prev_item()";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-e>" = "cmp.mapping.close()";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        };
      };
    };
    lspkind = {
      enable = true;
      symbolMap = {
        Copilot = "";
      };
      extraOptions = {
        maxwidth = 50;
        ellipsis_char = "...";
      };
    };
    lsp-format.enable = true;
    wilder.enable = true;
    wtf.enable = true;
    cmp-nvim-lsp = {
      enable = true;
    }; # lsp
    cmp-nvim-lua = {
      enable = true;
    }; # nvim lua
    cmp-rg = {
      enable = true;
    }; # ripgrep cmp
    cmp-buffer = {
      enable = true;
    };
    cmp-path = {
      enable = true;
    }; # file system paths
    cmp_luasnip = {
      enable = true;
    }; # snippets
    cmp-cmdline = {
      enable = true;
    }; # autocomplete for cmdline
    codeium-nvim.enable = true;
    friendly-snippets.enable = true;
    comment.enable = true;
    which-key.enable = true;
    nvim-tree.enable = true;
    luasnip.enable = true;
    treesitter.enable = true;
    telescope.enable = true;
    clangd-extensions.enable = true;
    lazygit.enable = true;
    plantuml-syntax.enable = true;
    copilot-lua = {
      enable = true;
      panel.enabled = false;
      suggestion.enabled = false;
    };
    copilot-cmp.enable = true;
    copilot-chat.enable = true;
    gitsigns.enable = true;
    gitblame.enable = true;
    lint = {
      enable = true;
      lintersByFt = {
        c = [ "cpplint" "sonarlint-language-server"];
        cpp = [ "cpplint" "sonarlint-language-server"];
        go = [ "golangci-lint" ];
        nix = [ "statix" ];
        lua = [ "selene" ];
        python = [ "ruff" ];
        haskell = [ "hlint" ];
        bash = [ "shellcheck" ];
      };
    };
    hop.enable = true;
    toggleterm.enable = true;
    lsp-status.enable = true;
  };

  opts = {
    number = true;
    relativenumber = true;
    shiftwidth = 2;
  };

  globals.mapleader = " ";

  keymaps = [
    {
      action  = ''<cmd>61ToggleTerm direction=float name="Terminal 1"<CR>'';
      key = "<M-1>";
      mode = ["n" "v" "t" "i"];
    }
    {
      action  = ''<cmd>62ToggleTerm direction=float name="Terminal 2"<CR>'';
      key = "<M-2>";
      mode = ["n" "v" "t" "i"];
    }
    {
      action  = ''<cmd>63ToggleTerm direction=float name="Terminal 3"<CR>'';
      key = "<M-3>";
      mode = ["n" "v" "t" "i"];
    }
    {
      action  = ''<cmd>64ToggleTerm direction=float name="Terminal 4"<CR>'';
      key = "<M-4>";
      mode = ["n" "v" "t" "i"];
    }
    {
      action  = ''<cmd>65ToggleTerm direction=float name="Terminal 5"<CR>'';
      key = "<M-5>";
      mode = ["n" "v" "t" "i"];
    }
    {
      action  = "<cmd>Telescope live_grep<CR>";
      key = "<leader>ft";
    }
    {
     action = "<cmd>NvimTreeToggle<CR>";
     key = "<leader>e";
    }
    {
     action = "<cmd>w<CR>";
     key = "<leader>w";
    }
    {
     action = "<cmd>q<CR>";
     key = "<leader>q";
    }
    {
      action  = "<cmd>Telescope man_pages<CR>";
      key = "<leader>sm";
    }
    {
      action  = "<cmd>Telescope buffers<CR>";
      key = "<leader>bf";
    }
    {
      action  = "<cmd>LazyGit<CR>";
      key = "<leader>gg";
    }
    {
      action  = "<cmd>GitBlameToggle<CR>";
      key = "<leader>gl";
    }
    {
      key = "f";
      action.__raw = #Lua
      ''
        function()
          require'hop'.hint_char1({
            direction = require'hop.hint'.HintDirection.AFTER_CURSOR,
            current_line_only = true
          })
        end
      '';
      options.remap = true;
    }
    {
      key = "F";
      action.__raw = #Lua
      ''
        function()
          require'hop'.hint_char1({
            direction = require'hop.hint'.HintDirection.BEFORE_CURSOR,
            current_line_only = true
          })
        end
      '';
      options.remap = true;
    }
    {
      key = "t";
      action.__raw = #Lua
      ''
        function()
          require'hop'.hint_char1({
            direction = require'hop.hint'.HintDirection.AFTER_CURSOR,
            current_line_only = true,
            hint_offset = -1
          })
        end
      '';
      options.remap = true;
    }
    {
      key = "T";
      action.__raw = #Lua
      ''
        function()
          require'hop'.hint_char1({
            direction = require'hop.hint'.HintDirection.BEFORE_CURSOR,
            current_line_only = true,
            hint_offset = 1
          })
        end
      '';
      options.remap = true;
    }
  ];

  extraPlugins = with pkgs.vimPlugins; [
    {
      plugin = lazydev-nvim;
    }
  ];

  colorschemes.gruvbox.enable = true;

  clipboard.providers.wl-copy.enable = true;
}
