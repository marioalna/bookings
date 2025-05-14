source "https://rubygems.org"

ruby "3.3.6"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "stimulus-rails"
gem "bcrypt", "~> 3.1.7"
gem "class_variants"
gem "importmap-rails"
gem "jbuilder"
gem "haml"
gem "image_processing", "~> 1.2"
gem "kamal", require: false
gem "propshaft"
gem "puma", ">= 6.0"
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "sqlite3", ">= 2.1"
gem "requestjs-rails"
gem "tailwindcss-rails", "4.1.0"
gem "tailwindcss-ruby", "4.1.6"
gem "turbo-rails"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "faker"
  gem "parallel_tests"
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "hotwire-spark"
  gem "letter_opener"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "database_cleaner"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
end
