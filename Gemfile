source 'https://rubygems.org'

gem 'rails'
gem 'rails-i18n'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'bcrypt'
gem 'github-markdown'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'

group :development, :test do
  gem 'spring'
  gem 'sqlite3', git: "https://github.com/sparklemotion/sqlite3-ruby"
  gem 'rails-controller-testing'
  gem 'capistrano', '~> 3.10.2'
  gem 'capistrano-rvm'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
end

group :production do
  gem 'pg'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
