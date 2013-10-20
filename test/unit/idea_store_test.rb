ENV["RACK_ENV"] = "test"
require './test/test_helper'
require './lib/idea_box/idea_store.rb'

class IdeaTest < MiniTest::Unit::TestCase

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

  def test_it_can_find_all_ideas_with_certain_tag
    IdeaStore.create(sample_data.merge("tags" => "app,
                                                  new_tech,
                                                  lifestyle"))
    IdeaStore.create( "title" => "Dinner",
                      "description" => "Use menu generator",
                      "tags" => "food,
                        cooking,
                        quantified_self,
                        lifestyle,
                        new_tech")
    assert_equal 2, IdeaStore.find_all_by_tag("new_tech").count
    assert_equal 2, IdeaStore.find_all_by_tag("lifestyle").count
    assert_equal 1, IdeaStore.find_all_by_tag("app").count
    assert_equal 1, IdeaStore.find_all_by_tag("cooking").count
    assert_equal 1, IdeaStore.find_all_by_tag("quantified_self").count
  end

  def test_it_can_find_all_ideas_sorted_by_tag_alphabetically
    IdeaStore.create(sample_data.merge("tags" => "app,
                                                  new_tech,
                                                  lifestyle"))
    IdeaStore.create(sample_data.merge("tags" => "food,
                        cooking,
                        quantified_self"))
    assert_equal 6, IdeaStore.all_tags.count
    assert_equal ["app", "cooking", "food", "lifestyle", "new_tech", "quantified_self"], IdeaStore.all_tags
  end

  def test_all_tags_only_counts_tag_once
    IdeaStore.create(sample_data.merge("tags" => "app,
                                                  new_tech,
                                                  lifestyle"))
    IdeaStore.create( "title" => "Dinner",
                      "description" => "Use menu generator",
                      "tags" => "food,
                        cooking,
                        quantified_self,
                        lifestyle,
                        new_tech")
    assert_equal ["app", "cooking", "food", "lifestyle", "new_tech", "quantified_self"], IdeaStore.all_tags
  end

end