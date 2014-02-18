#!/usr/bin/env ruby
# encoding: utf-8

require "alfred"
require "mechanize"
require "./setting"

class Util
  def self.prompt_username
    username = %x[osascript -e 'display dialog "Username" default answer ""' -e 'text returned of result']
    username.chomp!
    raise if username.empty?
    return username
  end

  def self.prompt_password
    password = %x[osascript -e 'display dialog "Password" default answer "" with hidden answer' -e 'text returned of result']
    password.chomp!
    raise if password.empty?
    return password
  end

  def self.get_enabled_agent
    agent = Mechanize.new

    if File.exists? @@cookie_yaml
      # Load cookie from file if exist
      agent.cookie_jar.load @@cookie_yaml
    else
      # Create a session newly
      page = agent.get "#{@@setting.get(:base_url)}/signin"
      form = page.forms[0]
      form.username = prompt_username
      form.password = prompt_password
      agent.submit form
      agent.cookie_jar.save_as @@cookie_yaml
    end
    return agent
  end

  def self.get_tasks_as_json(attribute)
    agent = self.get_enabled_agent
    begin
      page = agent.get "#{@@setting.get(:base_url)}/api/tasks/#{attribute}"
    rescue
      # Retry to get an enabled agent when any exception occurs or HTTP status is 401
      File.delete @@cookie_yaml
      get_tasks_as_json attribute
    end
    JSON.parse page.body
  end

  def self.print_feedback(feedback, attribute)
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

  def self.exec(attribute = "today")
    Alfred.with_friendly_error do |alfred|
      @@setting ||= Setting.new alfred
      @@cookie_yaml ||= "#{alfred.storage_path}/#{@@setting.get(:cookie_yaml)}"

      # Enabling cache (https://github.com/zhaocai/alfred-workflow#automate-saving-and-loading-cached-feedback)
      alfred.with_rescue_feedback = true
      alfred.with_cached_feedback do
        use_cache_file :expire => @@setting.get(:cache_expiration)
      end

      if fb = alfred.feedback.get_cached_feedback
        puts fb.to_alfred(ARGV)
      else
        fb = alfred.feedback
        Util.print_feedback fb, attribute
        puts fb.to_alfred(ARGV)
        fb.put_cached_feedback
      end
    end
  end
end
