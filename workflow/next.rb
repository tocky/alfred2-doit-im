#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require_relative "bundle/bundler/setup"
require "alfred"
require "./util.rb"

Alfred.with_friendly_error do |alfred|
  # Enabling cache (https://github.com/zhaocai/alfred-workflow#automate-saving-and-loading-cached-feedback)
  alfred.with_rescue_feedback = true
  alfred.with_cached_feedback do
    use_cache_file :expire => 1
  end

  # setting = Alfred::Setting.new alfred
  # setting[:base_url] = 'https://i.doit.im'
  # setting.dump

  if fb = alfred.feedback.get_cached_feedback
    puts fb.to_alfred(ARGV)
  else
    fb = alfred.feedback
    Util.print_feedback fb, "next"
    puts fb.to_alfred(ARGV)
    fb.put_cached_feedback
  end
end
