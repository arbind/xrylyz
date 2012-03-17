class ChatRoom
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, :type => String
  field :channel_name, :type => String
  field :users, :type => Array

  def num_users
  	users.try(:count) || 0
  end

  def for_display
  	{
  		id: _id,
  		name: name,
  		num_users: num_users
  	}
  end
end
