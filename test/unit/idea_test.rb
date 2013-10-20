require './test/test_helper'
require './lib/idea_box/idea.rb'
require './lib/idea_box/idea_store.rb'

class IdeaTest < Minitest::Test

  def teardown
    IdeaStore.destroy
  end

  def test_it_can_initialize_on_a_hash_of_data
    data = { "title" => "New idea!",
           "description" => "Really awesome app"
          }
    idea = Idea.new(data)
    assert_equal "New idea!", idea.title
    assert_equal "Really awesome app", idea.description
    assert_equal 0, idea.rank
  end

  def test_it_can_save
    data = { "title" => "New idea!",
           "description" => "Really awesome app"
          }
    idea = Idea.new(data)
    idea.save
    assert_equal "New idea!", IdeaStore.all.last.title
  end

  def test_it_can_update
    data = { "title" => "New idea!",
           "description" => "Really awesome app"
          }
    idea = Idea.new(data)
    idea.save
    idea = IdeaStore.all.first
    idea.title = "A really cool idea"
    idea.update
    assert_equal "A really cool idea", idea.title
  end

  def test_it_increments_rank_on_like
    data = { "title" => "New idea!",
           "description" => "Really awesome app"
          }
    idea = Idea.new(data)
    assert_equal 0, idea.rank
    idea.like!
    assert_equal 1, idea.rank
  end

  def test_it_can_rank_likes
    idea1 = Idea.new({ "rank" => 2 })
    idea2 = Idea.new({ "rank" => 6 })
    assert_equal 1, idea1 <=> idea2
  end

  def test_it_can_sort_likes
    idea1 = Idea.new({ "rank" => 2 })
    idea2 = Idea.new({ "rank" => 6 })
    assert_equal [idea2, idea1], [idea1, idea2].sort
  end

  def test_ideas_can_be_sorted_by_rank
    skip
    diet = Idea.new({ "title" => "diet", "description" => "cabbage soup"})
    exercise = Idea.new({"title" => "exercise", "description" => "long distance running"})
    drink = Idea.new({"title" => "drink", "description" => "carrot smoothy"})

    exercise.like!
    exercise.like!
    drink.like!

    ideas = [diet, exercise, drink]

    assert_equal [diet, drink, exercise], ideas.sort
  end


end