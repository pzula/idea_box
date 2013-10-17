ENV["RACK_ENV"] = "test"
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/idea_box/idea_store.rb'

class IdeaTest < Minitest::Test



end