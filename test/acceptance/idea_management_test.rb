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

  def test_manage_ideas
    IdeaStore.create({"title" => "eat", "description" => "chocolate chip cookies"})
    visit '/'
    assert page.has_content?("chocolate chip cookies")
  end
end
