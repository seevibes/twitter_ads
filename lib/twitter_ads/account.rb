#
# @ Seevibes 2015
# Author Thomas Landspurg
#
# thomas@seevibes.com
#
#


module TwitterADS


  class Account < RestResource

    attr_reader

    def initialize(client, account)
      @client = client
      @attributes = account
      init
      @prefix = "accounts/#{@id}/"
      @ops = {
        :get => [
          :promoted_accounts, :promoted_tweets, :tailored_audience_changes,
          :targeting_criteria, :app_lists, :campaigns, :funding_instruments,
          :line_items, :promoted_accounts, :promotable_users, :reach_estimate,
          :targeting_suggestions,:tailored_audiences
        ],
        :post => [:tailored_audiences, :tailored_audience_changes, :campaigns],
        :put => [:campaigns, :promoted_tweets, :targeting_criteria, 'tailored_audiences__global_opt_out'],
        :delete => [:tailored_audiences, :campaigns, :promoted_tweets, :targeting_criteria]
      }
    end
    def tailored_audiences
    	get('tailored_audiences').map{ |ta| TailoredAudience.new(self, ta)}
    end

    def tailored_audience tailored_audience_id
      TwitterADS::TailoredAudience.new(self, {'id' => tailored_audience_id})
    end
  end

end
