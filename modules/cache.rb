require "redis"

module Whim
  class Cache

    class Miss < Exception
    end

    class << self


      def connect!
        uri = URI.parse(ENV["REDISTOGO_URL"])
        @@redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      end


      def fetch key

        @@redis.incr "#{key}:request_count"

        value = @@redis.get key

        if value.nil?
          raise Miss
        else
          value
        end

      end


      def store key, value

        # Store the key and index it by date so that we can
        # sweep through the dates and expire old files:
        @@redis.pipelined do
          today = Date.today.to_s
          @@redis.sadd 'dates', today
          @@redis.sadd today, key
          @@redis.set key, value
        end
        value
      end


      def keys_older_than cuttoff_date, &block
        @@redis.smembers('dates').each do |date|
          if Date.parse(date) < cuttoff_date
            @@redis.smembers(date).each do |key|
              block.call(key)
            end
          end
        end
      end


    end

  end
end
