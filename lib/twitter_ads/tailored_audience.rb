#
# @ Seevibes 2015
# Author Thomas Landspurg
#
# thomas@seevibes.com
#
#

module TwitterADS

  class TailoredAudience < RestResource

    attr_reader :account

    def initialize(account,tailored_audience_hash)
      @account = account
      @client = account.client
      @attributes = tailored_audience_hash
      init
      @prefix = "accounts/#{account.id}/tailored_audiences/#{@id}"
      puts "Prefix: #{@prefix}"
      @ops = {
      }
    end

  end
end
