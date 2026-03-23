{
  plugins.aw-watcher = {
    enable = true;
    autoLoad = true;
    settings = {
      aw_server = {
        host = "127.0.0.1";
        port = 5600;
      };
    };
  };

  extraConfigLua = /* lua */ ''
    do
      local client = require("aw_watcher").__private.aw
      client.__post = function(self, url, data)
        local body = vim.fn.json_encode(data)
        local args = { "-X", "POST", url, "-H", "Content-Type: application/json", "--data-raw", body }
        local handle
        handle = vim.loop.spawn("curl", { args = args, verbatim = false }, function(code)
          self.connected = code == 0
          if handle and not handle:is_closing() then handle:close() end
        end)
      end
    end
  '';
}
