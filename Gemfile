source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

gem "bunnish", ">= 0.1.0"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem "rspec", ">= 2.8.0"
  gem "rdoc", "~> 3.12"
  gem "bundler", ">= 1.0.0"
  gem "jeweler", "~> 1.8.4"
  if RUBY_VERSION <= '1.8.7'
    gem "rcov", ">= 0"
  else
    gem "simplecov", ">= 0"
    gem "simplecov-rcov", ">= 0"
  end
  gem "ci_reporter", ">= 1.7.0"
  gem "flog", ">= 3.2.0"
end