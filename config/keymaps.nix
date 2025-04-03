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
  ];
}
