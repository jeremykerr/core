# [Devbox](https://www.jetify.com/docs/devbox/)

## Quickstart

Install Devbox:
```
curl -fsSL https://get.jetify.com/devbox | bash
```

Activate local environment:
```
devbox shell
```

Go back to your regular shell:
```
exit
```

## Troubleshooting

### Devbox Installation

If `devbox shell` complains about a missing Nix installation, you may need to [install Nix](https://nixos.org/download):
```
sh <(curl -L https://nixos.org/nix/install)
```

After installing, restart all shells/terminals.

### Mac Updates

Mac updates can occasionally break Nix installations. Usually it's not hard to fix, but sometimes
you may need to [uninstall & reinstall Nix](https://nix.dev/manual/nix/2.18/installation/uninstall).

### Error: nix: command error ... SQL logic error, table Cache has no column ...

If `devbox shell` or other Devbox commands give you an error like this one, you may have a broken Nix cache.
It's easiest just to reset/rebuild:
```
rm -rf ~/.cache/nix/*
devbox shell
```
