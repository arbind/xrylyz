class Util
  @@number_helper = Object.new.extend(ActionView::Helpers::NumberHelper)
  @@text_helper = Object.new.extend(ActionView::Helpers::TextHelper)
  # string utils
  def self.create_key(*tokens) tokens.join('.') end

  # number utils
  def self.percentage(decimal, precision=0) @@number_helper.number_to_percentage(100*decimal, precision: precision) end
  def self.number_to_percentage(number, precision=2) @@number_helper.number_to_percentage(number, precision: precision) end

  # text utils
  def self.pluralize(*args) @@text_helper.pluralize(*args) end

end
