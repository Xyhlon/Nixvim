{pkgs, ...}: {
  # Import all your configuration modules here
  imports = [
    ./keymaps.nix
    ./debug.nix
    ./lsp.nix
    ./bufferline.nix
    ./completion.nix
    ./lint.nix
    ./plaintext_format.nix
    ./aw-watcher
  ];
  dependencies.lean = {
    enable = true;
    package = pkgs.elan;
  };
  plugins = {
    lean = {
      enable = true;
      # package = pkgs.vimPlugins.lean-nvim;
    };
    lualine.enable = true;
    wilder.enable = true;
    wtf.enable = true;
    comment.enable = true;
    image.enable = true;
    which-key.enable = true;
    nvim-tree = {
      enable = true;
      settings = {
        git = {
          enable = true;
          ignore = false;
        };
      };
    };
    treesitter.enable = true;
    telescope = {
      enable = true;
      extensions.live-grep-args.enable = true;
    };
    lazygit.enable = true;
    plantuml-syntax.enable = true;
    copilot-lua = {
      enable = true;
      settings.panel.enabled = false;
      settings.suggestion.enabled = false;
    };
    gitsigns.enable = true;
    gitblame.enable = true;
    hop.enable = true;
    toggleterm.enable = true;
    lazydev.enable = true;
  };

  opts = {
    number = true;
    relativenumber = true;
    shiftwidth = 2;
  };

  filetype.extension = {
    sage = "python";
    pyx = "python";
    spyx = "python";
    py = "python";
  };

  globals.mapleader = " ";

  extraPlugins = with pkgs.vimPlugins; [
    typst-preview-nvim
  ];

  colorschemes.gruvbox.enable = true;

  clipboard.providers.wl-copy.enable = pkgs.stdenv.isLinux;
  clipboard.providers.pbcopy.enable = pkgs.stdenv.isDarwin;
  clipboard.register = "unnamedplus";

  extraPackages = [ pkgs.imagemagick pkgs.fd pkgs.ripgrep pkgs.ueberzugpp];
  extraLuaPackages = ps: [ ps.magick ];

  extraConfigLua =
    /*
    lua
    */
    ''
      -- There might be a better way to do it
      vim.cmd("packadd! termdebug");
    '';
}
