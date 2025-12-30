{ lib, pkgs, ... }:

{
  languages.elixir.enable = true;
  packages = [
    pkgs.inotify-tools

    pkgs.clang

    pkgs.esptool
    pkgs.picocom
  ] ++
  lib.optionals pkgs.stdenv.isDarwin [
    # for ExUnit notifier
    pkgs.terminal-notifier

    # for package - file_system
    pkgs.darwin.apple_sdk.frameworks.CoreFoundation
    pkgs.darwin.apple_sdk.frameworks.CoreServices
  ];

  scripts.flash.exec = ''
    mix atomvm.packbeam && sudo esptool --chip auto --port /dev/ttyUSB0 --baud 921600 \
      write-flash 0x250000 serial_test.avm
  '';

  scripts.monitor.exec = ''
    sudo picocom -b 115200 /dev/ttyUSB0
  '';
}
