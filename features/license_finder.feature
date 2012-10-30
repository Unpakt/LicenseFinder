Feature: License Finder command line executable
  So that I can report and manage my application's dependencies and licenses to my business
  As an application developer
  I want a command-line interface

  Scenario: Running without a configuration file
    Given I have an app with license finder
    And my app does not have a "config" directory
    When I run "license_finder"
    Then I should see a "config" directory
    And I should see the file "config/license_finder.yml" with the following content:
      """
      ---
      whitelist:
      #- MIT
      #- Apache 2.0
      ignore_groups:
      #- test
      #- development
      dependencies_file_dir: './'
      """

  Scenario: Running with an empty dependencies.yml
    Given I have an app with license finder
    And my app depends on a gem "mit_licensed_gem" licensed with "MIT"
    And I have a truncated dependencies.yml file
    When I run "license_finder"
    Then it should exit with status code 1
    And I should see "mit_licensed_gem" in its output

  Scenario: Auditing an application with non-whitelisted licenses
    Given I have an app with license finder
    And my app depends on a gem "mit_licensed_gem" licensed with "MIT"
    When I run "license_finder"
    Then it should exit with status code 1
    And I should see "mit_licensed_gem" in its output

  Scenario: Auditing an application with whitelisted licenses
    Given I have an app with license finder
    And my app depends on a gem "mit_licensed_gem" licensed with "MIT"
    When I run "license_finder"
    Then I should see "mit_licensed_gem" in its output
    When I whitelist the following licenses: "MIT, other"
    And I run "license_finder"
    Then I should see "All gems are approved for use" in its output
    And it should exit with status code 0

  Scenario: Merging a legacy dependencies.yml file
    Given I have an app with license finder
    And my app depends on a gem "random_licensed_gem" licensed with "random_license"
    And I have a legacy dependencies.yml file with "random_licensed_gem" approved with its "random_license" license
    And I whitelist the following licenses: "MIT, other"
    When I run "license_finder"
    Then I should see exactly one entry for "random_licensed_gem" in "dependencies.yml"
    And I should see "All gems are approved for use" in its output
    And it should exit with status code 0
