require 'minitest/autorun'
require 'minitest/pride'
require 'minitest-vcr'

# pull in the VCR setup
require File.expand_path './tests/vcr_setup.rb'
#
# # pull in the code to test
require 'twitter_ads'
MinitestVcr::Spec.configure!
#
