class UIDService
  require "digest/sha1"
  def self.generate_key(salt, length = 12)
    Digest::SHA1.hexdigest("#{Time.now.to_s}-#{salt}")[1..length]
  end
end