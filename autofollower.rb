#!/usr/bin/env ruby
require 'twitter'
require 'yaml'

@keys = YAML.load_file('config.yml')

def rest_client
  Twitter::REST::Client.new do |config|
    config.consumer_key        = @keys['consumer_key']
    config.consumer_secret     = @keys['consumer_secret']
    config.access_token        = @keys['access_token']
    config.access_token_secret = @keys['access_token_secret']
  end
end

def streaming_client
  Twitter::Streaming::Client.new do |config|
    config.consumer_key        = @keys['consumer_key']
    config.consumer_secret     = @keys['consumer_secret']
    config.access_token        = @keys['access_token']
    config.access_token_secret = @keys['access_token_secret']
  end
end


search_term = ARGV[0] || nil


limit = ARGV[1] || 10

unless search_term.nil?
  puts "Autofollowing: #{search_term}\r\nLimit: #{limit}"
  x = 1;
  streaming_client.filter(:track => "#{search_term}") do |object|
    begin
      if object.is_a?(Twitter::Tweet)
        puts "#{object.user.name}(#{object.user.screen_name}): #{object.text}"
        puts "Following #{object.user.screen_name} (#{x})"
        rest_client.follow!(object.user)
        x += 1
      end
    rescue Twitter::Error::TooManyReqeusts => error
      puts error
    end
    if x>limit.to_i
      break
    end
  end
end