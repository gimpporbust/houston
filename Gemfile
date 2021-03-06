source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "~> 4.1.0"

gem "pg"

gem "activerecord-import"
gem "addressable", require: "addressable/uri"
gem "bundler" # used to parse Gemfiles
gem "cancan"
gem "childprocess"
gem "codeclimate-test-reporter", "0.4.1" # locked because Houston implements its API
gem "default_value_for"
gem "devise", "~> 3.0.0"
gem "devise_invitable"
gem "devise_ldap_authenticatable", git: "https://github.com/houstonmc/devise_ldap_authenticatable.git"
gem "faraday"
gem "faraday-http-cache"
gem "faraday-raise-errors", github: "boblail/faraday-raise-errors", branch: "master"
gem "gemoji"
gem "gemnasium"
gem "googlecharts"
gem "hpricot"
gem "nokogiri"
gem "oauth-plugin", github: "houstonmc/oauth-plugin", branch: "master"
gem "octokit" # for adapting to GitHub Issues
gem "oj"
gem "pg_search"
gem "premailer" #, "1.7.3" # for inlining CSS in HTML emails
gem "progressbar" # for long migrations
gem "redcarpet"
gem "rufus-scheduler"
gem "rugged" # for speaking to Git
gem "simplecov"
gem "strongbox" # for encrypting user credentials
gem "sucker_punch" # for Airbrake
gem "unfuddle", github: "boblail/unfuddle", branch: "master"
gem "vestal_versions", github: "houstonmc/vestal_versions", branch: "master"
gem "whenever", "0.9.2" # a DSL for writing CRON jobs
gem "xlsx", github: "concordia-publishing-house/xlsx", branch: "master"

# Tooling
gem "airbrake"
gem "skylight"



# Modules
#
# Here modules are dynamically included in the Gemfile
#
root = File.dirname(__FILE__)
root = "./#{root}" unless root.start_with?("/")
require File.join(root, "lib/configuration.rb") # Loads Houston's configuration
Houston.config.gems.each do |gemspec|
  gem *gemspec
end


# Use SCSS for stylesheets
gem "sass-rails", "~> 4.0.0"

# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"

# Use CoffeeScript for .js.coffee assets and views
gem "coffee-rails", "~> 4.0.0"

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem "therubyracer", platforms: :ruby

# Precompiler for handlebars
gem "handlebars_assets"

# Source for unprecompiled assets
gem "backbone-rails", "~> 1.0.0"
gem "jquery-rails", "2.2.1"
gem "sugar-rails"
gem "neat-rails", github: "boblail/neat-rails", branch: "master"

group :development do
  gem "unicorn-rails"
  gem "letter_opener"
  gem "spring"
  # gem "rack-mini-profiler"
  
  # Better error messages
  gem "better_errors"
  gem "meta_request"
end

group :development, :test do
  gem "pry" # for debugging
end

gem "idioms", github: "concordia-publishing-house/idioms", branch: "master"

group :test do
  gem "minitest"
  gem "capybara"
  gem "shoulda-context"
  gem "timecop"
  gem "rr"
  gem "webmock", require: "webmock/minitest"
  gem "factory_girl_rails"
  
  # For Jenkins
  gem "simplecov-json", require: false, git: "git://github.com/houstonmc/simplecov-json.git"
  gem "minitest-reporters", require: false
end
