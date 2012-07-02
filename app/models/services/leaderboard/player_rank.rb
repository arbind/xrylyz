class PlayerRank
  include Mongoid::Document
  include Mongoid::Timestamps

  # field :nickname, :type => String
  # field :blog_url, :type => String
  # field :score,    :type => Integer, :default => -1

  # field :info,     :type => Hash, :default => {},

  # has_one :member

  # validates_presence_of :nickname
  # validates_presence_of :blog_url
end