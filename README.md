# NixOS Configuration Files

Inspired by https://github.com/mitchellh/nixos-config, I'm creating a simple way to bootstrap a new dev machine.

## First steps
- setup new Mac
- install git (xcode)
- restore `.gnupg`, `.ssh` and keychain from backup
- install Parallels
- setup new NixOS VM

## Copy files to VM
- add MacOS SSH public key to the VM
```
users.users.root.openssh.authorizedKeys.keys = [
  "<pub key>"
];
```

