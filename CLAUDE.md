# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a DDEV add-on that provides Kanopi's battle-tested workflow for Drupal development with multi-provider hosting support. The add-on includes 27 custom commands, enhanced provider integration for Pantheon and Acquia, and complete tooling for modern Drupal development.

## Architecture

### Command Structure
Commands are organized into two categories:
- **Host commands** (`commands/host/`): Execute on the host system outside containers
- **Web commands** (`commands/web/`): Execute inside the DDEV web container

### Core Components
- `install.yaml`: Add-on installation configuration and post-install actions
- `commands/`: Custom DDEV commands for development workflow
- `providers/`: Enhanced Pantheon provider configuration (not in this repo but created during installation)

## Common Development Commands

### Essential Commands
- `ddev project-init`: Complete project initialization with dependencies, Lefthook, NVM, and database refresh
- `ddev project-configure`: Interactive configuration wizard for project setup
- `ddev auth ssh`: Adds SSH keys to the ddev containers
- `ddev project-lefthook`: Install and initialize Lefthook git hooks
- `ddev project-nvm`: Install NVM and Node.js for theme development
- `ddev db-refresh [env] [-f]`: Smart database refresh from hosting provider with backup age detection (12-hour threshold)
- `ddev db-rebuild`: Composer install followed by database refresh
- `ddev drupal-open`: Open project URL in browser
- `ddev drupal-uli`: Generate one-time login link for Drupal

### Development Workflow Commands
- `ddev theme-install`: Set up Node.js, NPM, and build tools for theme development
- `ddev theme-npm <command>`: Run NPM commands in theme directory
- `ddev theme-npx <command>`: Run NPX commands in theme directory
- `ddev critical-install`: Install Critical CSS generation tools
- `ddev critical-run`: Run Critical CSS generation
- `ddev theme-watch`: Start theme development with file watching
- `ddev theme-build`: Build production theme assets

### Testing Commands
- `ddev cypress-install`: Install Cypress E2E testing dependencies
- `ddev cypress-run <command>`: Run Cypress commands with environment support
- `ddev cypress-users`: Create default admin user for Cypress testing
- `ddev pantheon-testenv <name> [type]`: Create isolated testing environment

### Drupal Recipe Commands
- `ddev recipe-apply <path>`: Apply Drupal recipe with cache management
- `ddev recipe-unpack <path>`: Unpack and prepare Drupal recipe for development
- `ddev recipe-uuid-rm <path>`: Remove UUIDs from config files (for recipe development)

### Migration and Database Commands
- `ddev db-prep-migrate`: Create secondary database for migrations
- `ddev pantheon-tickle`: Keep Pantheon environment awake (useful for long migrations)
- `ddev pantheon-terminus <command>`: Run Terminus commands for Pantheon integration

## Hosting Provider Support

### Pantheon
- **Recommended Docroot**: `web` (set during `ddev config`)
- **Environments**: dev, test, live, multidev
- **Authentication**: Terminus machine token
- **Database**: Automated backup management with age detection

### Acquia
- **Recommended Docroot**: `docroot` (set during `ddev config`)
- **Webserver**: apache-fpm for compatibility
- **Database**: MySQL 5.7
- **Authentication**: Acquia API key and secret
- **File Proxy**: Apache .htaccess-based proxy for missing files

## Configuration System

The add-on uses a simplified configuration approach with provider-specific variables managed through `ddev project-configure`.

### Configuration Storage
Variables are stored in two locations:
- **`.ddev/config.yaml`** (web_environment section): For DDEV containers to access via `printenv`
- **`.ddev/scripts/load-config.sh`**: For command scripts to source directly

### Common Variables (All Providers)
- `HOSTING_PROVIDER`: Platform identifier (pantheon, acquia)
- `THEME`: Path to custom theme directory (e.g., `themes/custom/themename`)
- `THEMENAME`: Theme name for development tools
- `HOSTING_SITE`: Site identifier on hosting platform
- `HOSTING_ENV`: Default environment for database pulls

### Provider-Specific Variables

#### Pantheon Configuration
- `HOSTING_SITE`: Pantheon site machine name
- `HOSTING_ENV`: Default environment for database pulls (dev/test/live)
- `MIGRATE_DB_SOURCE`: Source site for migrations (optional)
- `MIGRATE_DB_ENV`: Source environment for migrations (optional)

#### Acquia Configuration
- `HOSTING_SITE`: Acquia application name
- `HOSTING_ENV`: Default environment for database pulls (dev/stg/prod)
- `APACHE_FILE_PROXY`: Proxy URL for missing files
- `ACQUIA_API_KEY`: API key for Acquia Cloud API
- `ACQUIA_API_SECRET`: API secret for Acquia Cloud API

### Configuration Command
Use `ddev project-configure` to set up all variables through an interactive wizard that collects only the variables needed for your chosen hosting provider.

## Smart Refresh System

The `ddev db-refresh` command includes intelligent backup management:
- **Pantheon**: Automatically detects backup age (12-hour threshold) using Terminus API
- **Acquia**: Uses Acquia Cloud API for backup retrieval and management
- Uses `-f` flag to force new backup creation
- Supports any provider environment
- Includes automatic Cypress user creation after refresh

## Command Development Guidelines

### Host Command Template
```bash
#!/usr/bin/env bash

## Description: Brief description of what the command does
## Usage: command-name [arguments]
## Example: "ddev command-name arg1 arg2"

set -e
# Command logic here
```

### Web Command Template
```bash
#!/usr/bin/env bash

## Description: Brief description of what the command does
## Usage: command-name [arguments]
## Example: "ddev command-name arg1 arg2"

set -e
# Command logic here
```

## Installation and Setup

### Quick Start
The installation process varies based on your situation. See the main documentation index (`docs/index.md`) for detailed setup instructions covering:

1. **Adding DDEV and this add-on** - Setting up from scratch
2. **New to this project** - Joining a project that already uses this add-on

### Authentication Setup

Global authentication credentials are required for hosting provider API access:

#### Pantheon Authentication
```bash
# Set your Pantheon machine token globally
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
```
Get your token at: https://dashboard.pantheon.io/machine-token/create

#### Acquia Authentication
```bash
# Set your Acquia API credentials globally
ddev config global --web-environment-add=ACQUIA_API_KEY=your_api_key
ddev config global --web-environment-add=ACQUIA_API_SECRET=your_api_secret
```
Get credentials at: https://cloud.acquia.com/a/profile/tokens

### Basic Installation Flow
```bash
# 1. Configure DDEV (Pantheon example)
ddev config --project-type=drupal11 --docroot=web --database=mariadb:10.6
ddev start

# 2. Install the add-on
ddev add-on get kanopi/ddev-kanopi-drupal

# 3. Configure your project
ddev project-configure

# 4. Initialize
ddev project-init
```

### Local Development Testing
```bash
# Test add-on installation from local directory
ddev add-on get /path/to/ddev-kanopi-drupal

# Test removal
ddev add-on remove kanopi-drupal
```

### Testing Framework
The project includes comprehensive testing:

#### Official DDEV Testing (CI)
Uses `ddev/github-action-add-on-test@v2` for standardized add-on validation in GitHub Actions.

#### Bats Tests (Component Testing)
```bash
# Run bats tests locally
bats tests/test.bats

# Run specific test
bats tests/test.bats --filter "install from directory"
```

#### Integration Testing (End-to-End)
```bash
# Run comprehensive integration test
./tests/test-install.sh
```

## Dependencies

The add-on automatically installs and configures:
- **Lefthook** for git hooks
- **NVM** for Node.js version management
- **Cypress** for E2E testing
- **Terminus** for Pantheon API access (when using Pantheon)
- **Acquia CLI** for Acquia Cloud API access (when using Acquia)
- **Theme development tools** (Node.js, NPM)
- **Critical CSS generation tools**
- **Redis add-on** for caching (Pantheon)
- **Memcached add-on** for caching (Acquia)
- **Solr add-on** for search functionality
- **Multi-provider API tools** for hosting platform integration

## Cross-Repository Development

**IMPORTANT**: When working on this Drupal add-on, you should also work on the companion WordPress add-on (`ddev-kanopi-wp`) to maintain consistency between both projects.

### Maintaining Feature Parity
Both add-ons should maintain feature parity where applicable:
- **Shared commands**: Database, theme, testing, and utility commands should have identical functionality
- **Configuration patterns**: Environment variables, file structures, and naming conventions should align
- **Documentation**: README files, command help text, and examples should be consistent
- **CI/CD**: Both projects should have identical GitHub Actions and CircleCI configurations

### Development Workflow
When making changes to this repository:
1. **Assess applicability**: Determine if the change should also be applied to the WordPress add-on
2. **Mirror changes**: If applicable, make equivalent changes in both repositories
3. **Test both**: Ensure changes work correctly in both Drupal and WordPress contexts
4. **Update documentation**: Keep README and CLAUDE.md files synchronized
5. **Maintain aliases**: Preserve backward compatibility in both add-ons

### Platform-Specific Differences
While maintaining consistency, respect platform differences:
- **Drupal-specific**: Recipe commands (`recipe:apply`, `recipe:uuid-rm`)
- **WordPress-specific**: Block creation (`theme:create-block`), admin user management (`wp:restore-admin-user`)
- **Hosting providers**: Both support Pantheon, but WordPress also supports WPEngine and Kinsta
- **File structures**: Drupal uses different directory conventions than WordPress

### Repository Locations
- **Drupal add-on**: https://github.com/kanopi/ddev-kanopi-drupal
- **WordPress add-on**: https://github.com/kanopi/ddev-kanopi-wp

## Testing Notes
- Always test changes to install.yaml thoroughly
- Use bats tests for quick validation during development
- Run integration tests before major releases
- Tests pre-configure environment variables to avoid interactive prompts
- Test changes in both add-ons when making cross-repository updates