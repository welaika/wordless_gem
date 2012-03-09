Feature: Create Wordless sites
  In order to infuse a healthy dose of Rails culture into my WordPress development habits
  As a WordPress developer
  I want to be able to easily create a new Wordless-enabled WordPress site
  
  Scenario: Create a plain new Wordless site
    When I run `wordless new mysite`
    Then a WordPress installation should exist
    And the Wordless plugin should be installed
    And a Wordless theme called "mysite" should exist

  
