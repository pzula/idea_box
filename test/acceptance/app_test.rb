ENV["RACK_ENV"] = "test"
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'rack/test'
require './lib/app.rb'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    IdeaBoxApp
  end

  def test_it_exists
    assert IdeaBoxApp
  end

  def test_homepage_route_returns_ok
    get '/'
    assert last_response.ok?
  end

end