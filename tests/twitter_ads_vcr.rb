require "minitest/autorun"
require 'twitter_ads'
require 'minitest-vcr'
require 'yaml'

MinitestVcr::Spec.configure!


describe 'TwitterAds test', :vcr do
  before do
    begin # Note: if you want to use your own token, set a config.yml as expected
      config_client=YAML.load_file('config.yml')
    rescue Errno::ENOENT
      config_client={}
    end
    @client=TwitterAds::Client.new(config_client)
  end
  let(:account){@client.account("p0r8d3")}
  let(:list){account.tailored_audience_changes}
  it "fetch accounts" do
    accounts=@client.accounts
    accounts[1].name.must_equal "Thomas Landspurg"
  end

  it "refresh account" do
    account.refresh
    account.name.must_equal "Thomas Landspurg"
  end

  it "Bidding rules" do
    @client.bidding_rules.must_be_instance_of Array
  end

  it "IAB categories " do
    @client.iab_categories.must_be_instance_of Array
  end

  it "Get tailored audience list" do
    $list=account.tailored_audience_changes
    $list.must_be_instance_of Array
    $list.size.must_be :>,0
  end

  it "Tailored audience creation" do
    params={
          :name=>"Fake Creation",
          :list_type=>"TWITTER_ID"
        }
    res=account.post_tailored_audiences  params
    res["name"].must_equal "Fake Creation"
    id=res["id"]
    err=lambda{
      account.tailored_audience_changes id
    }.must_raise TwitterAds::AdsError
    err.message.must_equal "TAILORED_AUDIENCE_CHANGE_FILE_NOT_FOUND"

    res=account.delete_tailored_audiences id
    res["name"].must_equal "Fake Creation"
  end

  it "single get tailored audience change" do
    aList=account.tailored_audience_changes list.first['id']
    aList["state"].must_equal "COMPLETED"
  end

  it "receive promoted accounts" do
    pa=account.promoted_accounts.must_be_instance_of Array
  end

  it "receive promoted tweets" do
    pt=account.promoted_tweets.must_be_instance_of Array
  end

  it "targeting criteria all" do
    err= lambda{
      pt=account.targeting_criteria
    }.must_raise TwitterAds::AdsError
    err.message.must_equal "MISSING_PARAMETER"
  end

  it "targeting criteria" do
    assert_raises TwitterAds::AdsError do
      pt=account.targeting_criteria("1")
    end
  end
end
