{pkgs, ...}: {
  plugins = {
    dap = {
      enable = true;
    };
    dap-ui.enable = true;
    dap-virtual-text.enable = true;
    dap-python.enable = true;
    dap-lldb.enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    nvim-gdb
    one-small-step-for-vimkind
  ];

  extraConfigLua =
    /*
    lua
    */
    ''
              local dap, dapui = require("dap"), require("dapui")
              dap.listeners.before.attach.dapui_config = function()
              	dapui.open()
              end
              dap.listeners.before.launch.dapui_config = function()
              	dapui.open()
              end
              dap.listeners.before.event_terminated.dapui_config = function()
              	dapui.close()
              end
              dap.listeners.before.event_exited.dapui_config = function()
              	dapui.close()
              end

             local dap = require('dap')
             dap.set_log_level('DEBUG')

             dap.adapters.lldb = {
                 type = 'executable',
                 command = '${pkgs.lldb_20}/bin/lldb-vscode', -- adjust as needed, must be absolute path
                 name = 'lldb'
             }

             local dap = require("dap")
             dap.adapters.gdb = {
                 type = "executable",
                 command = "gdb",
                 args = { "-i", "dap" }
             }

             local dap = require("dap")
             dap.configurations.c = {
           	{
           		name = "Launch",
           		type = "gdb",
           		request = "launch",
           		program = function()
           			return vim.fn.input('Path of the executable: ', vim.fn.getcwd() .. '/', 'file')
           		end,
           		cwd = "''${workspaceFolder}",
           	},
             }

             local dap = require('dap')
             dap.configurations.rust = {
           	{
           		name = 'Launch',
           		type = 'lldb',
           		request = 'launch',
           		program = function()
           			return vim.fn.input('Path of the executable: ', vim.fn.getcwd() .. '/', 'file')
           		end,
           		cwd = "''${workspaceFolder}",
           		stopOnEntry = false,
           		args = {},
           	},
           }
           dap.configurations.lua = {
      {
        type = 'nlua',
        request = 'attach',
        name = "Attach to running Neovim instance",
      }
           }

           dap.adapters.nlua = function(callback, config)
      callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 8086 })
           end


           dap.configurations.zig = {
           	{
           		name = 'Launch',
           		type = 'lldb',
           		request = 'launch',
           		program = function()
           			return vim.fn.input('Root path of executable: ', vim.fn.getcwd() .. '/', 'file')
                   end,
           		cwd = "''${workspaceFolder}",
           		stopOnEntry = false,
           		args = {},
           	},
           }
    '';
}
