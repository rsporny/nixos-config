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

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      ms-python.python
    ];
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
   #   mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
      sources = [ (mkTuple [ "xkb" "gb+mac" ]) ];
   #   xkb-options = [ "lv3:ralt_switch" ];
    };
  };

  home.stateVersion = "25.05";
}

