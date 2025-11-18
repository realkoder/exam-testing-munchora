# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :connection_uuid

    def connect
      self.current_user = find_verified_user
      self.connection_uuid = SecureRandom.uuid
      track_connection!
    end

    def disconnect
      untrack_connection!
    end

    private

    def redis
      @redis ||= begin
                   Redis.new(url: ENV['UPSTASH_REDIS_URL'])
                 end
    end

    def track_connection!
      value = "user_id:#{current_user.id};connection_uuid:#{connection_uuid}"
      redis.sadd('action_cable:connections', value)
    end

    def untrack_connection!
      value = "user_id:#{current_user.id};connection_uuid:#{connection_uuid}"
      redis.srem('action_cable:connections', value)
    end

    def find_verified_user
      token = cookies[:jwt_auth]

      # Fallback to Bearer token in query param or headers
      if token.nil?
        auth_header = request.headers['Authorization']
        if auth_header&.start_with?('Bearer ')
          token = auth_header.split(' ').last
        elsif (param_token = request.params[:token])
          token = param_token
        end
      end

      raise 'No token' unless token

      decoded = Auth::JsonWebToken.decode(token)
      raise 'Invalid token' unless decoded && decoded[:user_id]

      user = User.find_by(id: decoded[:user_id])
      raise 'User not found' unless user

      user
    rescue => e
      Rails.logger.warn "ActionCable: auth failed - #{e.message}"
      reject_unauthorized_connection
    end
  end
end
