#!/usr/bin/env ruby
# encoding: utf-8

require "alfred"

class Setting
  def initialize(alfred)
    @setting ||= Alfred::Setting.new alfred
    @setting[:cookies_dump] = 'cookies.dump'
    @setting[:cache_expiration] = 300
    @setting[:base_url] = 'https://i.doit.im'
    @setting.dump
  end

  def get(key)
    begin
      @setting[key.to_sym]
    rescue NameError => ex
      generate alfred
      get alfred, key
    end
  end

  def set(key, value)
    begin
      @setting[key.to_sym] = value
      @setting.dump
    rescue NameError => ex
      generate alfred
      set alfred, key, value
    end
  end
end
