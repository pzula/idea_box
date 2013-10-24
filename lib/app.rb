require 'sinatra/base'
require 'sinatra/reloader'
require './lib/idea_box'

class IdeaBoxApp < Sinatra::Base
  set :method_override, true
  set :root, 'lib/app'

  helpers do
    def idea_path(idea=nil)
      if idea
        "ideas/#{idea.id}"
      else
        "ideas"
      end
    end
  end

  not_found do
    erb :error
  end

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    erb :index, locals: {ideas: IdeaStore.all.sort, idea: Idea.new, tags: IdeaStore.all_tags}
  end

  post '/ideas' do
    IdeaStore.create(params[:idea])
    redirect '/'
  end

  delete '/ideas/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect '/'
  end

  get '/ideas/:id/edit' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :edit, locals: {idea: idea}
  end

  put '/ideas/:id' do |id|
    IdeaStore.update(id.to_i, params[:idea])
    redirect '/'
  end

  post '/ideas/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.update(id.to_i, idea.to_h)
    redirect '/'
  end

  get '/ideas/:id' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :idea, locals: {idea: idea}
  end

  get '/tag/:tag' do |tag|
    ideas = IdeaStore.find_all_by_tag(tag)
    erb :tag, locals: {ideas: ideas, tag: tag}
  end

  get '/search/results' do
    ideas = IdeaStore.search(params[:phrase])
    erb :search, locals: {ideas: ideas, phrase: params[:phrase]}
  end

  get '/sms' do
    title, description_tags = params[:Body].split(" :: ")
    description, tags = description_tags.split(" # ")
    attributes = {"title" => title, "description" => description, "tags" => tags}

    IdeaStore.create(attributes)
    redirect '/'
    # send a text to the number using title :: description # tag, tag, tag
  end
end