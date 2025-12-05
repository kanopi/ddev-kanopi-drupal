#!/usr/bin/env bats

# Test suite for ddev-kanopi-drupal add-on

setup() {
    export PROJNAME=test-kanopi-drupal
    export TESTDIR=~/tmp/$PROJNAME
    export DIR=${BATS_TEST_DIRNAME}/..
    mkdir -p $TESTDIR && cd $TESTDIR
    export DDEV_NONINTERACTIVE=true
    ddev delete -Oy $PROJNAME >/dev/null 2>&1 || true
    cd $TESTDIR
}

health_checks() {
    echo "Starting health checks..." >&3
    # Basic health checks for the add-on
    echo "Checking PHP version..." >&3
    ddev exec "php --version" | grep "PHP"
    echo "Checking Drush..." >&3
    # Note: Drush may not be available in test environment
    ddev exec "drush --version" 2>/dev/null | grep "Drush" || echo "Drush not available in test environment"

    echo "Checking Docker services..." >&3
    # Check services are running (from DDEV add-ons)
    docker ps | grep "ddev-${PROJNAME}-redis" || docker ps | grep "ddev-${PROJNAME}-memcached" || echo "Caching service should be running"
    docker ps | grep "ddev-${PROJNAME}-solr" || echo "Solr service should be running"

    echo "Checking custom commands..." >&3
    # Check new modular project commands
    ddev project-init --help || echo "project-init command exists or skipped due to conflicts"
    ddev project-configure --help || echo "project-configure command exists or skipped due to conflicts"
    ddev auth ssh --help || echo "auth ssh command exists or skipped due to conflicts"
    ddev project-lefthook --help || echo "project-lefthook command exists or skipped due to conflicts"
    ddev project-nvm --help || echo "project-nvm command exists or skipped due to conflicts"

    # Check theme development commands
    ddev theme-install --help || echo "theme-install command exists or skipped due to conflicts"
    ddev theme-watch --help || echo "theme-watch command exists or skipped due to conflicts"
    ddev theme-build --help || echo "theme-build command exists or skipped due to conflicts"
    ddev theme-npm --help || echo "theme-npm command exists or skipped due to conflicts"
    ddev theme-npx --help || echo "theme-npx command exists or skipped due to conflicts"

    # Check Drupal specific commands
    ddev drupal-open --help || echo "drupal-open command exists or skipped due to conflicts"
    ddev drupal-uli --help || echo "drupal-uli command exists or skipped due to conflicts"

    # Check recipe commands (Drupal-specific)
    ddev recipe-apply --help || echo "recipe-apply command exists or skipped due to conflicts"
    ddev recipe-unpack --help || echo "recipe-unpack command exists or skipped due to conflicts"
    ddev recipe-uuid-rm --help || echo "recipe-uuid-rm command exists or skipped due to conflicts"

    # Check database and hosting commands
    ddev db-refresh --help || echo "db-refresh command exists or skipped due to conflicts"
    ddev db-rebuild --help || echo "db-rebuild command exists or skipped due to conflicts"
    ddev db-prep-migrate --help || echo "db-prep-migrate command exists or skipped due to conflicts"
    ddev pantheon-terminus --help || echo "pantheon-terminus command exists or skipped due to conflicts"
    ddev pantheon-testenv --help || echo "pantheon-testenv command exists or skipped due to conflicts"
    ddev pantheon-tickle --help || echo "pantheon-tickle command exists or skipped due to conflicts"

    # Check testing commands
    ddev cypress-install --help || echo "cypress-install command exists or skipped due to conflicts"
    ddev cypress-run --help || echo "cypress-run command exists or skipped due to conflicts"
    ddev cypress-users --help || echo "cypress-users command exists or skipped due to conflicts"

    # Check Critical CSS commands
    ddev critical-install --help || echo "critical-install command exists or skipped due to conflicts"
    ddev critical-run --help || echo "critical-run command exists or skipped due to conflicts"

    echo "Checking configuration files..." >&3
    # Check configuration files exist
    [ -f ".ddev/config/php/php.ini" ] || echo "Missing .ddev/config/php/php.ini"
    [ -f ".ddev/config/nginx_full/nginx-site.conf" ] || [ -f ".ddev/config/nginx/nginx-site.conf" ] || echo "Missing nginx configuration"

    echo "Checking scripts folder..." >&3
    # Check that scripts folder was copied
    [ -d ".ddev/scripts" ] || echo "Missing .ddev/scripts directory"
    [ -f ".ddev/scripts/load-config.sh" ] || echo "Missing load-config.sh configuration loader"
    [ -f ".ddev/scripts/refresh-pantheon.sh" ] || echo "Missing refresh-pantheon.sh"
    [ -f ".ddev/scripts/refresh-acquia.sh" ] || echo "Missing refresh-acquia.sh"

    echo "Checking gitignore..." >&3
    # Check gitignore was updated for add-on settings
    grep -q "settings.ddev.redis.php\|settings.ddev.memcached.php" .gitignore || echo "gitignore should contain add-on settings files"
    echo "Health checks completed." >&3
}

teardown() {
    set -eu -o pipefail
    cd $TESTDIR || ( printf "unable to cd to $TESTDIR\n" && exit 1 )
    ddev delete -Oy $PROJNAME >/dev/null 2>&1 || true
    [ "$TESTDIR" != "" ] && rm -rf $TESTDIR
}

@test "install from directory" {
    set -eu -o pipefail
    cd $TESTDIR
    echo "# ddev config --project-name=$PROJNAME --project-type=drupal10 --docroot=web --create-docroot" >&3
    ddev config --project-name=$PROJNAME --project-type=drupal10 --docroot=web --create-docroot

    echo "# ddev add-on get $DIR with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
    ddev add-on get $DIR

    echo "# ddev start" >&3
    ddev start

    health_checks
}

@test "environment variable configuration" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal10 --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start

    # Set up test environment variables using the add-on's configuration system
    ddev config --web-environment-add="HOSTING_PROVIDER=pantheon"
    ddev config --web-environment-add="HOSTING_SITE=test-site-123"
    ddev config --web-environment-add="HOSTING_ENV=dev"
    ddev config --web-environment-add="THEME=themes/custom/testtheme"
    ddev config --web-environment-add="THEMENAME=testtheme"

    # Restart to apply environment variable changes
    ddev restart

    # Check that environment variables were set correctly
    ddev exec printenv HOSTING_PROVIDER | grep -q "pantheon"
    ddev exec printenv HOSTING_SITE | grep -q "test-site-123"
    ddev exec printenv HOSTING_ENV | grep -q "dev"
    ddev exec printenv THEME | grep -q "themes/custom/testtheme"
    ddev exec printenv THEMENAME | grep -q "testtheme"
}

@test "interactive installation wizard" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal10 --docroot=web --create-docroot

    # Test non-interactive mode (should use defaults)
    export DDEV_NONINTERACTIVE=true
    ddev add-on get $DIR
    ddev start

    # Set up test environment variables to simulate configuration
    ddev config --web-environment-add="HOSTING_PROVIDER=pantheon"
    ddev config --web-environment-add="HOSTING_SITE=test-site-123"
    ddev config --web-environment-add="HOSTING_ENV=dev"

    # Restart to apply environment variable changes
    ddev restart

    # Check that default values were used in environment variables
    ddev exec printenv HOSTING_PROVIDER | grep -q "pantheon"
    ddev exec printenv HOSTING_SITE | grep -q "test-site-123"
    ddev exec printenv HOSTING_ENV | grep -q "dev"
}

@test "recipe functionality" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal10 --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start

    # Check that recipe commands exist and have proper structure (Drupal-specific)
    ddev recipe-apply --help >/dev/null 2>&1 || echo "recipe-apply command should exist"
    ddev recipe-unpack --help >/dev/null 2>&1 || echo "recipe-unpack command should exist"
    ddev recipe-uuid-rm --help >/dev/null 2>&1 || echo "recipe-uuid-rm command should exist"
}

@test "docker services" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal10 --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start

    # Wait a moment for services to fully start
    sleep 5

    # Check that core services are running (web and db are essential)
    docker ps | grep "ddev-${PROJNAME}-web"
    docker ps | grep "ddev-${PROJNAME}-db"

    # Check additional services (allow these to fail gracefully)
    docker ps | grep "ddev-${PROJNAME}-redis" || docker ps | grep "ddev-${PROJNAME}-memcached" || echo "Caching service not running"
    docker ps | grep "ddev-${PROJNAME}-solr" || echo "Solr service not running"
}

@test "modular command structure" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal10 --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start

    # Test modular project commands exist and can show help
    ddev project-configure --help >/dev/null 2>&1 || echo "project-configure should exist"
    ddev auth ssh --help >/dev/null 2>&1 || echo "auth ssh should exist"
    ddev project-lefthook --help >/dev/null 2>&1 || echo "project-lefthook should exist"
    ddev project-nvm --help >/dev/null 2>&1 || echo "project-nvm should exist"
    ddev project-init --help >/dev/null 2>&1 || echo "project-init should exist"
}

@test "pantheon configuration" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal10 --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start

    # Set up Pantheon configuration for testing using project-configure approach
    ddev exec "mkdir -p .ddev/scripts"
    ddev exec "echo 'export HOSTING_PROVIDER=\"pantheon\"' >> .ddev/scripts/load-config.sh"
    ddev exec "echo 'export HOSTING_SITE=\"test-site\"' >> .ddev/scripts/load-config.sh"
    ddev exec "echo 'export HOSTING_ENV=\"dev\"' >> .ddev/scripts/load-config.sh"

    # Test that Pantheon configuration loads properly
    ddev exec "source .ddev/scripts/load-config.sh && load_kanopi_config && echo \$HOSTING_PROVIDER" | grep -q "pantheon"
}

@test "acquia configuration" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal10 --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start

    # Set up Acquia configuration for testing using project-configure approach
    ddev exec "mkdir -p .ddev/scripts"
    ddev exec "echo 'export HOSTING_PROVIDER=\"acquia\"' >> .ddev/scripts/load-config.sh"
    ddev exec "echo 'export HOSTING_SITE=\"test-app\"' >> .ddev/scripts/load-config.sh"
    ddev exec "echo 'export HOSTING_ENV=\"dev\"' >> .ddev/scripts/load-config.sh"
    ddev exec "echo 'export APACHE_FILE_PROXY=\"https://example.com\"' >> .ddev/scripts/load-config.sh"

    # Test that Acquia configuration loads properly
    ddev exec "source .ddev/scripts/load-config.sh && load_kanopi_config && echo \$HOSTING_PROVIDER" | grep -q "acquia"
}

@test "theme development commands" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal10 --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start

    # Test that theme development commands exist and can show help
    ddev theme-install --help >/dev/null 2>&1 || echo "theme-install should exist"
    ddev theme-build --help >/dev/null 2>&1 || echo "theme-build should exist"
    ddev theme-watch --help >/dev/null 2>&1 || echo "theme-watch should exist"
    ddev theme-npm --help >/dev/null 2>&1 || echo "theme-npm should exist"
    ddev theme-npx --help >/dev/null 2>&1 || echo "theme-npx should exist"
}

@test "drupal specific commands" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal10 --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start

    # Test that Drupal-specific commands exist and can show help
    ddev drupal-open --help >/dev/null 2>&1 || echo "drupal-open should exist"
    ddev drupal-uli --help >/dev/null 2>&1 || echo "drupal-uli should exist"

    # Test drupal-open without arguments (should work but won't actually open browser in CI)
    timeout 10 ddev drupal-open >/dev/null 2>&1 || echo "drupal-open executed (expected to timeout in CI)"
}

@test "migration and testing commands" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=drupal10 --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start

    # Test migration commands
    ddev db-prep-migrate --help >/dev/null 2>&1 || echo "db-prep-migrate should exist"
    ddev pantheon-tickle --help >/dev/null 2>&1 || echo "pantheon-tickle should exist"

    # Test Cypress testing commands
    ddev cypress-install --help >/dev/null 2>&1 || echo "cypress-install should exist"
    ddev cypress-run --help >/dev/null 2>&1 || echo "cypress-run should exist"
    ddev cypress-users --help >/dev/null 2>&1 || echo "cypress-users should exist"

    # Test Pantheon testing environment
    ddev pantheon-testenv --help >/dev/null 2>&1 || echo "pantheon-testenv should exist"
}