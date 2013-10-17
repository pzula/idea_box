require 'yaml/store'

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
    ideas = []
    raw_ideas.each do |data|
      ideas << Idea.new(data)
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
      db['ideas'][i] = data.merge("id" => data["id"].to_i,
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

end