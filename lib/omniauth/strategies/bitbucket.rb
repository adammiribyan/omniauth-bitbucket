require 'omniauth-oauth'

module OmniAuth
  module Strategies
    class Bitbucket < OmniAuth::Strategies::OAuth
      option :client_options, {
        site: 'https://bitbucket.org',
        request_token_path: '/api/1.0/oauth/request_token',
        authorize_path: '/api/1.0/oauth/authenticate',
        access_token_path: '/api/1.0/oauth/access_token'
      }

      uid { raw_info['username'] }

      extra do
        { raw_info: raw_info }
      end

      info do
        {
          name: "#{raw_info['first_name']} #{raw_info['last_name']}",
          avatar: raw_info['avatar'],
          email: raw_info['email']
        }
      end

      def raw_info
        @raw_info ||= begin
          ri = MultiJson.decode(access_token.get('/api/1.0/user').body)['user']
          emails = MultiJson.decode(access_token.get('/api/1.0/emails').body)
          email_hash = emails.find { |email| email['primary'] } || emails.first || {}
          ri.merge('email' => email_hash['email'])
        end
      end
    end
  end
end