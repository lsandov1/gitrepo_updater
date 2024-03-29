require 'rubygems'
require 'bundler/setup'
require 'octokit'

class GithubAccount
  def initialize(login, pwd)
    @login, @pwd = login, pwd
  end

  def client
      @client ||= Octokit::Client.new(:login => @login, :password => @pwd)
  end
  
  def github_request
    begin 
      yield client if client
    rescue => e
      puts e.message
    end
  end

  def create_hook(user, repo_name, hook_url)
    github_request do |client|
      unless hook_include? user, repo_name, hook_url
        hook_options = {'name' => 'web', 'config' => {'url'=>hook_url}, 'active'=> true}
        # POST /repos/:user/:repo/hooks
        client.post "/repos/#{user}/#{repo_name}/hooks", hook_options, 3
      else
        puts "Hook #{hook_url} already on #{repo_name}"
      end
    end
  end

  def list_hooks(user, repo_name)
    # GET /repos/:user/:repo/hooks
    hooks = github_request do |client|
      response = client.get "/repos/#{user}/#{repo_name}/hooks"
      hooks = {}
      response.each {|hook| hooks[hook.config.url] = hook.id}
      hooks
      end || {}
  end

  def hook_include?(user, repo_name, hook_url)
    list_hooks(user, repo_name).include? hook_url
  end

  def test_hook(user, repo_name, hook_url)
    hooks = list_hooks(user, repo_name)
    if hooks[hook_url]
      id = hooks[hook_url]
      #POST /repos/:user/:repo/hooks/:id/test
      github_request{|client| client.post "/repos/#{user}/#{repo_name}/hooks/#{id}/test" }
    end
  end
end

