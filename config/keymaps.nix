{pkgs, ...}: {
  keymaps = [
    {
      action = ''<cmd>61ToggleTerm direction=float name="Terminal 1"<CR>'';
      key = "<M-1>";
      mode = ["n" "v" "t" "i"];
    }
    {
      action = ''<cmd>62ToggleTerm direction=float name="Terminal 2"<CR>'';
      key = "<M-2>";
      mode = ["n" "v" "t" "i"];
    }
    {
      action = ''<cmd>63ToggleTerm direction=float name="Terminal 3"<CR>'';
      key = "<M-3>";
      mode = ["n" "v" "t" "i"];
    }
    {
      action = ''<cmd>64ToggleTerm direction=float name="Terminal 4"<CR>'';
      key = "<M-4>";
      mode = ["n" "v" "t" "i"];
    }
    {
      action = ''<cmd>65ToggleTerm direction=float name="Terminal 5"<CR>'';
      key = "<M-5>";
      mode = ["n" "v" "t" "i"];
    }
    {
      action = "<cmd>Telescope live_grep<CR>";
      key = "<leader>st";
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
      action = "<cmd>Telescope man_pages sections=ALL<CR>";
      key = "<leader>sm";
    }
    {
      action = "<cmd>Telescope help_tags<CR>";
      key = "<leader>sh";
    }
    {
      action = "<cmd>Telescope buffers<CR>";
      key = "<leader>bf";
    }
    {
      action = "<cmd>LazyGit<CR>";
      key = "<leader>gg";
    }
    {
      action = "<cmd>GitBlameToggle<CR>";
      key = "<leader>gl";
    }
    {
      key = "<leader>fp";
      action.__raw =
        #Lua
        ''
          function()
            require'plaintext_fmt'.format_plaintext_nodes()
          end
        '';
    }
    {
      key = "f";
      action.__raw =
        #Lua
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
      action.__raw =
        #Lua
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
      action.__raw =
        #Lua
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
      action.__raw =
        #Lua
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
    # DAP Debugging
    {
      key = "<leader>b";
      mode = "n";
      action = ":lua require'dap'.toggle_breakpoint()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Toggle DAP [b]reakpoint";
      };
    }
    {
      key = "<leader>B";
      mode = "n";
      action = ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Set DAP [B]reakpoint";
      };
    }
    {
      key = "<leader>dtg";
      mode = "n";
      action = ":lua require'dap-go'.debug_test()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "DAP [d]ebug [t]est for (g)o";
      };
    }
    {
      key = "<leader>de";
      mode = "n";
      action = ":lua require'dap'.repl.open()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "[d]ap r[e]pl open";
      };
    }
    {
      key = "<leader>lp";
      mode = "n";
      action = ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "[l]og DAP [p]oint message";
      };
    }
    {
      key = "<F5>";
      mode = "n";
      action = ":lua require'dap'.continue()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Continue DAP debug";
      };
    }
    {
      key = "<F10>";
      mode = "n";
      action = ":lua require'dap'.step_over()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Step over DAP debug";
      };
    }
    {
      key = "<F11>";
      mode = "n";
      action = ":lua require'dap'.step_into()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Step into DAP debug";
      };
    }
    {
      key = "<F12>";
      mode = "n";
      action = ":lua require'dap'.step_out()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Stepout of DAP debug";
      };
    }
  ];
}
