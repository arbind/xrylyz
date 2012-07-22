class TimestampLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :scope,       :type => String, :default => nil
  field :ns,          :type => String, :default => nil
  field :key,         :type => String, :default => nil
  field :timestamps,  :type => Array,  :default => []

  validates_presence_of :scope
  validates_presence_of :ns
  validates_presence_of :key

end