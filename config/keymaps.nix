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
      key = "<leader>si";
      mode = "n";
      action.__raw =
        #Lua
        ''
          function()
            local ok_builtin, builtin = pcall(require, "telescope.builtin")
            local ok_previewers, previewers = pcall(require, "telescope.previewers")
            local ok_conf, conf = pcall(require, "telescope.config")
            local ok_image, image_api = pcall(require, "image")

            if not ok_builtin then
              vim.notify("telescope.builtin could not be loaded", vim.log.levels.ERROR)
              return
            end

            if not ok_previewers then
              vim.notify("telescope.previewers could not be loaded", vim.log.levels.ERROR)
              return
            end

            if not ok_conf then
              vim.notify("telescope.config could not be loaded", vim.log.levels.ERROR)
              return
            end

            if not ok_image then
              vim.notify("image.nvim could not be loaded", vim.log.levels.ERROR)
              return
            end

            local uv = vim.uv or vim.loop

            local supported = {
              png = true,
              jpg = true,
              jpeg = true,
              gif = true,
              webp = true,
              avif = true,
              heic = true,
              bmp = true,
              svg = true,
            }

            local active_image = nil
            local generation = 0

            local function clear_image()
              if active_image then
                pcall(function()
                  active_image:clear()
                end)
                active_image = nil
              end
            end

            local function repo_root()
              local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
              if vim.v.shell_error == 0 and git_root and git_root ~= "" then
                return git_root
              end
              return uv.cwd()
            end

            local root = repo_root()

            local function is_image(filepath)
              local ext = filepath and filepath:match("%.([^%.]+)$")
              return ext and supported[ext:lower()] == true
            end

            local function normalize_path(filepath)
              if not filepath or filepath == "" then
                return nil
              end

              if not vim.startswith(filepath, "/") then
                filepath = root .. "/" .. filepath
              end

              return vim.fn.fnamemodify(filepath, ":p")
            end

            local function entry_path(entry)
              local path = entry.path or entry.filename or entry.value

              if type(path) == "table" then
                path = path.path or path.filename or path[1]
              end

              if type(path) ~= "string" then
                return nil
              end

              return normalize_path(path)
            end

            local function set_preview_lines(bufnr, lines)
              if not vim.api.nvim_buf_is_valid(bufnr) then
                return
              end

              pcall(vim.api.nvim_set_option_value, "modifiable", true, { buf = bufnr })
              pcall(vim.api.nvim_buf_set_lines, bufnr, 0, -1, false, lines)
              pcall(vim.api.nvim_set_option_value, "modifiable", false, { buf = bufnr })
            end

            local function render_image(filepath, bufnr, winid)
              generation = generation + 1
              local my_generation = generation

              clear_image()

              set_preview_lines(bufnr, {
                "",
                "  Loading image preview...",
                "",
                "  " .. filepath,
              })

              vim.defer_fn(function()
                if my_generation ~= generation then
                  return
                end

                if not vim.api.nvim_buf_is_valid(bufnr) then
                  return
                end

                if not winid or not vim.api.nvim_win_is_valid(winid) then
                  return
                end

                local width = math.max(vim.api.nvim_win_get_width(winid), 10)
                local height = math.max(vim.api.nvim_win_get_height(winid), 5)

                local padding = {}
                for _ = 1, height do
                  table.insert(padding, "")
                end
                set_preview_lines(bufnr, padding)

                local ok, img = pcall(image_api.from_file, filepath, {
                  id = "telescope-image-preview-" .. tostring(bufnr),
                  window = winid,
                  buffer = bufnr,
                  with_virtual_padding = true,

                  -- Start at the very top-left of the preview window.
                  x = 0,
                  y = 0,

                  -- Give image.nvim the full preview-window bounding box.
                  -- It will preserve aspect ratio, so one dimension should touch the edge.
                  width = width,
                  height = height,

                  -- Do not inherit your global 50% max-height limit here.
                  max_width_window_percentage = 100,
                  max_height_window_percentage = 100,
                })

                if ok and img then
                  img.ignore_global_max_size = true
                end

                if my_generation ~= generation then
                  if ok and img then
                    pcall(function()
                      img:clear()
                    end)
                  end
                  return
                end

                if not ok or not img then
                  set_preview_lines(bufnr, {
                    "",
                    "  image.nvim could not render this image:",
                    "",
                    "  " .. filepath,
                  })
                  return
                end

                active_image = img

                pcall(function()
                  active_image:render()
                end)
              end, 150)
            end

            local image_previewer = previewers.new_buffer_previewer({
              title = "Image Preview",

              define_preview = function(self, entry)
                local filepath = entry_path(entry)

                generation = generation + 1
                clear_image()

                if not filepath then
                  set_preview_lines(self.state.bufnr, { "No file selected." })
                  return
                end

                if is_image(filepath) then
                  render_image(filepath, self.state.bufnr, self.state.winid)
                  return
                end

                conf.values.buffer_previewer_maker(filepath, self.state.bufnr, {
                  bufname = self.state.bufname,
                  winid = self.state.winid,
                })
              end,

              teardown = function()
                generation = generation + 1
                clear_image()
              end,
            })

            builtin.find_files({
              cwd = root,
              prompt_title = "Images in repo",
              previewer = image_previewer,

              layout_config = {
                horizontal = {
                  preview_width = 0.75,
                },
              },

              find_command = {
                "${pkgs.fd}/bin/fd",
                ".",
                root,
                "--type", "f",
                "--hidden",
                "--no-ignore",
                "--follow",
                "--exclude", ".git",
                "--exclude", ".direnv",
                "--color", "never",
                "--extension", "png",
                "--extension", "jpg",
                "--extension", "jpeg",
                "--extension", "gif",
                "--extension", "webp",
                "--extension", "avif",
                "--extension", "heic",
                "--extension", "bmp",
                "--extension", "svg",
              },
            })
          end
        '';
      options = {
        silent = true;
        noremap = true;
        desc = "Telescope image files with image.nvim preview";
      };
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
