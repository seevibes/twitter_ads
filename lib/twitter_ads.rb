require 'OAuth'
require 'json'

ADS_API_ENDPOINT="ads-api.twitter.com"


# Usage:
# Initialisation
#
#ads=TwitterAds::Client.new({consumer_key:"YOUR_CONSUER_KEY",
#	                        consumer_secret:"YOUR CONSUMER SECRET",
#	                        access_token:"YOUR ACCESS TOKEN",
#	                        access_secret:"YOUR ACCESS SECRET"})
# get the list of accounts:
#  ads.accounts
#
# get info on a specfic account
# account=ads.account[account_id]
#
#  get tailored_audience change
# accounts.tailored_audience_changes
#
#  get tailored audience change on a specific list
# accounts.tailoered_audience_changes list_id
#
module TwitterAds
	UnauthorizedAccess="UNAUTHORIZED_ACCESS"

	class  Client
		attr_reader :config,:access_token

		def initialize params
			@config=params
			consumer = OAuth::Consumer.new(
			      params[:consumer_key],params[:consumer_secret],
			      :site => "https://#{ADS_API_ENDPOINT}")
			consumer.http.use_ssl = true
			consumer.http.set_debug_output(STDERR)
			consumer.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

			@access_token = OAuth::AccessToken.new(consumer, params[:access_token],params[:access_secret])
			puts @access_token

		end

		# Utility funciton to do a get on the RES API
		def get action,params=nil
			do_request "get",action,params
		end
		def post action,params=nil
			do_request "post",action,params
		end
		def do_request verb,action,params
			url="https://#{ADS_API_ENDPOINT}/0/#{action}"
			puts url
			puts params
			if verb=="post"
				res=::JSON.parse @access_token.post(url,params).body
			else
				res=::JSON.parse @access_token.get(url,params).body
			end

			if res["errors"]
				raise res["errors"].first["code"]
			end
			res["data"]
		end


		# return the list of available accounts
		def accounts
			if !@cached_accounts
				@cached_accounts=get("accounts").map{|account| Account.new(self,account)}
			end
			@cached_accounts
		end

		# Create an account based on his id
		def account account_id
			 TwitterAds::Account.new(self,{"id"=>account_id})
		end

	end

	class Account
		attr_reader :id,:name
		def initialize client,account
			@client=client
			@account=account
			init
		end
		def init
			@id=@account["id"]
			@name=@account["name"]
		end

		def as_json
			return @account
		end

		def refresh
			@account=@client.get("accounts/#{@id}")
			init
		end

		def do_tailored_audience params
		    @client.post "accounts/#{@id}/tailored_audiences",params
		end

		def do_tailored_audience_changes params
		    @client.post "accounts/#{@id}/tailored_audience_changes",params
		end

		def tailored_audience_changes list_id=nil
			if list_id
				url="accounts/#{@id}/tailored_audience_changes/#{list_id}"
			else
				url="accounts/#{@id}/tailored_audience_changes"
			end
		    @client.get(url)
		end
	end
end
