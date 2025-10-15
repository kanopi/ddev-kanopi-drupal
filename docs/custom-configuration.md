# Custom Configuration

Lets gather common scenarios for customizations after the DDEV add-on is installed.

---

## Theming Commands

In the Docksal `install-theme-tools` command, there were some helpers for Critical CSS on M1 machines.

Add this early in the DDEV `theme-install` command.

```
# Critical.
echo -e "Installing tools needed for Critical"
sudo apt update
sudo apt install -yq --no-install-recommends dh-autoreconf libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 libnss3 chromium
```

---

## settings.php Configuration

Here are some things that you may manually have to change in your settings file.

### Trusted Host Patterns

```
$settings['trusted_host_patterns'] = [
  '.*sitename\.pantheonsite\.io',  // Any env from Pantheon
  '.*sitename\.docksal\.site',    //  Docksal
  # Add an entry for DDEV
  '.*pcg\.ddev\.site',
];
```

### Solr Configuration

Add this configuration to web/sites/default/settings.php to connect to DDEV Solr.
Note: Adjust the server machine name to match your project's Search API server.

```php
/**
* DDEV Solr Configuration
* Override Pantheon search configuration when in DDEV environment
*/
if (getenv('IS_DDEV_PROJECT') == 'true') {
 // Override any Pantheon search configuration for DDEV
 $config['search_api.server.pantheon_solr8']['backend_config']['connector_config']['host'] = 'solr';
 $config['search_api.server.pantheon_solr8']['backend_config']['connector_config']['port'] = '8983';
 $config['search_api.server.pantheon_solr8']['backend_config']['connector_config']['path'] = '/';
 $config['search_api.server.pantheon_solr8']['backend_config']['connector_config']['core'] = 'dev';

 // Alternative configuration if using different server name
 $config['search_api.server.solr']['backend_config']['connector_config']['host'] = 'solr';
 $config['search_api.server.solr']['backend_config']['connector_config']['port'] = '8983';
 $config['search_api.server.solr']['backend_config']['connector_config']['path'] = '/';
 $config['search_api.server.solr']['backend_config']['connector_config']['core'] = 'dev';
}
```

If you have a Docksal project, you can find the configuration at /.docksal/conf/settings.php
