$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require "priscilla"
require "pry-byebug"

require "wordless"

module WordpressStructure
  TMP_PATH = File.expand_path('../tmp', __dir__).freeze
  WORDPRESS_PATH = File.join(TMP_PATH, "wordpress").freeze

  def make_all_wordpress_paths!
    make_wordpress_path!
    make_wpcontent_path!
    make_plugins_path!
    make_themes_path!
  end

  def make_wordpress_path!
    FileUtils.mkdir_p(WORDPRESS_PATH)
  end

  def make_wpcontent_path!
    FileUtils.mkdir_p(File.join(WORDPRESS_PATH, "wp-content"))
  end

  def make_plugins_path!
    FileUtils.mkdir_p(File.join(WORDPRESS_PATH, "wp-content", "plugins"))
  end

  def make_themes_path!
    FileUtils.mkdir_p(File.join(WORDPRESS_PATH, "wp-content", "themes"))
  end

  def install_wordless!
    FileUtils.cp_r(
      File.expand_path('fixtures/wordless', __dir__),
      File.join(WORDPRESS_PATH, "wp-content", "plugins")
    )
  end

  def in_wordpress_path
    make_wordpress_path!

    original_dir = Dir.pwd
    Dir.chdir(WORDPRESS_PATH)
    begin
      yield
    ensure
      Dir.chdir(original_dir)
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.warnings = false

  config.default_formatter = "doc" if config.files_to_run.one?

  config.order = :random

  config.include WordpressStructure
  config.after(:each) do
    if Dir.exist?(WordpressStructure::TMP_PATH)
      FileUtils.rm_rf(Dir.glob("#{WordpressStructure::TMP_PATH}/*"))
    end
  end
end
