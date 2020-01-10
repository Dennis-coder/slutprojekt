require 'bundler'

require_relative 'models/DBEntity.rb'

Dir.glob('models/*.rb') { |model| require_relative model }

Bundler.require

require_relative 'app'

run Application