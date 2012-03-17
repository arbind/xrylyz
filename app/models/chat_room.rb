class ChatRoom
  include Mongoid::Document
  include Mongoid::Timestamps
  field :channel_name, :type => String
  field :users, :type => Array
end
