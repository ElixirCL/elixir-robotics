{ pkgs, ... }:

{
  languages.go.enable = true;
  packages = [
    pkgs.esptool
    pkgs.minicom
    pkgs.tic-80
  ];
}
