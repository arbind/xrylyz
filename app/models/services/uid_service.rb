class UIDService
  require "digest/sha1"
  def self.generate_key(value, length = 12)
    Digest::SHA1.hexdigest(Time.now.to_s + "value")[1..length]
  end
end