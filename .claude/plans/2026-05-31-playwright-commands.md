# Playwright Commands — ddev-kanopi-drupal

Add three Playwright DDEV commands to the Drupal addon, parallel to the existing `cypress-*` commands. Structure mirrors `ddev-kanopi-wp` for consistency; only `playwright-users` differs (uses `drush` instead of `wp-cli`).

The existing `cypress-users` command is the direct model for `playwright-users` — same pattern, same approach, different credentials and additional roles.

---

## Commands to Add

### `commands/host/playwright-install` (new)

Identical logic to `ddev-kanopi-wp` — Playwright always lives at the project root regardless of CMS.

```bash
#!/usr/bin/env bash

## Description: Install Playwright and browsers for e2e testing
## Usage: playwright-install
## Example: "ddev playwright-install"
## Aliases: playwright:install,pwi

#ddev-generated

#-------------------------- Helper functions ------------------------------

green='\033[0;32m'
yellow='\033[1;33m'
NC='\033[0m'
divider='===================================================\n'

#-------------------------- Execution -------------------------------------

echo -e "🚧 ${yellow} Initializing Playwright...${NC} 🚧"
echo -e "${green}${divider}${NC}"

# Make sure NVM works
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Check for package.json at project root
if [ ! -f "${DDEV_APPROOT}/package.json" ]; then
    echo "❌ No package.json found at project root: ${DDEV_APPROOT}"
    echo "Please create a package.json with Playwright dependencies first."
    exit 1
fi

cd "${DDEV_APPROOT}" || exit 1

echo "Installing Playwright dependencies..."
npm install

echo "Installing Playwright browsers..."
npx playwright install --with-deps chromium firefox webkit

echo ""
echo "✅ Playwright installation complete!"
echo "Run tests with: ddev playwright-run"
```

---

### `commands/host/playwright-run` (new)

Same pattern as `cypress-run`. Runs from project root with DDEV primary URL injected as `BASE_URL`.

```bash
#!/usr/bin/env bash

## Description: Run Playwright e2e tests
## Usage: playwright-run [options]
## Example: "ddev playwright-run"
## Example: "ddev playwright-run --reporter=list"
## Example: "ddev playwright-run --ui"
## Example: "ddev playwright-run tests/e2e/specs/smoke.spec.ts"
## Aliases: playwright:run,pwr

#ddev-generated

#-------------------------- Helper functions ------------------------------

green='\033[0;32m'
yellow='\033[1;33m'
NC='\033[0m'
divider='===================================================\n'

#-------------------------- Execution -------------------------------------

# Make sure NVM works
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Check for playwright config at project root
if [ ! -f "${DDEV_APPROOT}/playwright.config.ts" ] && [ ! -f "${DDEV_APPROOT}/playwright.config.js" ]; then
    echo "❌ No playwright.config.ts found at project root"
    echo "Please run 'ddev playwright-install' first."
    exit 1
fi

export BASE_URL="${DDEV_PRIMARY_URL}"
export DRUPAL_USERNAME="playwright"
export DRUPAL_PASSWORD="playwright"

cd "${DDEV_APPROOT}" || exit 1

echo -e "🎭 ${yellow} Running Playwright tests against ${BASE_URL}...${NC}"
echo -e "${green}${divider}${NC}"

npx playwright test "$@"

if [ -d "playwright-report" ]; then
    echo ""
    echo "View HTML report with: npx playwright show-report"
fi
```

---

### `commands/host/playwright-users` (new)

Informed by `cypress-users` — same drush approach, expanded to four role-scoped users. Note on Drupal roles: `administrator` is standard; `editor` and `content_author` are common custom roles but **may need to be adjusted per project** depending on what roles are defined.

```bash
#!/usr/bin/env bash

## Description: Create Playwright test users in Drupal
## Usage: playwright-users
## Example: "ddev playwright-users"
## Aliases: playwright:users,pwu

#ddev-generated

# Abort if anything fails
set -e

echo "Creating test users for Playwright tests..."

# Admin user — administrator role is always present in Drupal
ddev drush user-create playwright --mail="playwright@test.local" --password="playwright" || true
ddev drush user-add-role administrator playwright
echo "Created/updated admin user: playwright / playwright"

# Editor user — 'editor' role must exist in the project; adjust machine name if needed
ddev drush user-create playwright-editor --mail="playwright-editor@test.local" --password="playwright" || true
ddev drush user-add-role editor playwright-editor 2>/dev/null \
    || echo "  Note: 'editor' role not found — add the role manually or adjust this command for your project's roles"
echo "Created/updated editor user: playwright-editor / playwright"

# Author user — adjust role machine name to match your project
ddev drush user-create playwright-author --mail="playwright-author@test.local" --password="playwright" || true
ddev drush user-add-role content_author playwright-author 2>/dev/null \
    || echo "  Note: 'content_author' role not found — adjust the role machine name for your project"
echo "Created/updated author user: playwright-author / playwright"

# Authenticated-only user (no extra role needed — all logged-in Drupal users are 'authenticated')
ddev drush user-create playwright-subscriber --mail="playwright-subscriber@test.local" --password="playwright" || true
echo "Created/updated authenticated user: playwright-subscriber / playwright"

echo ""
echo "=== Test users ready ==="
echo "Admin:       playwright / playwright          (administrator)"
echo "Editor:      playwright-editor / playwright   (editor — verify role name)"
echo "Author:      playwright-author / playwright   (content_author — verify role name)"
echo "Subscriber:  playwright-subscriber / playwright (authenticated only)"
echo ""
echo "Tip: Adjust role machine names in this command to match your project."
```

---

## Files to Modify

### `install.yaml` — add playwright commands to `removal_action`

In the `# Remove host commands` section, add:

```yaml
  rm -f commands/host/playwright-install 2>/dev/null || true
  rm -f commands/host/playwright-run 2>/dev/null || true
  rm -f commands/host/playwright-users 2>/dev/null || true
```

### `README.md` — add to the command reference table

Add these three rows alongside the existing `cypress-*` entries:

| Command | Description |
|---|---|
| `ddev playwright-install` | Install Playwright and browsers at project root |
| `ddev playwright-run [options]` | Run Playwright e2e tests (pass any `npx playwright test` flags) |
| `ddev playwright-users` | Create/update Playwright test users (admin + role-scoped variants) |

### `docs/commands.md` — add to the command table

**Add three rows** to the main table alongside the existing `cypress-*` rows:

```markdown
| `playwright-install` | Install Playwright and browsers for e2e testing                   | `ddev playwright-install`        | `playwright:install`, `pwi`      | Host |
| `playwright-run [options]` | Run Playwright e2e tests                                    | `ddev playwright-run --ui`       | `playwright:run`, `pwr`          | Host |
| `playwright-users`   | Create Playwright test users in Drupal                            | `ddev playwright-users`          | `playwright:users`, `pwu`        | Host |
```

**Update the command count** in the opening paragraph from "27 custom commands" to "30 custom commands".

---

## Implementation Order

1. Create `commands/host/playwright-install`
2. Create `commands/host/playwright-run`
3. Create `commands/host/playwright-users`
4. Update `install.yaml` removal_action
5. Update `README.md`
6. Update `docs/commands.md`
7. Commit, tag, push
8. In each consuming project: `ddev add-on update ddev-kanopi-drupal` then `ddev restart`

---

## Drupal-Specific Notes

- `playwright-users` creates a `playwright` admin and three additional role-scoped users, but Drupal role machine names are project-defined. The command uses `editor`, `content_author`, and `authenticated` as starting defaults — override them in a project-local `playwright-users` script if needed.
- The `playwright-subscriber` user intentionally has no added role; all Drupal users already have `authenticated`. This mirrors the WordPress subscriber pattern (read-only access).
- The `cypress-users` command creates a single `cypress` admin. `playwright-users` expands on this by adding role-scoped variants for more granular test coverage.
