# Wordless

A command line tool to help manage your [Wordless](http://welaika.github.com/wordless/)-based WordPress sites. 

WARNING: This gem is in early development and barely does anything useful yet.

## Installation

    $ gem install wordless

## Usage

- `wordless help` shows some help.
- `wordless wp mysite` creates a `mysite` directory and installs the latest stable release of WordPress.
- `wordless wp --locale=fr_FR --bare` installs the French version of WordPress, and removes default plugins and themes.
- `wordless install` installs the Wordless plugin in the current WordPress installation as a git submodule.

## Caveats

- If you attempt to download a WordPress localization that's outdated, the latest English version will be downloaded instead.
- Currently, the Wordless plugin is installed as a git submodule, so your WordPress directory must be a git repo.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add some specs
4. Commit your changes (`git commit -am 'Added some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
