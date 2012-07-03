class FinalScore
  include Mongoid::Document
  include Mongoid::Timestamps

  field :leaderboard_key, :type => String
  field :nickname,        :type => String
  field :blog_url,        :type => String
  field :score,           :type => Integer, :default => -1
  field :member_id,       :type => BSON::ObjectId
  field :info,            :type => Hash, :default => {}

  validates_presence_of :leaderboard_key
  validates_presence_of :nickname
  validates_presence_of :blog_url
  validates_presence_of :score
end