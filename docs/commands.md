# Command Reference

The DDEV Kanopi Drupal Add-on provides custom commands to streamline local development, testing, and hosting integration.

**Types**

* **Host** – Run on your local machine (outside the DDEV container).
* **Web** – Run inside the DDEV web container (full Drupal environment access).

**How to use**

* Run commands with `ddev <command>` in your project directory.
* Append `--help` to any command for usage details, options, and flags (e.g., `ddev db-refresh --help`).

---

| Command            | Description                                                               | Example                                    | Alias                                                    | Type |
|--------------------|---------------------------------------------------------------------------|--------------------------------------------|----------------------------------------------------------|------|
| `critical-install` | Initialize/reinstall tools needed for critical CSS.                       | `ddev critical-install`                    | `critical:install`, `install-critical-tools`, `cri`      | Web  |
| `critical-run`     | Run Critical CSS Commands                                                 | `ddev critical-run`                        | `critical:run`, `critical`, `crr`                        | Web  |
| `cypress-install`  | Install the node packages for cypress on the developers local machine     | `ddev cypress-install`                     | `cypress:install`, `cyi`, `install-cypress`              | Host |
| `cypress-run`      | Run Cypress Commands                                                      | `ddev cypress-run [command]`               | `cypress:run`, `cy`, `cypress`, `cyr`                    | Host |
| `cypress-users`    | Create Cypress users                                                      | `ddev cypress-users`                       | `cypress:users`, `cyu`                                   | Host |
| `db-prep-migrate`  | Create and configure the migration database inside the DDEV web container | `ddev db-prep-migrate`                     | `db:prep-migrate`, `migrate-prep-db`                     | Web  |
| `db-rebuild`       | Runs composer install and database refresh.                               | `ddev db-rebuild`                          | `db:rebuild`, `rebuild`, `dbreb`                         | Host |
| `db-refresh`       | Downloads the database from the hosting provider (Pantheon & Acquia).     | `ddev db-refresh pr-123`                   | `db:refresh`, `refresh`                                  | Web  |
| `drupal-open`      | Open the site or admin in your default browser                            | `ddev drupal-open      # Opens the site`   | `drupal:open`, `open`                                    | Web  |
| `drupal-uli`       | Logs you in to Drupal.                                                    | `ddev project-uli`                         | `drupal:uli`, `uli`                                      | Host |
| `pantheon-testenv` | Initialize stack and testing environment in DDEV.                         | `ddev pantheon-testenv my-env minimal`     | `pantheon:testenv`, `testenv`                            | Host |
| `pantheon-terminus`| Run Terminus commands for Pantheon integration                            | `ddev pantheon-terminus site:list`         | —                                                        | Host |
| `pantheon-tickle`  | Continuously wake up a Pantheon environment.                              | `ddev pantheon-tickle`                     | `pantheon:tickle`, `tickle`                              | Web  |
| `phpmyadmin`       | Launch a browser with PhpMyAdmin                                          | `ddev phpmyadmin`                          | —                                                        | Host |
| `auth ssh`         | Adds SSH keys to the ddev containers.                                     | `ddev auth ssh`                            | —                                                        | Host |
| `project-configure`| Interactive configuration wizard for Kanopi Drupal DDEV                   | `ddev project-configure`                   | `configure`, `project:configure`, `prc`                  | Host |
| `project-init`     | Initialize local development.                                             | `ddev project-init`                        | `project:init`, `init`                                   | Host |
| `project-lefthook` | Initialize Lefthook.                                                      | `ddev project-lefthook`                    | `project:lefthook`                                       | Host |
| `project-nvm`      | Initializes NVM.                                                          | `ddev project-nvm`                         | `project:nvm`                                            | Host |
| `recipe-apply`     | Apply a Drupal Recipe.                                                    | `ddev recipe-apply ../recipes/recipe-name` | `recipe:apply`, `recipe`, `ra`                           | Web  |
| `recipe-unpack`    | Unpack a recipe package that's already required in your project           | `ddev recipe-unpack drupal/example_recipe` | `recipe:unpack`, `ru`                                    | Web  |
| `recipe-uuid-rm`   | Remove UUIDs and _core metadata from Drupal config files.                 | `ddev recipe-uuid-rm config/sync`          | `recipe:uuid-rm`, `uuid-rm`                              | Web  |
| `theme-build`      | Build production assets for the theme                                     | `ddev theme-build`                         | `theme:build`, `production`, `thb`, `theme-production`   | Web  |
| `theme-install`    | Install and set up theme development tools in DDEV                        | `ddev theme-install`                       | `theme:install`, `install-theme-tools`, `thi`            | Web  |
| `theme-npm`        | Runs NPM commands on the theme.                                           | `ddev theme-npm install`                   | `theme:npm`                                              | Web  |
| `theme-npx`        | Runs NPX commands on the theme.                                           | `ddev theme-npx webpack --watch`           | `theme:npx`                                              | Web  |
| `theme-watch`      | Start theme development with file watching                                | `ddev theme-watch`                         | `theme:watch`, `development`, `thw`, `theme-development` | Web  |

**Notes**

* Some commands accept additional options/flags. Use `--help` to view full usage.
