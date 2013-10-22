require './test/test_helper'
require 'bundler'
Bundler.require
require 'rack/test'
require 'capybara'
require 'capybara/dsl'

require './lib/app'

Capybara.app = IdeaBoxApp

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :headers =>  { 'User-Agent' => 'Capybara' })
end

class IdeaManagementTest < MiniTest::Unit::TestCase
  include Capybara::DSL

  def teardown
    IdeaStore.destroy
  end

  def test_idea_creation
    IdeaStore.create({"title" => "eat", "description" => "chocolate chip cookies"})
    visit '/'
    assert page.has_content?("chocolate chip cookies")
  end

  def test_manage_ideas
      # Create a couple of decoys
      # This is so we know we're editing the right thing later
      IdeaStore.create({"title" => "laundry", "description" => "buy more socks"})
      IdeaStore.create({"title" => "groceries", "description" => "macaroni, cheese"})

      # Create an idea
      visit '/'
      # The decoys are there
      assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
      assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page"

      # Fill in the form
      fill_in 'idea[title]', :with => 'eat'
      fill_in 'idea[description]', :with => 'chocolate chip cookies'
      click_button 'Save'
      assert page.has_content?("chocolate chip cookies"), "Idea is not on page"

      # Find the idea - we need the ID to find
      # it on the page to edit it
      idea = IdeaStore.search('eat').first

      # Edit the idea
      within("#idea_#{idea.id}") do
        find(".edit").click
      end

        assert_equal 'eat', find_field('idea[title]').value
        assert_equal 'chocolate chip cookies', find_field('idea[description]').value

        fill_in 'idea[title]', :with => 'eats'
        fill_in 'idea[description]', :with => 'chocolate chip oatmeal cookies'
        click_button 'Save'

          # Idea has been updated
        assert page.has_content?("chocolate chip oatmeal cookies"), "Updated idea is not on page"

        # Decoys are unchanged
        assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
        assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page"

        # Original idea (that got edited) is no longer there
        refute page.has_content?("chocolate chip cookies"), "Original idea is on page still"

        # Delete the idea
        within("#idea_#{idea.id}") do
          find(".delete").click
        end

        refute page.has_content?("chocolate chip oatmeal cookies"), "Updated idea is not on page"

        # Decoys are untouched
        assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page after delete"
        assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page after delete"
  end

  def test_ranking_ideas
    IdeaStore.create({"title" => "fun", "description" => "ride horses"})
    IdeaStore.create({"title" => "vacation", "description" => "camping in the mountains"})
    IdeaStore.create({"title" => "write", "description" => "a book about being brave"})

    visit '/'

    idea = IdeaStore.all[1]
    idea.like!
    idea.like!
    idea.like!
    idea.like!
    idea.like!

    id1 = IdeaStore.all[0]
    id2 = IdeaStore.all[1]
    id3 = IdeaStore.all[2]

    within("#idea_#{id2.id}") do
      3.times do
        find(".like").click
      end
    end

    within("#idea_#{id3.id}") do
      find(".like").click
    end

    # now check that the order is correct
    ideas = page.all('li')
    assert_match /camping in the mountains/, ideas[0].text
    assert_match /a book about being brave/, ideas[1].text
    assert_match /ride horses/, ideas[2].text
  end

  def test_searching
    # Create a couple of decoys
    # This is so we know we're editing the right thing later
    IdeaStore.create({"title" => "laundry", "description" => "buy more socks"})
    IdeaStore.create({"title" => "groceries", "description" => "macaroni, cheese"})

    # Create an idea
      visit '/'

    # Fill the search
      fill_in 'phrase', :with => 'buy more'
      click_button 'search'

      assert page.has_content?("All ideas with the search phrase \"buy more\" " ), "Search page is not functioning"
  end



end
