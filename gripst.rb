#!/usr/bin/env ruby
class Gripst
  require 'find'
  require 'git'
  require 'octokit'
  require 'tmpdir'

  def initialize
    @auth_token=ENV['GITHUB_USER_ACCESS_TOKEN']
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
    begin
      g = Git.clone("https://#{@auth_token}@gist.github.com/#{id}.git", id, :path => "#{@tmpdir}")
    rescue
      $stderr.puts "ERROR: git fell down on #{id}"
      return false
    end
    return true
  end

  def grep_gist(regex,id)
    if clone(id)
      Find.find("#{@tmpdir}/#{id}") do |path|
      if path == "#{@tmpdir}/#{id}/.git"
          Find.prune
        else
          if File.file?(path)
            fh = File.new(path)
            fh.each do |line|
              begin
                matches = /#{regex}/.match(line)
              rescue ArgumentError
                $stderr.puts "Skipping... #{id}(#{(path).gsub("#{@tmpdir}/#{id}/","")}) #{$!}"
                sleep 300
              end
              if matches != nil
                puts "#{id} (#{(path).gsub("#{@tmpdir}/#{id}/","")}) #{line}"
              end
            end
          end
        end
      end
    end
  end

end

################################################################################
gripst = Gripst.new
gripst.all_gists.each do |id|
  gripst.grep_gist(ARGV[0],id)
end
