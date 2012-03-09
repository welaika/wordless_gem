Then /^the Wordless plugin should be installed$/ do
  plugin_root = 'wp-content/plugins/wordless'
  steps %Q{
    Then the following files should exist:
      | #{plugin_root}/wordless.php          |
      | #{plugin_root}/wordless/wordless.php |
  }
end

Then /^a Wordless theme called "([^"]*)" should exist$/ do |name|
  theme_root = "wp-content/themes/#{name}"
  steps %Q{
    Then the following files should exist:
      | #{theme_root}/index.php                                    |
      | #{theme_root}/style.css                                    |
      | #{theme_root}/config/initializers/wordless_preferences.php |
  }
end