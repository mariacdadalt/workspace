# WordPress Multisite Lando Environment

This project provides a simple local setup for WordPress multisite development using [Lando](https://lando.dev/) and VS Code.

## Requirements
* [Lando](https://lando.dev/)
* [Docker](https://www.docker.com/) (installed with Lando)

## Getting started
1. Clone this repository.
2. Run `./init.sh` to start Lando, install dependencies and bootstrap WordPress.
3. Access the site at [https://wordpress.lndo.site](https://wordpress.lndo.site).

Use `lando wp`, `lando composer`, `lando php` and `lando npm` for CLI tasks.

## VS Code
Debugging and extension recommendations are preconfigured in the `.vscode` folder.

## Directory structure
* `web/` – Document root served by Lando
* `vendor/` – Composer packages (git ignored)
