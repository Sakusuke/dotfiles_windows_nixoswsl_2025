# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:
{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
  ];

  wsl.enable = true;
  wsl.defaultUser = "windesk";
  
  
  users.defaultUserShell = pkgs.zsh;
  # Terminal
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "sudo" ];
      theme = "eastwood";};};

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git gh yadm wget curl
    vim neovim
    neofetch
    htop 
    
    ## File management
    ncdu
    vimv
    trash-cli
    lf

    ## idk random shit im testing
    yt-dlp jq
    ffmpeg

    (python3.withPackages (ps: with ps; [
      ytmusicapi
    ]))
  ];

    # Variables
  environment.sessionVariables = {
    #for xdg-ninja, beware zsh not working/being in the wrong spot
    XDG_DATA_HOME = "$HOME/.local/share"; #these 4 are for general setup for the others
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
    WINEPREFIX = "$XDG_DATA_HOME/wine"; #for .wine
    XINITRC = "$XDG_CONFIG_HOME/X11/xinitrc"; #for .xinitrc
    ZDOTDIR = "$HOME/.config/zsh"; #for zshrc
    #HISTFILE = "$XDG_STATE_HOME/zsh/history"; for some reason this doesnt work, now declaring in .zshrc file
    GNUPGHOME = "$XDG_DATA_HOME/gnupg"; #idk
    GTK2_RC_FILES = "$XDG_CONFIG_HOME/gtk-2.0/gtkrc"; #for .gtkrc

    ## variables that would usually be .profile, a replacement for that idk what, you have to restart WM for changes to take effect
    QT_SCALE_FACTOR= "1.4";
    ELM_SCALE= "1.4";
    GDK_SCALE= "1.4";
    XCURSOR_SIZE= "30";
    XCOMPOSECACHE="$XDG_CACHE_HOME/X11/xcompose";
  };

  system.stateVersion = "24.11";
}
