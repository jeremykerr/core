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
- [home.arpa](https://home.arpa) is the default landing page
- [auth.home.arpa](https://auth.home.arpa) is where you can configure Keycloak
- [middleware.home.arpa](https://middleware.home.arpa) is where you can login
    - You can login with `test`/`test` or `admin`/`admin`
    - These users are specified in the [realm.json](./platform/identity/import/realm.json) file
    - The `test` user is a regular user with the `user` role
    - The `admin` user is an admin user with the `user` and `admin` roles
    - You can sign out at [middleware.home.arpa/oauth2/sign_out](https://middleware.home.arpa/oauth2/sign_out)
- [hello.home.arpa](https://hello.home.arpa) is the demo app, which requires authentication
    - [hello.home.arpa/](https://hello.home.arpa/) is accessible to all users, authenticated or not
    - [hello.home.arpa/authorized](https://hello.home.arpa/authorized) is limited to authenticated users
    - [hello.home.arpa/admin](https://hello.home.arpa/admin) is limited to admins

## Appendix

For troubleshooting, see [Troubleshooting Guide](./docs/TROUBLESHOOTING.md)

