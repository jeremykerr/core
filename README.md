# CORE: Code, Operations, Resources, & Environments

## Prerequisites

You'll need the following accounts:

1. [Github](https://github.com/)
2. [Docker](https://docker.com/)

## Getting Started

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) and start it
2. Install [Devbox](./docs/DEVBOX.md)
3. Setup the local development environment
```
devbox run setup
devbox run dnsmasq
```
4. Restart Firefox & Chrome browsers to ensure local settings take effect
5. Finalize the Docker setup
```
devbox shell
make buildx
```

## Development loop

```
devbox shell
make run
```

The Makefile is your friend. To learn more advanced commands, run `make` or `make help`.

## Interacting with your apps

These are the links you can use to interact with apps while running locally:
- [home.arpa](https://home.arpa)

## Appendix

For troubleshooting, see [Troubleshooting Guide](./docs/TROUBLESHOOTING.md)

