#!/usr/bin/env ruby
# encoding: utf-8

require "mechanize"

class Util
  def self.get_enabled_agent
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
    return agent
  end

  def self.get_tasks_as_json(attribute)
    agent = self.get_enabled_agent
    page = agent.get "https://i.doit.im/api/tasks/#{attribute}"
    JSON.parse page.body
  end

  def self.print_feedback(feedback, attribute = "today")
    json = Util.get_tasks_as_json attribute
    json['entities'].each do |entity|
      feedback.add_item({
        :uid => "",
        :title => entity['title'],
        :icon => {:type => "default", :name => "#{entity['priority']}.png"},
        :arg => "https://i.doit.im/home/#/task/#{entity['uuid']}",
        :valid => "yes"
      })
    end
  end
end
