source 'https://rubygems.org'

gemspec

gem 'rails', github: 'rails/rails'

group :production do
  gem 'puma'
  gem 'pg'
  gem 'devise'
  gem 'devise_token_auth', github: 'lynndylanhurley/devise_token_auth'
  gem 'mongoid', github: 'mongodb/mongoid'
end

group :development do
  gem 'bullet'
end

group :test do
  gem 'rails-controller-testing'
  gem 'ammeter'
  gem 'timecop'
  gem 'committee'
  gem 'committee-rails'
  # gem 'coveralls', require: false
  gem 'coveralls_reborn', require: false
end

gem 'webpacker', groups: [:production, :development]
gem 'rack-cors', groups: [:production, :development]
gem 'dotenv-rails', groups: [:development, :test]
