gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/idea_box/idea.rb'

class IdeaTest < Minitest::Test

  def test_it_can_initialize_on_a_hash_of_data
    data = { "title" => "New idea!",
           "description" => "Really awesome app"
          }
    idea = Idea.new(data)
    assert_equal "New idea!", idea.title
    assert_equal "Really awesome app", idea.description
    assert_equal 0, idea.rank
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

end