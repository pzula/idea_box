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
    # Create an idea
    visit '/'
    fill_in 'idea[title]', :with => 'eat'
    fill_in 'idea[description]', :with => 'chocolate chip cookies'
    click_button 'Save'
    assert page.has_content?("chocolate chip cookies"), "Idea is not on page"

  end
end
