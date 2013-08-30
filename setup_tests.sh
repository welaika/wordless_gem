#! /bin/bash

set -e

FIXTURE_PATH="spec/fixtures/wordless"

rm -rf $FIXTURE_PATH

git clone --branch=master git://github.com/welaika/wordless.git $FIXTURE_PATH && cd $FIXTURE_PATH
cp -f ../wordless_preferences.php wordless/theme_builder/vanilla_theme/config/initializers/wordless_preferences.php
git ci -am "updated ruby and compass path"

echo "[OK!]"