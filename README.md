# Wordless

A command line tool to help manage your [Wordless](http://welaika.github.com/wordless/)-based WordPress sites. 

## Installation

    gem install wordless

## Usage

Create a new Wordless-enabled WordPress site in directory `mysite`. This downloads the latest stable release of WordPress (you can also specify a locale):

    wordless new mysite
    wordless new mysite --locale=fr_FR

If you already have WordPress installed, you can install the Wordless plugin (this currently installs from the master branch on GitHub):

    wordless install

Once Wordless is installed, you can create a new Wordless theme:

    wordless theme mytheme

Compile your site's static assets:

    wordless compile

Clean your compiled static assets:

    wordless clean

Deploy your wordless installation using the `deploy_command` specified in your Wordfile:

    wordless deploy

You can also use the refresh option `-r` to compile your assets before deploying and clean your assets after:

    wordless deploy -r

Get some help:

    wordless help

## Configuration

You can create a Wordfile to customize the behaviour of wordless:

```yaml
wordless_repo: 'git://github.com/welaika/wordless.git'
static_css:
  - 'wp-content/themes/mytheme/assets/stylesheets/screen.css'
  - 'wp-content/themes/mytheme/assets/stylesheets/print.css'
static_js:
  - 'wp-content/themes/mytheme/assets/javascripts/application.js'
  - 'wp-content/themes/mytheme/assets/javascripts/mobile.js'
deploy_command: 'wordmove push -du'
```

## Caveats

- If you attempt to download a WordPress localization that's outdated, the latest English version will be downloaded instead.
- Only tested on Mac OS X

## Running specs

Clone the wordless repo inside `spec/fixtures/wordless`:

    git clone https://github.com/welaika/wordless.git spec/fixtures/wordless && cd spec/fixtures/wordless

Set your compass and ruby paths:

    vim wordless/theme_builder/vanilla_theme/config/initializers/wordless_preferences.php

Commit your changes:

    git commit -am "Set compass and ruby paths"

Go back to the wordless_gem directory and have fun:

    cd - && rspec

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add some specs
4. Commit your changes (`git commit -am 'Added some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
