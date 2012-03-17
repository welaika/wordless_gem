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

You can also simply install the latest stable release of WordPress, with an optional locale:

    wordless wp mysite
    wordless wp mysite --locale=fr_FR

Get some help:

    wordless help

## Caveats

- If you attempt to download a WordPress localization that's outdated, the latest English version will be downloaded instead.
- Only tested on Mac OS X
- Specs that test installation of the plugin actually download the plugin from GitHub. This makes the specs a bit slow to run.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add some specs
4. Commit your changes (`git commit -am 'Added some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
