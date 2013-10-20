ENV["RACK_ENV"] = "test"
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/idea_box/idea_store.rb'

class IdeaTest < Minitest::Test

  def setup
    data = {"title" => "A new idea",
            "description" => "Is awesome"}
    IdeaStore.create(data)
  end

  def teardown
    IdeaStore.destroy
  end

  def sample_data
      {"title" => "A cooler idea",
      "description" => "For refridgerators"}
  end

  def test_it_creates_a_database
    assert IdeaStore.database
  end

  def test_it_returns_first_object_in_database
    idea = IdeaStore.all.first
    assert_equal "A new idea", idea.title
    assert_equal "Is awesome", idea.description
    assert_equal 0, idea.rank
    assert idea.id
  end

  def test_it_returns_multiple_objects_in_database
    IdeaStore.create(sample_data)
    assert_equal 2, IdeaStore.all.count
    assert_equal "A cooler idea", IdeaStore.all.last.title
    assert_equal "For refridgerators", IdeaStore.all.last.description
  end

  def test_it_returns_proper_id_for_next_object
    assert_equal 2, IdeaStore.next_id
    IdeaStore.create(sample_data)
    assert_equal 3, IdeaStore.next_id
  end

  def test_it_finds_an_object
    IdeaStore.create(sample_data.merge("id" => 2))
    assert_equal "A cooler idea", IdeaStore.find(2).title
    assert_equal "A new idea", IdeaStore.find(1).title
  end

  def test_it_can_update_data
    IdeaStore.create(sample_data.merge("id" => 2))
    IdeaStore.update(2, "title" => "A better idea",
                        "description" => "Run",
                        "rank" => 2 )
    assert_equal "A better idea", IdeaStore.find(2).title
    assert_equal 2, IdeaStore.find(2).rank
  end

  def test_that_likes_are_persisted
    idea = IdeaStore.all.first
    idea.like!
    idea.update
    assert_equal 1, IdeaStore.all.first.rank
  end

  def test_that_it_gets_deleted
    IdeaStore.delete(1)
    assert_equal 0, IdeaStore.all.count
  end

end