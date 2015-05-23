require "minitest/autorun"
require 'twitter_ads'

class TestTwitterAds < Minitest::Test
  def setup
    @ads = TwitterAds::Client.new({:consumer_key=>"CONSUMER_KEY"})
  end

  def test_that_config_is_ok
    assert_equal "CONSUMER_KEY", @ads.config[:consumer_key]
  end

end