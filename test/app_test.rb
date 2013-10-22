ENV["RACK_ENV"] = "test"
require './test/test_helper'
require 'rack/test'
require './lib/app.rb'

class AppTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    IdeaBoxApp
  end

  def teardown
    IdeaStore.destroy
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
    post '/', idea: {title: 'costume', description: "scary vampire"}

    assert_equal 1, IdeaStore.all.count

    idea = IdeaStore.all.first
    assert_equal "costume", idea.title
    assert_equal "scary vampire", idea.description
  end

  def test_edit_idea
    skip
    idea = IdeaStore.create Idea.new({'title' => 'sing', 'description' => 'happy songs'}).to_h

    put "/#{idea}", idea: {title: 'yodle', description: 'joyful songs'}

    assert_equal 302, last_response.status

    idea = IdeaStore.find(id)
    assert_equal 'yodle', idea.title
    assert_equal 'joyful songs', idea.description
  end




end