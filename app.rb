require 'rubygems'
require 'bundler'

Bundler.require

#require 'sinatra'
require 'json'
require 'open-uri'

helpers do

  def exec(cmd) puts "Command: #{cmd}"; system(cmd) end

  def create_path(path) Dir.mkdir_p(path, 0700) end

  def update_restart(github_username, github_repository_name)
    data={}
    open('data.json') {|f| data = JSON.parse(f.read) }
    key = "#{github_username}/#{github_repository_name}"
    if data[key]
      path        = data[key]["local_path"]
      restart_cmd = data[key]["restart_cmd"]
      begin
        if path
          if File.directory? path
            puts "Pulling"
            exec("/bin/bash -c \". $HOME/.profile; cd #{path} && git pull \"")
            exec("/bin/bash -c \". $HOME/.profile; cd #{path} && #{restart_cmd}\"") unless restart_cmd.empty?
          else
            puts "Cloning"
            FileUtils.mkdir_p path
            Kernel.system("/bin/bash -c \". $HOME/.profile\"; cd #{path} && git clone git@github.com:#{key} .")
            Kernel.system("/bin/bash -c \". $HOME/.profile\"; cd #{path} && #{restart_cmd}") unless restart_cmd.empty?
          end
        end
      rescue =>e
        puts e.message
      end
    end
  end
end

post '/' do
  payload = JSON.parse(params["payload"])
  repository = payload["repository"]
  github_repository_name = repository["name"]
  github_username = repository["owner"]["name"]
  update_restart github_username, github_repository_name
end
