require 'sinatra/base'
require 'sinatra/reloader'
require './lib/idea_box'

class IdeaBoxApp < Sinatra::Base
  set :method_override, true
  set :root, 'lib/app'

  not_found do
    erb :error
  end

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    erb :index, locals: {ideas: IdeaStore.all.sort, idea: Idea.new, tags: IdeaStore.all_tags}
  end

  post '/' do
    IdeaStore.create(params[:idea])
    redirect '/'
  end

  delete '/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect '/'
  end

  get '/:id/edit' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :edit, locals: {idea: idea}
  end

  get '/:id' do |id|
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

  put '/:id' do |id|
    IdeaStore.update(id.to_i, params[:idea])
    redirect '/'
  end

  post '/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.update(id.to_i, idea.to_h)
    redirect '/'
  end


end