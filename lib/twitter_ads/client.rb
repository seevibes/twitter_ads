#
# @ Seevibes 2015
# Author Thomas Landspurg
#
# thomas@seevibes.com
#
#

module TwitterADS


  class Client < RestResource
    attr_reader :config, :access_token, :ops

    def initialize(params)
      @config = params
      @ops = { get: [:bidding_rules, :iab_categories] }
      @attributes={}
      consumer = OAuth::Consumer.new(params[:consumer_key], params[:consumer_secret], site: "https://#{ADS_API_ENDPOINT}")
      consumer.http.use_ssl = true
      consumer.http.set_debug_output(STDERR)
      consumer.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @client = self # To manage rest resource
      @access_token = OAuth::AccessToken.new(consumer, params[:access_token], params[:access_secret])
    end

    # return the list of available accounts
    def accounts
      @cached_accounts = get('accounts').map { |account| Account.new(self, account) } unless @cached_accounts
      @cached_accounts
    end

    # Create an account based on his id
    def account(account_id)
      TwitterADS::Account.new(self, {'id' => account_id})
    end
  end

end
