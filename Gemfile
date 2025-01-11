source "https://rubygems.org"

ruby "3.4.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.1"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "stimulus-rails"
gem "bcrypt", "~> 3.1.7"
gem "importmap-rails"
gem "jbuilder"
gem "haml"
gem "propshaft"
gem "puma", ">= 6.0"
gem "sqlite3", ">= 2.1"
gem "tailwindcss-rails"
gem "turbo-rails"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

gem "image_processing", "~> 1.2"
gem "class_variants"

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
