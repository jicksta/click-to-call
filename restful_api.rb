require 'rubygems'
require 'sinatra'

Adhearson = DRb.new_with_uri 'druby://127.0.0.1:9050'

SIP_TRUNK = "SIP/%s@voipms"

get "/call/:source/:destination" do
  source, destination = params.values_at :source, :destination
  Adhearsion.proxy.introduce SIP_TRUNK % source, SIP_TRUNK % destination
end