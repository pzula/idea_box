class Idea

  attr_accessor :title, :description, :rank, :id

  def initialize(attributes = {})
    @title = attributes["title"]
    @description = attributes["description"]
    @rank = attributes["rank"] || 0
    @id = attributes["id"]
    @tags = attributes["tags"]
  end

  def save
    IdeaStore.create(to_h)
  end

  def to_h
    {
      "id" => id,
      "title" => title,
      "description" => description,
      "rank" => rank,
      "tags" => tags
    }
  end

  def tags
    if @tags
      format_tags(@tags)
    else
      []
    end
  end

  def format_tags(tags)
    tags.gsub(/\s+/, "").split(",")
  end

  def update
    IdeaStore.update(id, to_h)
  end

  def like!
    @rank += 1
  end

  def <=>(other)
    other.rank <=> rank
  end

end