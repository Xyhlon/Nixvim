{...}: let
  get_bufnrs.__raw =
    #Lua
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
in {
  plugins = {
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
            name = "lazydev";
            priority = 1100;
            option = {
              inherit get_bufnrs;
            };
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
        window = {
          completion.__raw =
            #Lua
            ''cmp.config.window.bordered()'';
          documentation.__raw =
            #Lua
            ''cmp.config.window.bordered()'';
        };
        snippet = {
          expand =
            #Lua
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
    cmp-nvim-lsp.enable = true;
    cmp-nvim-lua.enable = true;
    cmp-rg.enable = true;
    cmp-buffer.enable = true;
    cmp-path.enable = true;
    cmp_luasnip.enable = true;
    cmp-cmdline.enable = true;
    luasnip.enable = true;
    friendly-snippets.enable = true;
    # ai completion
    copilot-cmp.enable = true;
    copilot-chat.enable = true;
    # windsurf-nvim.enable = true;
  };
}
