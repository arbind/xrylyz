class TimestampLogger

  def self.stamp(scope, ns, key, at_datetime=DateTime.now)
    stamp = lookup_timestamp_log(scope, ns, key)
    stamp ||= TimestampLog.new(scope:scope.to_s, ns: ns.to_s, key:key.to_s)
    stamp.timestamps.push(at_datetime.utc.to_s)
    stamp.save
    timestamps_to_datetime(stamp.timestamps)
  end

  def self.lookup(scope, ns, key)
    stamp = lookup_timestamp_log(scope, ns, key)
    return [] if stamp.nil?
    timestamps_to_datetime(stamp.timestamps)
  end

  def self.stamped?(scope, ns, key)
    stamp = lookup_timestamp_log(scope, ns, key)
    return false if (stamp.nil? or stamp.timestamps.empty?)
    not stamp.timestamps.empty?
  end
  def self.unstamped?(scope, ns, key) not stamped?(scope, ns, key) end


  # last stamped at
  def self.last_stamped_at(scope, ns, key)
    stamp = lookup_timestamp_log(scope, ns, key)
    return nil if (stamp.nil? or stamp.timestamps.empty?)
    timestamps_to_datetime(stamp.timestamps).last
  end

  def self.last_stamped_after?(scope, ns, key, at_datetime)
    last_stamp = last_stamped_at(scope, ns, key)
    return false if last_stamp.nil?
    last_stamp > at_datetime
  end

  def self.last_stamped_prior_to?(scope, ns, key, at_datetime)
    last_stamp = last_stamped_at(scope, ns, key)
    return false if last_stamp.nil?
    last_stamp < at_datetime
  end

  # first stamped at

  def self.first_stamped_at(scope, ns, key)
    stamp = lookup_timestamp_log(scope, ns, key)
    return nil if (stamp.nil? or stamp.timestamps.empty?)
    timestamps_to_datetime(stamp.timestamps).first
  end

  def self.first_stamped_after?(scope, ns, key, at_datetime)
    first_stamp = first_stamped_at(scope, ns, key)
    return false if first_stamp.nil?
    first_stamp > at_datetime
  end

  def self.first_stamped_prior_to?(scope, ns, key, at_datetime)
    first_stamp = first_stamped_at(scope, ns, key)
    return false if first_stamp.nil?
    first_stamp < at_datetime
  end


  class << self
      alias_method :stamped_before?, :stamped?
  end

  private
  def self.timestamps_to_datetime(timestamps)
    stamps = timestamps.map { |ts| DateTime.parse(ts) }
    stamps.sort!
  end

  def self.lookup_timestamp_log(scope, ns, key)
    TimestampLog.where(scope:scope.to_s, ns: ns.to_s, key:key.to_s).first
  end

end
