require 'mini_magick'
require 'open-uri'

module Whim
  class Image

    def initialize( uri )
      @image = MiniMagick::Image.open( uri )
    end

    def process!( geometry = "100x100" )
      @image.resize( geometry )
      @image.format 'jpg'
    end

    def blob
      @image.to_blob
    end

  end
end
