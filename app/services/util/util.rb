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

  def self.invite_url(host_url, game_name='auto')
    url = Addressable::URI.parse(host_url)
    return nil if url.nil?

    url.query_values = {} if url.query_values.nil?
    url.query_values = url.query_values.merge({ryPlay: game_name})
    url
  end

  def self.invite_href(host_url, game_name='auto')
    url = invite_url(host_url, game_name)
    return '' if url.nil?
    url.to_s
  end

end
