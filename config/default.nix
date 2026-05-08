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
  nixpkgs.config.allowUnfree = true;
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
    image = {
      enable = true;

      package = pkgs.vimPlugins.image-nvim.overrideAttrs (old: {
        postPatch =
          (old.postPatch or "")
          + ''
                ${pkgs.python3}/bin/python3 - <<'PY'
            from pathlib import Path
            import re

            # 1. Correctness fix:
            # Pass editor_tty for Kitty direct transfers.
            p = Path("lua/image/backends/kitty/init.lua")
            s = p.read_text()

            tty_line = "tty = transmit_medium == codes.control.transmit_medium.direct and editor_tty or nil,"

            if tty_line not in s:
                needle = "transmit_medium = transmit_medium,"
                if needle not in s:
                    raise SystemExit("could not find transmit_medium field in init.lua")

                s = s.replace(
                    needle,
                    needle + "\n        " + tty_line,
                    1,
                )

            p.write_text(s)


            # 2. Performance experiment:
            # Keep per-chunk tty writes, but make chunks bigger than 4096.
            #
            # This reduces open/write/flush/close calls while avoiding the corruption
            # caused by one giant tty stream.
            p = Path("lua/image/backends/kitty/helpers.lua")
            s = p.read_text()

            # Supports current helper shape:
            #   for i = 1, #str, 4096 do
            #   str:sub(i, i + 4096 - 1)
            s = s.replace("for i = 1, #str, 4096 do", "for i = 1, #str, 65536 do")
            s = s.replace("str:sub(i, i + 4096 - 1)", "str:sub(i, i + 65536 - 1)")

            # Supports alternate helper shape:
            #   utils.str.chunk(str, 4096)
            s = s.replace("utils.str.chunk(str, 4096)", "utils.str.chunk(str, 65536)")

            if "65536" not in s:
                raise SystemExit("could not patch Kitty chunk size in helpers.lua")

            p.write_text(s)
            PY
          '';
      });
      # package = pkgs.vimPlugins.image-nvim.overrideAttrs (old: {
      #   postPatch =
      #     (old.postPatch or "")
      #     + ''
      #       substituteInPlace lua/image/backends/kitty/init.lua \
      #         --replace-fail \
      #           'if transmitted_images[image.id] ~= preprocessing_hash then' \
      #           'if true then -- DEBUG: always retransmit'
      #     '';
      # });

      settings = {
        debug.enabled = true;
        window_overlap_clear_enabled = true;
      };
    };
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

  extraPackages = [pkgs.imagemagick pkgs.fd pkgs.ripgrep pkgs.ueberzugpp];

  extraConfigLua =
    /*
    lua
    */
    ''
      -- There might be a better way to do it
      vim.cmd("packadd! termdebug");
    '';
}
