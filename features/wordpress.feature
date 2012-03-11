Feature: Install WordPress

  @announce @long
  Scenario: Create a plain new WordPress site
    When I run `wordless wp`
    Then a WordPress installation should exist
