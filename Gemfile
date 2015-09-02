source 'https://rubygems.org'

%w[rspec rspec-core rspec-expectations rspec-mocks rspec-support].each do |lib|
      gem lib, :git => "git://github.com/rspec/#{lib}.git", :branch => 'master'
end

gem 'activerecord', '~> 4.1.8'
gem 'activerecord-jdbc-adapter', '~> 1.3', platform: :jruby
gem 'activerecord-jdbcpostgresql-adapter', platform: :jruby
gem 'pg', platform: :mri
gem 'jdbc-postgres', platform: :jruby
gem 'net-ssh'
gem 'safe_attributes'
gem 'highline'
gem 'pry'
gem 'celluloid'
