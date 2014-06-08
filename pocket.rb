require 'httparty'

class Pocket
  include HTTParty
  base_uri 'https://getpocket.com/v3'

  def initialize(access_token: , consumer_key:)
    @options = {
      query: {
        access_token: access_token,
        consumer_key: consumer_key
      }
    }
  end

  def articles_read_since time
    options = @options.dup
    options[:query][:since] = time.to_i
    options[:query][:state] = 'archive'

    response = self.class.get('/get', options)

    parse_articles JSON.parse(response.body)
  end

  private

  def parse_articles unparsed_articles
    articles = []

    unparsed_articles["list"].each do |id, article|
      articles.push article
    end

    articles
  end
end
