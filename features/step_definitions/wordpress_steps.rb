Then /^a WordPress installation should exist$/ do
  steps %Q{
    Then the following files should exist:
      | index.php            |
      | wp-activate.php      |
      | wp-config.sample.php |
      | wp-settings.php      |
    Then the following directories should exist:
      | wp-content  |
      | wp-admin    |
      | wp-includes |
  }
end