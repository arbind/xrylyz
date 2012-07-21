class TimestampLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :domain,      :type => String
  field :ns,          :type => String
  field :key,         :type => String
  field :timestamps,  :type => Array, :default => []

  validates_presence_of :domain
  validates_presence_of :ns
  validates_presence_of :key
  
end