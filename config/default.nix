{
  self,
  pkgs,
  ...
}: {
  # Import all your configuration modules here
  imports = [
    ./keymaps.nix
    ./lsp.nix
    ./bufferline.nix
    ./completion.nix
    ./lint.nix
    ./plaintext_format.nix
  ];
  plugins = {
    lualine.enable = true;
    wilder.enable = true;
    wtf.enable = true;
    comment.enable = true;
    which-key.enable = true;
    nvim-tree = {
      enable = true;
      git = {
        enable = true;
        ignore = false;
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
  };

  opts = {
    number = true;
    relativenumber = true;
    shiftwidth = 2;
  };

  globals.mapleader = " ";

  extraPlugins = with pkgs.vimPlugins; [
    lazydev-nvim
    typst-preview-nvim
  ];

  colorschemes.gruvbox.enable = true;

  clipboard.providers.wl-copy.enable = true;
  clipboard.register = "unnamedplus";
}
