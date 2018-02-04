require "gemver/version"
require 'net/http'
require 'json'

module Gemver
  UNKNOWN_VERSION = 'unknown'
  def self.run(gemname)
    if gemname.nil?
      puts 'ERR: Please specify gem name! \n `gemver rails` for an example'
      return
    end

    begin
      response = Net::HTTP.get_response(URI("https://rubygems.org/api/v1/versions/#{gemname}/latest.json"))

      unless response.is_a?(Net::HTTPSuccess)
        puts "An error occurs when get gem verions: #{response.header&.message}"
        return
      end

      body = JSON.parse(response.body)
      version = body.fetch('version', UNKNOWN_VERSION)

      if version == UNKNOWN_VERSION
        raise 'Your gem name return an unknown version number. Please verify that the gem exists!'
        return
      end

      self.add_to_gemfile("gem '#{gemname}', '~> #{version}'")
    rescue => e
      puts e
    end
  end

  def self.add_to_gemfile(text)
    begin
      puts "#{text} is added to Gemfile"
      file = File.open('Gemfile', 'a+')
      file.write("\n" + text)
    rescue IOError => e
      puts e
    ensure
      file.close unless file.nil?
    end
  end
end
