require 'rubygems'
require 'bundler/setup'

require 'rspec'

require 'time'

Dir['./spec/support/**/*.rb'].map {|f| require f}

$:.push File.expand_path("../lib", __FILE__)
require 'pachube_data_formats'

require File.dirname(__FILE__) + '/fixtures/models.rb'

