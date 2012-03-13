Feature: Manage Wordless-based sites
  
  @long
  Scenario: Install Wordless into an existing WordPress installation
    Given WordPress is already installed
    When I run `wordless install`
    Then the Wordless plugin should be installed