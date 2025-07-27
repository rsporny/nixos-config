{ config, pkgs, lib, ... }:

let
  sharedPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTCs2ssi3U1hCcfmhgwom/rGlf0l19js3eTfpSh4LUD";
in
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Warsaw";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  users.users.rspo = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [ sharedPubKey ];
  };

  security.sudo.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
    neovim
    gnupg
    openssh
    curl
    wget
    docker
    kubectl
  ];

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [ sharedPubKey ];

  programs.fish.enable = true;
  programs.neovim.enable = true;
  services.udev.packages = [
    pkgs.yubikey-personalization
  ];
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;  # needed if using gpg-agent for SSH as well
  };

  virtualisation.docker.enable = true;

  system.stateVersion = "25.05";
}

