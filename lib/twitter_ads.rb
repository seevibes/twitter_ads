#
# @ Seevibes 2015
# Author Thomas Landspurg
#
# thomas@seevibes.com
#
#
require 'oauth'
require 'multi_json'


# Usage:
# Initialisation
#
#  ads=TwitterADS::Client.new({consumer_key   :"YOUR_CONSUER_KEY",
#	                        consumer_secret:"YOUR CONSUMER SECRET",
#	                        access_token   :"YOUR ACCESS TOKEN",
#	                        access_secret  :"YOUR ACCESS SECRET"})
# get the list of accounts:
#  ads.accounts
#
# get info on a specific account
# account = ads.account[account_id]
#
#  get tailored_audience change
# accounts.tailored_audience_changes
#
#  get tailored audience change on a specific list
# accounts.tailoered_audience_changes list_id
#
# if the method does not exist, the easiest it to do:
# client.get "/accounts/ACCOUNT_ID",params
#
# same with post, put, delete
#

module TwitterADS

  ADS_API_ENDPOINT = 'ads-api.twitter.com'
  TRACE = true
  UnauthorizedAccess = 'UNAUTHORIZED_ACCESS'
  class AdsError < StandardError
  end

end
require "twitter_ads/rest_resource"
require "twitter_ads/client"
require "twitter_ads/account"
require "twitter_ads/tailored_audience"