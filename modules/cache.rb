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
          @@redis.incr "cache_misses"
          raise Miss
        else
          @@redis.incr "cache_hits"
          value
        end

      end

      def requests_for key
        @@redis.get "#{key}:request_count"
      end


      def store key, value

        # Store the key and index it by date so that we can
        # sweep through the dates and expire old files:
        @@redis.pipelined do
          today = Date.today.to_s
          @@redis.incr 'key_count'
          @@redis.sadd 'dates', today
          @@redis.sadd today, key
          @@redis.set key, value
        end
        value
      end

      def key_count
        @@redis.get 'key_count'
      end

      def cache_hits
        @@redis.get 'cache_hits'
      end

      def cache_misses
        @@redis.get 'cache_misses'
      end

      def stats
        {
          key_count: key_count,
          cache_hits: cache_hits,
          cache_misses: cache_misses
        }
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
