ENV["RACK_ENV"] = "test"
require './test/test_helper'
require 'rack/test'
require './lib/app.rb'

class AppTest < MiniTest::Unit::TestCase
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

  def test_idea_list
    IdeaStore.create({"title" => "dinner", "description" => "spaghetti and meatballs"})
    IdeaStore.create({"title" => "drinks", "description" => "imported beers"})
    IdeaStore.create({"title" => "movie", "description" => "The Matrix"})

    get '/'

    [
      /dinner/, /spaghetti/,
      /drinks/, /imported beers/,
      /movie/, /The Matrix/
    ].each do |content|
      assert_match content, last_response.body
    end
  end

  def test_create_idea
    skip
    post '/', {"title" => "costume", "description" => "scary vampire"}

    assert_equal 1, IdeaStore.count

    idea = IdeaStore.all.first
    assert_equal "costume", idea.title
    assert_equal "scary vampire", idea.description
  end



end