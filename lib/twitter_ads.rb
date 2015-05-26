require 'OAuth'
require 'json'

ADS_API_ENDPOINT="ads-api.twitter.com"
TRACE=false
# Usage:
# Initialisation
#
# ads=TwitterAds::Client.new({consumer_key:"YOUR_CONSUER_KEY",
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
# if the method does not exist, the easiest it to do:
# client.get "/accounts/ACCOUNT_ID",params
#
# same with post, put, delete
#
module TwitterAds
	UnauthorizedAccess="UNAUTHORIZED_ACCESS"
    class AdsError < StandardError
    end

    # Common class to manage access to recourse
    # Need access to client, prefix, and ops available on this ressource
    class RestRessource
    	@prefix=""
    	attr:access_token,:prefix

		# Utility funciton to do a get on the RES API
		def get action="",params=nil
			do_request :get,action,params
		end
		def post action,params=nil
			do_request :post,action,params
		end
		def put action,params=nil
			do_request :put,action,params
		end
		def delete action="",params=nil
			do_request :delete,action,params
		end

		def do_request verb,action,params
			url="https://#{ADS_API_ENDPOINT}/0/#{prefix}#{action}"
			if url[-1]=="/" then url=url[0..-2] end
			puts "Doing request:#{verb} #{prefix} #{action} #{params} URL:#{url}" if TRACE
			res=::JSON.parse @client.access_token.request(verb,url,params).body
			if res["errors"]
				raise AdsError,res["errors"].first["code"]
			end
			res["data"]
		end



		# Dynamic check of methods
		# tab_ops contain the list of allowed method and verbs
		# prefix the prefix to add to the method
		#
		def check_method tab_ops,prefix,method_sym,do_call,*arguments, &block
			method_sym=method_sym.id2name
			verb=:get
			[:post,:get,:delete,:put].each do |averb|
				if method_sym.start_with? averb.id2name
					verb=averb
					method_sym[averb.id2name+"_"]=""
					break
				end
			end
			if  tab_ops[verb].include? method_sym.to_sym
				if do_call
					method=prefix+method_sym
					params=arguments.first
					if params.first && params.first.class!=Hash
						method+="/#{params.shift}"
					end
					return do_request verb,method,params.shift
				else
					return nil
				end
			end
			nil
		end
		def method_missing(method_sym, *arguments, &block)
			# the first argument is a Symbol, so you need to_s it if you want to pattern match
			if (res=check_method(@ops,"",method_sym,true,arguments,block))==nil
				super
			else
				res
			end
		end
		def respond_to? method_sym
			if check_method(@ops,"",method_sym.to_sym,false,"",nil)
				return true
			end
			super
		end
    end

	class  Client<RestRessource
		attr_reader :config,:access_token,:ops

		def initialize params
			@config=params
			@ops={:get=>[:bidding_rules,:iab_categories]}

			consumer = OAuth::Consumer.new(
			      params[:consumer_key],params[:consumer_secret],
			      :site => "https://#{ADS_API_ENDPOINT}")
			consumer.http.use_ssl = true
			consumer.http.set_debug_output(STDERR)
			consumer.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			@client=self # To manage rest resource
			@access_token = OAuth::AccessToken.new(consumer, params[:access_token],params[:access_secret])
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

	class Account<RestRessource

		attr_reader :id,:name
		def initialize client,account
			@client=client
			@account=account
			init
			@prefix="accounts/#{@id}/"
			@ops={:get   =>[:promoted_accounts,:promoted_tweets,:tailored_audience_changes,
				            :targeting_criteria,:app_lists,:campaigns,:funding_instruments,
				            :line_items,:promoted_accounts,:promotable_users,:reach_estimate,
		      	            :targeting_suggestions],
			      :post  =>[:tailored_audiences,:tailored_audience_changes,:campaigns],
			      :put   =>[:campaigns,:promoted_tweets,:targeting_criteria,"tailored_audiences__global_opt_out"],
			      :delete=>[:tailored_audiences,:campaigns,:promoted_tweets,:targeting_criteria]
			}

			end
		def init
			@id=@account["id"]
			@name=@account["name"]
		end

		def as_json
			return @account
		end

		def refresh
			@account=get("")
			init
		end

	end
end
