# Wordless

Command line tools to help manage your [Wordless](http://welaika.github.com/wordless/)-based WordPress sites. 

WARNING: This gem is in early development and barely does anything useful yet.

## Installation

    $ gem install wordless

## Usage

`wordless help` shows some help.
`wordless wp mysite` creates a `mysite` directory and installs the latest stable release of WordPress.
`wordless wp --locale=fr_FR --bare` installs the French version of WordPress, and removes default plugins and themes.
`wordless install` installs the Wordless plugin in the current WordPress installation as a git submodule.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
