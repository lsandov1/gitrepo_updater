#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'octokit'
require 'trollop'

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

if (__FILE__ == $0) then
  opts = Trollop::options do
    opt :github_user_name, 'The Github username', :default => 'ooyala'
    opt :github_repository_name, 'The Github repository name', :default=>'', :required => true
    opt :local_path, 'The local Github repository path', :default => '', :required => true
    opt :restart_cmd, 'Command line to restart your app', :default => ''
    opt :github_login, 'The Github login', :default => '', :required => true
    opt :github_password, 'The Github password', :default => '', :required => true
    opt :github_hook, 'The Github hook, which is the name of the current domain', :default => '', :required => true
  end
  account = GithubAccount(opts[:github_login,:github_password])
  account.test_hook(opts[:github_user_name,
                    opts[:github_repository_name],
                    opts[:github_hook])
 end 
