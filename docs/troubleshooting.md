# Troubleshooting

Common issues and solutions for the DDEV Kanopi Drupal Add-on.

## Installation Issues

### Add-on Installation Fails

**Problem**: `ddev add-on get kanopi/ddev-kanopi-drupal` fails

**Solutions**:
```bash
# Ensure DDEV is up to date
ddev version
# Update if needed: brew upgrade ddev

# Try installing from GitHub directly
ddev add-on get https://github.com/kanopi/ddev-kanopi-drupal

# Check DDEV add-on list
ddev add-on list --available
```

### Interactive Configuration Hangs

**Problem**: Configuration prompts don't appear or hang

**Solutions**:
```bash
# Set non-interactive mode and reconfigure
export DDEV_NONINTERACTIVE=true
ddev add-on get kanopi/ddev-kanopi-drupal

# Then configure manually
ddev project-configure
```

## Authentication Issues

### Pantheon Authentication

**Problem**: `ddev pantheon-terminus` commands fail with authentication errors

**Solutions**:
```bash
# Check if token is set globally
ddev exec printenv TERMINUS_MACHINE_TOKEN

# If not set, configure globally
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token

# Test authentication
ddev pantheon-terminus auth:whoami

# Re-authenticate manually if needed
ddev pantheon-terminus auth:login --machine-token="your_token"
```

### Acquia Authentication

**Problem**: Acquia commands fail with API authentication errors

**Solutions**:
```bash
# Check API credentials
ddev exec printenv ACQUIA_API_KEY
ddev exec printenv ACQUIA_API_SECRET

# Set if missing
ddev config global --web-environment-add=ACQUIA_API_KEY=your_key
ddev config global --web-environment-add=ACQUIA_API_SECRET=your_secret

# Test authentication
ddev exec acli auth:login --key="your_key" --secret="your_secret"
ddev exec acli api:applications:find
```

## Database Issues

### Database Refresh Fails

**Problem**: `ddev db-refresh` fails or times out

**Solutions**:
```bash
# Check hosting provider connection
ddev pantheon-terminus site:list  # For Pantheon
ddev exec acli api:applications:find  # For Acquia

# Force new backup creation
ddev db-refresh -f

# Check environment variables
ddev exec env | grep -E "(HOSTING|TERMINUS|ACQUIA)"

# Manual backup download (Pantheon)
ddev pantheon-terminus backup:create my-site.dev --element=database --keep=180
ddev pantheon-terminus backup:get my-site.dev --element=database --to=/tmp/backup.sql.gz
```

### Database Connection Errors

**Problem**: Drupal can't connect to database

**Solutions**:
```bash
# Restart DDEV
ddev restart

# Check database service
ddev describe

# Test database connection
ddev exec mysql -e "SHOW DATABASES;"

# Check Drupal settings
ddev exec drush status
```

## Theme Development Issues

### Theme Tools Installation Fails

**Problem**: `ddev theme-install` fails or can't find `.nvmrc`

**Solutions**:
```bash
# Check theme path configuration
ddev exec printenv THEME
ddev exec ls -la $THEME

# Create .nvmrc file if missing
echo "18" > themes/custom/mytheme/.nvmrc

# Check if Node.js is available
ddev exec node --version
ddev exec npm --version

# Reinstall NVM
ddev project-nvm
```

### Theme Watch/Build Issues

**Problem**: `ddev theme-watch` or `ddev theme-build` fail

**Solutions**:
```bash
# Check theme directory and package.json
ddev exec ls -la $THEME
ddev exec cat $THEME/package.json

# Install dependencies
ddev theme-npm install

# Check for build scripts in package.json
ddev exec jq '.scripts' $THEME/package.json

# Run specific NPM commands
ddev theme-npm run build
ddev theme-npm run dev
```

## Recipe Development Issues

### Recipe Application Fails

**Problem**: `ddev recipe-apply` fails with errors

**Solutions**:
```bash
# Check recipe structure
ls -la ../recipes/my-recipe/
cat ../recipes/my-recipe/recipe.yml

# Clear caches before applying
ddev drush cache:rebuild
ddev recipe-apply ../recipes/my-recipe

# Check Drupal logs
ddev drush watchdog:show --count=20
```

## Service Issues

### Redis/Memcached Not Working

**Problem**: Caching service not responding

**Solutions**:
```bash
# Check running containers
docker ps | grep ddev-projectname

# For Pantheon (Redis)
ddev exec redis-cli ping
docker logs ddev-projectname-redis

# For Acquia (Memcached)
ddev exec "echo stats | nc memcached 11211"
docker logs ddev-projectname-memcached

# Restart services
ddev restart
```

### Solr Search Issues

**Problem**: Search functionality not working

**Solutions**:
```bash
# Check Solr container
docker ps | grep solr
docker logs ddev-projectname-solr

# Test Solr connection
curl http://localhost:8983/solr/

# Check Drupal Solr configuration in settings.php
```

## Proxy Configuration Issues

### Assets Not Loading (Pantheon)

**Problem**: Images/files from Pantheon not displaying locally

**Solutions**:
```bash
# Check nginx proxy configuration
cat .ddev/nginx_full/nginx-site.conf

# Test proxy URL manually
curl -I https://dev-mysite.pantheonsite.io/sites/default/files/test-image.jpg

# Check environment variables
ddev exec printenv | grep HOSTING
```

### File Proxy Not Working (Acquia)

**Problem**: Missing files not proxying from Acquia

**Solutions**:
```bash
# Check .htaccess file proxy rules
grep -A 10 "File proxy DDEV" web/.htaccess

# Check Apache configuration
ddev exec apache2ctl -t

# Check environment variable
ddev exec printenv APACHE_FILE_PROXY

# Test proxy URL
curl -I https://yourdomain.acquia.com/sites/default/files/test-image.jpg
```

## Performance Issues

### Slow Database Operations

**Problem**: Database imports/exports are very slow

**Solutions**:
```bash
# Increase PHP memory and time limits
echo "memory_limit = 2G" >> .ddev/config/php/php.ini
echo "max_execution_time = 0" >> .ddev/config/php/php.ini
ddev restart

# Use compression for large databases
ddev db-refresh -f  # Forces new compressed backup
```

### Theme Build Performance

**Problem**: Theme builds are slow or consume too much memory

**Solutions**:
```bash
# Increase Node.js memory limit
ddev theme-npx --max_old_space_size=4096 webpack

# Check for memory leaks in build process
ddev theme-npm run build -- --analyze

# Use production mode for final builds
NODE_ENV=production ddev theme-build
```

## CI/CD and Testing Issues

### GitHub Actions Failing

**Problem**: Add-on tests failing in CI

**Solutions**:
```bash
# Run tests locally first
./tests/test-install.sh

# Check test environment
bats tests/test.bats

# Debug specific test failures
ddev describe
ddev logs
```

### Cypress Tests Failing

**Problem**: E2E tests not running properly

**Solutions**:
```bash
# Ensure test users exist
ddev cypress-users

# Check Cypress installation
ddev exec cypress version

# Run tests in debug mode
ddev cypress-run open --env configFile=cypress.config.js

# Check test database
ddev exec drush user:information admin
```

## Environment-Specific Issues

### Multidev Environment Issues (Pantheon)

**Problem**: Can't create or access multidev environments

**Solutions**:
```bash
# Check multidev limit
ddev pantheon-terminus multidev:list my-site

# Create new multidev
ddev pantheon-testenv my-feature

# Switch database source
ddev db-refresh my-feature
```

### Multiple Environment Management (Acquia)

**Problem**: Confusion with dev/stg/prod environments

**Solutions**:
```bash
# List available environments
ddev exec acli api:environments:find your-app-uuid

# Set default environment
ddev config --web-environment-add HOSTING_ENV=prod

# Refresh from specific environment
ddev db-refresh prod -f
```

## Getting Additional Help

### Debug Information

Collect debug information when reporting issues:

```bash
# System information
ddev version
docker version
docker-compose version

# Project information
ddev describe
ddev config

# Environment variables
ddev exec env | grep -E "(HOSTING|THEME|TERMINUS|ACQUIA)"

# Service status
docker ps | grep ddev-projectname
ddev logs
```

### Log Files

Check relevant log files:

```bash
# DDEV logs
ddev logs

# Service-specific logs
docker logs ddev-projectname-web
docker logs ddev-projectname-db
docker logs ddev-projectname-redis

# Drupal logs
ddev drush watchdog:show
```

### Community Support

- **[GitHub Issues](https://github.com/kanopi/ddev-kanopi-drupal/issues)** - Report bugs and request features
- **[DDEV Discord](https://discord.gg/5wjP76mBJD)** - General DDEV community support
- **[Kanopi Studios](https://kanopi.com/contact)** - Professional Drupal support

## Common Error Messages

### "Command not found"

**Error**: `ddev: command not found: theme-install`

**Solution**: Command may conflict with existing DDEV commands or installation may be incomplete:
```bash
# Reinstall add-on
ddev add-on remove kanopi-drupal
ddev add-on get kanopi/ddev-kanopi-drupal

# Check command availability
ddev help | grep theme
```

### "Permission denied"

**Error**: Permission denied errors when running commands

**Solution**: Check file permissions and Docker setup:
```bash
# Fix file permissions
chmod +x .ddev/commands/host/*
chmod +x .ddev/commands/web/*

# Restart DDEV
ddev restart
```

### "Network timeout" / "Connection refused"

**Error**: Network-related errors during operations

**Solutions**:
```bash
# Check internet connection
ping pantheonsite.io  # or acquia.com

# Check DNS resolution
nslookup dev-mysite.pantheonsite.io

# Try with different DNS
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf

# Restart Docker
docker system restart  # or Docker Desktop restart
```

Remember to always check the [official documentation](https://kanopi.github.io/ddev-kanopi-drupal/) for the most up-to-date troubleshooting information.
