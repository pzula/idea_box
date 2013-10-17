require 'yaml/store'
require 'pry'

class IdeaStore

  def self.create(data)
    id = next_id
    database.transaction do
      database['ideas'] << data.merge("id" => id, "rank" => 0)
    end
  end

  def self.all
    ideas = []
    raw_ideas.each_with_index do |data, i|
      ideas << Idea.new(data.merge("id" => i))
    end
    ideas
  end

  def self.next_id
    raw_ideas.length + 1
  end

  def self.find(id)
    raw_idea = find_raw_idea(id)
    Idea.new(raw_idea)
  end

  def self.find_raw_idea(id)
    database.transaction do
      database['ideas'].at(id)
    end
  end

  def self.raw_ideas
    database.transaction do |db|
      db['ideas']
    end
  end

  def self.update(id, data)
    database.transaction do |db|
      raw_idea = db['ideas'].find do |idea|
        idea["id"] == id
      end
      i = db['ideas'].index(raw_idea)
      db['ideas'][i] = data.merge("id" => data["id"].to_i,
                                  "rank" => data["rank"].to_i)
    end
  end

  def self.delete(position)
    database.transaction do

    end
  end

  def self.database
    return @database if @database

    @database =  YAML::Store.new("db/ideabox_#{environment}")
    @database.transaction do
      @database['ideas'] ||= []
    end
    @database
  end

  def self.environment
    ENV["RACK_ENV"] || "development"
  end

end