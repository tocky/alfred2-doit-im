#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require_relative "bundle/bundler/setup"
require "alfred"
require "mechanize"

def print_feedback(fb)
  agent = Mechanize.new

  if File.exists? "./cookie.yaml" # FIXME
    # Load cookie from file if exist
    agent.cookie_jar.load "./cookie.yaml" # FIXME
  else
    # Create a session newly
    page = agent.get "https://i.doit.im/signin"
    form = page.forms[0]
    form.username = "" # FIXME
    form.password = "" # FIXME
    agent.submit form
    agent.cookie_jar.save_as "./cookie.yaml" # FIXME
  end

  page = agent.get "https://i.doit.im/api/tasks/today"
  json = JSON.parse page.body

  json['entities'].each do |entity|
    fb.add_item({
      :uid => "",
      :title => entity['title'],
      :icon => {:type => "default", :name => "#{entity['priority']}.png"},
      :arg => "https://i.doit.im/home/#/task/#{entity['uuid']}",
      :valid => "yes"
    })
  end
end

Alfred.with_friendly_error do |alfred|
  # Enabling cache (https://github.com/zhaocai/alfred-workflow#automate-saving-and-loading-cached-feedback)
  alfred.with_rescue_feedback = true
  alfred.with_cached_feedback do
    use_cache_file :expire => 1
  end

  # setting = Alfred::Setting.new alfred
  # table = {'base_url': 'https://i.doit.im'}
  # setting.dump table

  if fb = alfred.feedback.get_cached_feedback
    puts fb.to_alfred(ARGV)
  else
    fb = alfred.feedback
    print_feedback fb
    puts fb.to_alfred(ARGV)
    fb.put_cached_feedback
  end
end
