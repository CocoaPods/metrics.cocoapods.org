require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../app/controller', __FILE__)

describe MetricsApp, 'when receiving hook calls from trunk' do

  def post_spec_update
    # header 'Content-Type', 'application/x-www-form-urlencoded'
    # payload = fixture_read('trunk_spec_update.raw')
    post '/hooks/trunk/', 'ohai' # payload
  end

  # before do
  #   header 'X-Github-Delivery', '37ac017e-902c-11e3-8115-655d22cdc2ab'
  #   header 'User-Agent', 'GitHub Hookshot 7e04da1'
  #   header 'Content-Length', '3687'
  #   header 'Content-Type', 'text/json'
  #   header 'X-Request-Id', '00f5fba2-c1ef-4169-b417-8abf02b26b94'
  #   header 'Connection', 'close'
  #   header 'X-Github-Event', 'push'
  #   header 'Accept', '*/*'
  #   header 'Host', 'trunk.cocoapods.org'
  # end

  it 'succeeds' do
    post_spec_update
    last_response.status.should == 200
  end

end
