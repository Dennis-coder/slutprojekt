require 'bundler'

Dir.glob('models/*.rb') { |model| require_relative model }

Bundler.require

require_relative 'app'

run Application