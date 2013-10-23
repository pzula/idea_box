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
    skip
    assert IdeaBoxApp
  end

  def test_homepage_route_returns_ok
    skip
    get '/'
    assert last_response.ok?
  end

  def test_idea_list
    skip
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
    post '/', idea: {title: 'costume', description: "scary vampire", tags: "fun, idea"}

    assert_equal 1, IdeaStore.all.count

    idea = IdeaStore.all.first
    assert_equal "costume", idea.title
    assert_equal "scary vampire", idea.description
    assert_equal ["fun", "idea"], idea.tags
  end

  def test_edit_idea
    skip
    IdeaStore.create({'title' => 'sing', 'description' => 'happy songs'})
    idea = IdeaStore.all.first
    put "/#{idea.id}", idea: {title: 'yodle', description: 'joyful songs', tags: 'songs'}

    assert_equal 302, last_response.status

    idea = IdeaStore.find(idea.id)
    assert_equal 'yodle', idea.title
    assert_equal 'joyful songs', idea.description
    assert_equal ['songs'], idea.tags
  end

  def test_delete_idea
    skip
    IdeaStore.create({'title' => 'breathe', 'description' => 'fresh air in the mountains'})
    idea = IdeaStore.all.first
    assert_equal 1, IdeaStore.all.count

    delete "/#{idea.id}"

    assert_equal 302, last_response.status
    assert_equal 0, IdeaStore.all.count
  end

  def test_search_results
    skip
    IdeaStore.create({'title' => 'breathe', 'description' => 'fresh air in the mountains'})

    get '/search/results?phrase=fresh+air'

    assert_match /fresh air/, last_response.body
  end

  def test_an_idea_can_be_created_via_sms
    assert_equal 0, IdeaStore.all.count

    url = '/sms'
    params = {"Body" => "Breathe :: fresh air in the mountains # outdoors, air, colorado"}

    get url, params

    assert_equal 1, IdeaStore.all.count
    idea = IdeaStore.all.last
    assert_equal "Breathe", idea.title
    assert_equal "fresh air in the mountains", idea.description
    assert_equal ["outdoors", "air", "colorado"], idea.tags
  end



end