require 'json'
module Rdio
  module History
    class ItemParsingException < Exception
    end

    class Item
      attr_accessor :artist_id, :artist_name, :album_id, :album_name, :track_id, :track_name, :track_url, :time, :count

      # We can extend this class to include whatever
      # data fields we'd like. For now, this data is sufficient
      def initialize(item, extraKeys)
        begin
          @artist_id = item['track']['artistKey']
          @artist_name = item['track']['artist']
          @album_id = item['track']['albumKey']
          @album_name = item['track']['album']
          @track_id = item['track']['key']
          @track_name = item['track']['name']
          @track_url = item['track']['shortUrl']
          @count = 1 + extraKeys.select{ |key| key == item['track']['key'] }.length
          @time = item['time']
        rescue Exception => e
          raise ItemParsingException.new('Unexpected API format' + e.message)
        end
      end

      def to_json(*a)
        return {
          'artist_id' => @artist_id,
          'artist_name' => @artist_name,
          'album_id' => @album_id,
          'album_name' => @album_name,
          'track_id' => @track_id,
          'track_name' => @track_name,
          'track_url' => @track_url,
          'count' => @count,
          'time' => @time
        }.to_json(*a)
      end
    end
  end
end
