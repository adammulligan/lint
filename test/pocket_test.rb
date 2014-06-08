require './pocket'

require "minitest/autorun"

require 'timecop'
require 'webmock/minitest'

class TestPocket < Minitest::Test
  def test_new_assigns_an_options_object_with_the_api_keys_and_the_base_uri
    pocket = Pocket.new access_token: 'test_token', consumer_key: 'test_key'

    query = pocket.instance_variable_get(:@options)[:query]
    access_token = query[:access_token]
    consumer_key = query[:consumer_key]

    assert_equal "test_token", access_token
    assert_equal "test_key", consumer_key
    assert_equal "https://getpocket.com/v3", Pocket.base_uri
  end

  def test_articles_since_returns_articles_read_after_the_timestamp
    timestamp = 1402240107
    time = Time.at(timestamp)
    Timecop.freeze(time)

    returned_articles = { "list" => {
      "1" => {"given_title" => "Why NodeJS sucks and so do you"},
      "2" => {"given_title" => "My little PHP"}
    }}
    expected_articles = [
      {"given_title" => "Why NodeJS sucks and so do you"},
      {"given_title" => "My little PHP"}
    ]

    stub_request(:get, "https://getpocket.com/v3/get").
      with({query: {
        access_token: 'test_token',
        consumer_key: 'test_key',
        since: timestamp,
        state: 'archive'
      }}).to_return(:status => 200, :body => returned_articles.to_json)

    pocket = Pocket.new access_token: 'test_token', consumer_key: 'test_key'
    articles = pocket.articles_read_since time

    assert_equal expected_articles, articles
  end
end
