#! /bin/bash

set -e

FIXTURE_PATH="spec/fixtures/wordless"
WORDLESS_ARCHIVE="https://github.com/welaika/wordless/archive/master.tar.gz"
WORDLESS_PREFERENCES="wordless/theme_builder/vanilla_theme/config/initializers/wordless_preferences.php"

function log {
  echo;
  echo "== [ $1 ] ==";
}

log "Deleting {$FIXTURE_PATH}..."
rm -rf $FIXTURE_PATH
mkdir -p $FIXTURE_PATH
echo "Done!"

log "Downloading wordless from github..."
cd $FIXTURE_PATH
wget $WORDLESS_ARCHIVE -O - | tar -xz --strip 1
echo "Done!"
