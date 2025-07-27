{ config, pkgs, lib, ... }:

let
  username = "rspo";
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  programs.home-manager.enable = true;
  programs.ssh.enable = true;

  programs.fish = {
    enable = true;
    shellAbbrs = {
      ll = "ls -lha";
      vim = "nvim";
    };
  };

  programs.ghostty = {
    enable = true;
    settings.keybind = [
      "performable:cmd+c=copy_to_clipboard"
      "cmd+v=paste_from_clipboard"
    ];
  };

  programs.git = {
    enable = true;
    userEmail = "404@rspo.dev";
    userName = "Radosław Sporny";
    signing.key = "15AC8EA84FC2A5AE768FFD753CEBBA453DE5BCFD";
    signing.signByDefault = true;
    signing.signer = "gpg";
  };

  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      disable-ccid = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    verbose = true;
    pinentry = {
      package = pkgs.pinentry-gtk2;
      program = "pinentry";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      # LazyVim
      lua-language-server
      stylua
      # Telescope
      ripgrep
    ];

    plugins = [ pkgs.vimPlugins.lazy-nvim ];

    extraLuaConfig =
      let
        plugins = with pkgs.vimPlugins; [
          # LazyVim
          LazyVim
          bufferline-nvim
          cmp-buffer
          cmp-nvim-lsp
          cmp-path
          conform-nvim
          dashboard-nvim
          dressing-nvim
          flash-nvim
          friendly-snippets
          gitsigns-nvim
          grug-far-nvim
          indent-blankline-nvim
          lazydev-nvim
          lualine-nvim
          luvit-meta
          neo-tree-nvim
          noice-nvim
          nui-nvim
          nvim-cmp
          nvim-lint
          nvim-lspconfig
          nvim-snippets
          nvim-treesitter
          nvim-treesitter-textobjects
          nvim-ts-autotag
          persistence-nvim
          plenary-nvim
          snacks-nvim
          telescope-fzf-native-nvim
          telescope-nvim
          todo-comments-nvim
          tokyonight-nvim
          trouble-nvim
          ts-comments-nvim
          which-key-nvim
          { name = "catppuccin"; path = catppuccin-nvim; }
          { name = "mini.ai"; path = mini-nvim; }
          { name = "mini.icons"; path = mini-nvim; }
          { name = "mini.pairs"; path = mini-nvim; }
        ];
        mkEntryFromDrv = drv:
          if lib.isDerivation drv then
            { name = "${lib.getName drv}"; path = drv; }
          else
            drv;
        lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
      in
      ''
        require("lazy").setup({
          defaults = {
            lazy = true,
          },
          dev = {
            -- reuse files from pkgs.vimPlugins.*
            path = "${lazyPath}",
            patterns = { "" },
            -- fallback to download
            fallback = true,
          },
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
            -- The following configs are needed for fixing lazyvim on nix
            -- force enable telescope-fzf-native.nvim
            { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
            -- disable mason.nvim, use config.extraPackages
            { "williamboman/mason-lspconfig.nvim", enabled = false },
            { "williamboman/mason.nvim", enabled = false },
            -- uncomment to import/override with your plugins
            -- { import = "plugins" },
            -- put this line at the end of spec to clear ensure_installed
            { "nvim-treesitter/nvim-treesitter", opts = function(_, opts) opts.ensure_installed = {} end },
          },
        })
      '';
  };

  home.packages = with pkgs; [
    curl
    gnupg
    pinentry-gtk2
    yubikey-manager
    pcsc-tools
    gcr
    kubectl
    docker
    ghostty
  ];

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/peripherals/keyboard" = {
      delay = mkUint32 300;
      repeat = true;
      repeat-interval = 10;
    };
    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
      sources = [ (mkTuple [ "xkb" "us+mac" ]) ];
      xkb-options = [ "lv3:ralt_switch" ];
    };
  };

  home.stateVersion = "25.05";
}

