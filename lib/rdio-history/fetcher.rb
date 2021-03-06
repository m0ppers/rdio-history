require 'json'
require 'net/https'
require 'rdio-history/session'
require 'rdio-history/item'
require 'rdio-history/util'

module Rdio
  module History
    class Fetcher
      include Rdio::API

      def initialize(user)
        session = Rdio::Session::Fetcher.get_session

        @cursor = 0
        @rpp = 10
        @session = session
        @user_key = get_user(user)['key']
      end

      # Fetch the user json object from the username
      def get_user(user)
        params = {
          'url' => "people/#{user}/",
          'method' => USER_METHOD
        }
        user = do_post(USER_PATH, params)
        user['result']
      end

      # Perform a single blocking history fetch
      # starting from the current cursor
      def fetch
        history = []
        params = {
          'user' => "#{@user_key}",
          'start' => @cursor,
          'count' => @rpp,
          'method' => HISTORY_METHOD
        }
        output = []
        
        attempts = 1
        while output.length == 0 do
          history = do_post(HISTORY_PATH, params)
          
          if history.size > 0
            history['result']['sources'].each_with_index do |source, i|
              source['tracks'].each do |item|
                output << Item.new(item, source['extraTrackKeys'])
              end
            end
          end

          if output.length == 0 then
            puts "Oops...no data even though last result said we are not done....trying again. attempt #{attempts}. cursor is at #{@cursor}"
            attempts += 1
            sleep(1)
          else
            @cursor = history['result']['last_transaction']
            if history['result']['doneLoading'] then
              return nil
            end
          end
        end
        return output
      end

      private
      def do_post(url, data = {})
        data.merge!({'_authorization_key' => @session[:authorization_key]})
        data = data.map{|k,v| "#{k}=#{v}"}.join('&')

        https = Net::HTTP.new(API_BASE_URL, 443)
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        https.use_ssl = true
        headers = { 'Cookie' => @session[:authorization_cookie] }
        resp = https.post(url, data, headers).body
        JSON.parse(resp)
      end

    end
  end
end
