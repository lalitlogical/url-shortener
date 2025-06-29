require "securerandom"

module Base62ShortCodeGenerator
  CHARSET = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".chars.freeze
  BASE    = CHARSET.size
  REDIS_KEY = "url_shortener:global_counter"

  # Returns a Base62 encoded string from an integer
  def self.encode(num)
    return CHARSET[0] if num == 0

    str = ""
    while num > 0
      str.prepend(CHARSET[num % BASE])
      num /= BASE
    end
    str
  end

  # Generates a short code using Redis counter
  # Fallbacks to UUID-based base62 if Redis fails
  def self.generate(id = nil, length: 6)
    begin
      id ||= $redis.incr(REDIS_KEY)
      code = encode(id)

      # pad to fixed length if needed
      code.rjust(length, CHARSET[0])
    rescue => e
      puts "Redis unavailable, using fallback: #{e.message}"
      fallback = SecureRandom.uuid.delete("-").to_i(16)
      encode(fallback)[0...length]
    end
  end
end
