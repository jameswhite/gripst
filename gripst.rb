#!/usr/bin/env ruby

class Gripst
  require 'git'
  require 'octokit'
  require 'tmpdir'

  def initialize
    @auth_token=ENV['HUBOT_GITHUB_TOKEN']
    puts Dir.methods.grep("tmp").join " "
    @tmpdir = Dir.mktmpdir
  end

  def all_gists
    all_gists = Array.new
    Octokit.auto_paginate = true
    client = Octokit::Client.new(:access_token => "#{@auth_token}")
    octouser = client.user
    octouser.login
    raw_gists = client.gists
    raw_gists.each do |gist|
      all_gists.push(gist.id)
    end
    return all_gists
  end

  def clone(id)
    g = Git.clone("https://#{@auth_token}:#{@auth_token}@gist.github.com/#{id}.git", id, :path => "#{@tmpdir}")
  end

  def grep_gist(regex,id)
    clone(id)
    Find.find("#{@tmpdir}/#{id}") do |path|
    if path == "#{@gittmp}/#{user}/#{repo}/.git"
        Find.prune       # Don't look
      else
        if File.file?(path)
          fh = File.new(path)
          fh.each do |line|
            # YOU ARE HERE
            puts line
          end
        end
      end
    end
  end

end

################################################################################

gripst = Gripst.new
gripst.all_gists.each do |id|
  gripst.grep_gist(id,"stuff")
end
