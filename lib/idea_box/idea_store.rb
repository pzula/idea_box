require 'yaml/store'
require './lib/idea_box/idea'

class IdeaStore

  def self.create(data)
    id = next_id
    data["id"] = next_id if data["id"].nil?
    data["rank"] = 0 if data["rank"].nil?
    database.transaction do
      database['ideas'] << data
    end
  end

  def self.all
    raw_ideas.map do |data|
      Idea.new(data)
    end
  end

  def self.next_id
    raw_ideas.length + 1
  end

  def self.find(id)
    raw_idea = find_raw_idea(id)
    Idea.new(raw_idea)
  end

  def self.find_all_by_tag(tag)
    all.select do |idea|
      idea.tags.include?(tag)
    end
  end

  def self.find_raw_idea(id)
    database.transaction do |db|
      db['ideas'].find do |idea|
        idea["id"] == id
      end
    end
  end

  def self.raw_ideas
    database.transaction do |db|
      db['ideas']
    end
  end

  def self.update(id, data)
    i = raw_ideas.index(find_raw_idea(id))
    database.transaction do |db|
      db['ideas'][i] = data.merge("id" => id,
                                  "rank" => data["rank"].to_i)
    end
  end

  def self.delete(id)
    i = raw_ideas.index(find_raw_idea(id))
    database.transaction do |db|
      db['ideas'].delete_at(i)
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

  def self.destroy
    database.transaction do |db|
      db['ideas'] = []
    end
  end

end