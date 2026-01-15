# DDEV Kanopi Drupal Add-on

[![tests](https://github.com/kanopi/ddev-kanopi-drupal/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/kanopi/ddev-kanopi-drupal/actions/workflows/test.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/kanopi/ddev-kanopi-drupal)](https://github.com/kanopi/ddev-kanopi-drupal/commits)
[![release](https://img.shields.io/github/v/release/kanopi/ddev-kanopi-drupal)](https://github.com/kanopi/ddev-kanopi-drupal/releases/latest)
![project is maintained](https://img.shields.io/maintenance/yes/2025.svg)

A comprehensive DDEV add-on that provides Kanopi's battle-tested workflow for Drupal development. This add-on includes complete tooling for modern Drupal development with multi-provider hosting support.

## Features

This add-on provides:

- **27 Custom Commands**: Complete Drupal development workflow with namespaced commands
- **Multi-Provider Hosting**: Support for Pantheon and Acquia hosting platforms
- **Recipe Development**: Tools for Drupal 11 recipe creation and management
- **Theme Development**: Node.js, NPM, and build tools with file watching
- **Testing Framework**: Cypress E2E testing with user management
- **Database Management**: Smart refresh system with 12-hour backup detection
- **Critical CSS Tools**: Performance optimization with critical path CSS generation
- **Migration Utilities**: Tools for site migrations and database management
- **Security & Performance**: Platform-specific configurations and optimization
- **Services Integration**: Redis/Memcached and Solr via official DDEV add-ons
- **Environment Configuration**: Clean configuration system using environment variables

## Prerequisites

### Install DDEV and Docker Desktop

First, install DDEV on your system. Follow installation instructions at: [https://ddev.readthedocs.io/en/stable/users/install/ddev-installation/](https://ddev.readthedocs.io/en/stable/users/install/ddev-installation/)

The most common installation for macOS is to use Homebrew.

```bash
# Install DDEV
brew install ddev/ddev/ddev

# One-time initialization of mkcert
mkcert -install
```

If you have Docksal or Lando running, stop them to avoid port conflicts. This is not required as DDEV will find other ports if the primary ports are busy.

```bash
# Stop Docksal
fin system stop
# Stop Lando
lando poweroff
```

### Set Up Hosting Provider Authentication

#### Pantheon

```bash
# Set your Pantheon machine token globally
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
```

Get your token: [https://dashboard.pantheon.io/machine-token/create](https://dashboard.pantheon.io/machine-token/create)

#### Acquia

```bash
# Set your Acquia API credentials globally
ddev config global --web-environment-add=ACQUIA_API_KEY=your_api_key_here
ddev config global --web-environment-add=ACQUIA_API_SECRET=your_api_secret_here
```

Get your credentials: [https://cloud.acquia.com/a/profile/tokens](https://cloud.acquia.com/a/profile/tokens)

---

## Quick Start

- **[Adding DDEV and this add-on](#adding-ddev-and-this-add-on)** - Set up DDEV and this add-on for a brand new local environment
- **[New to this project?](#new-to-this-project)** - Clone and start developing on a project that already uses this add-on

## Adding DDEV and this add-on

You're setting up a DDEV local development environment for the first time. If you already have DDEV configured on your project, skip to Step 2.


### 1. Configure DDEV

In the root of your project, initialize DDEV with provider-specific settings:

#### Pantheon
```bash
# Configure for Pantheon
ddev config --project-type=drupal11 --docroot=web --database=mariadb:10.6
ddev start
```

#### Acquia
```bash
# Configure for Acquia
ddev config --project-type=drupal11 --docroot=docroot --webserver-type=apache-fpm --database=mysql:5.7
ddev start
```

### 2. Install the Add-on

```bash
ddev add-on get kanopi/ddev-kanopi-drupal
```

### 3. Review local development customizations

This add-on was created from our standard drupal-starter. If your project has different or custom command, environment variables, or configuration, identify and replicate at this point in DDEV.

Common customizations needed here are:

* settings.php
* Theme installation/build/watch commands
* Solr settings
* .ddev/config.yaml (make sure php_version matches your project's PHP version)

See [custom-configuration.md](custom-configuration.md) for common scenarios.

If you do change any files provided by the add-on, remove the #ddev-generate comment from the file.  This will make it a custom file and won't be touched if you update or remove the add-on.

### 4. Configure Your Project

Run the interactive configuration wizard:

```bash
ddev project-configure
```

### 5. Initialize Your Environment

```bash
# Install dependencies, pull database, set up development tools
ddev project-init
```

---

## New to this Project

If you're joining a project that already uses this add-on, you just need to clone it and run project-init. Use this section to add to your project's README.md for local development.  You can also grab the commands from the commands.md

### Step 1: Clone and Start

```bash
# Clone the project repository
git clone <repository-url>
cd <project-directory>

# Start DDEV
ddev start
```

### Step 3: Initialize Your Environment

```bash
# Pull database, install dependencies, set up tools
ddev project-init
```

### You're Done!

Start developing:
```bash
# Open the site
ddev launch

# Watch theme files for changes
ddev theme-watch

# Generate a login link
ddev drupal-uli
```
## Converting Your Project from Docksal

### If your project is Drupal and on Pantheon
Add the following to `assets/pantheon_settings_defaults.inc`:

```php
/**
* Include DDEV settings if available.
*/
$ddev_settings = __DIR__ . '/settings.ddev.php';
if (file_exists($ddev_settings)) {
include $ddev_settings;
}
```
### If your project uses LeftHook
1. Check `lefthook.yml`
2. If there are docksal commands ("fin"), update them to be ddev commands, e.g.,
4. Change: `run: fin composer -n code-sniff`
7. To: `run: ddev composer -n code-sniff`
