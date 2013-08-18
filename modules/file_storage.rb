require 'aws-sdk'

module EasyCache
  class RemoteFile

    class << self
      def connect!

        @@s3 = AWS::S3.new(
          :access_key_id => ENV['S3_KEY'],
          :secret_access_key => ENV['S3_SECRET']
        )

        @@bucket = @@s3.buckets[ ENV['S3_BUCKET'] ]

      end
    end

    def initialize key, value=nil
      @key = key
      @value = value
    end

    def url
      @url ||= @@bucket.objects[@key].public_url
    end

    def store!
      @@bucket.objects[@key].write(@value, :acl=>:public_read)
      @url = @@bucket.objects[@key].public_url
    end

  end
end
