class Util
  @@number_helper = Object.new.extend(ActionView::Helpers::NumberHelper)

  # string utils
  def self.create_key(*tokens) tokens.join('.') end

  # number utils
  def self.percentage(decimal, precision=0) @@number_helper.number_to_percentage(100*decimal, precision: precision) end
  def self.number_to_percentage(number, precision=2) @@number_helper.number_to_percentage(number, precision: precision) end

end
