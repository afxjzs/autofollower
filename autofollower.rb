#!/usr/bin/env ruby
require 'twitter'
require 'yaml'

keys = YAML.load_file('config.yml')

rest_client = Twitter::REST::Client.new(keys)

streaming_client = Twitter::Streaming::Client.new(keys)

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
    rescue Twitter::Error::TooManyRequests => error
      puts error
    end
    if x>limit.to_i
      break
    end
  end
end