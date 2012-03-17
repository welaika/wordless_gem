# Wordless

A command line tool to help manage your [Wordless](http://welaika.github.com/wordless/)-based WordPress sites. 

WARNING: This gem is in early development and barely does anything useful yet.

## Installation

    gem install wordless

## Usage

Get some help:

    wordless help

Install the latest stable release of WordPress in directory `mysite`. You can also specify a locale:

    wordless wp mysite
    wordless wp mysite --locale=fr_FR

If you don't want the default plugins and themes, use the `--bare` (or `-b`) option:

    wordless wp --bare

Install the Wordless plugin in the current WordPress installation (this currently installs from GitHub):

    wordless install

Create a new Wordless theme:

    wordless theme mytheme

## Caveats

- If you attempt to download a WordPress localization that's outdated, the latest English version will be downloaded instead.
- Has not been tested under Windows.
- Running the specs is very verbose because of terminal output. If anyone knows how to silence it, a pull request will be very appreciated.
- Specs that test installation of the plugin actually download the plugin from GitHub. This makes the specs a bit slow to run.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add some specs
4. Commit your changes (`git commit -am 'Added some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
