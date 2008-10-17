require 'drb'
require 'rubygems'
require 'json'     # Get with "gem install json"
require 'sinatra'  # Get with "gem install sinatra"

# Adhearsion must be running also. Type "ahn start ." from within this folder
Adhearsion = DRbObject.new_with_uri 'druby://localhost:9050'

# You'll need to change this for your own format.
# Note: this will soon be handled by the Call Routing DSL in Adhearsion.
def format_number(number)
  "SIP/#{number}@teliax"
end

post "/call" do
  source      = format_number params[:source]
  destination = format_number params[:destination]
  
  Adhearsion.proxy.call_into_context source, 'adhearsion', :variables => {:destination => destination}
  "ok".to_json
end

post "/hangup" do
  channel_of_active_call = Adhearsion.channel_with_destination params[:call_to_hangup]
  Adhearsion.proxy.hangup channel_of_active_call
  "ok".to_json
end

get '/status' do
  destination = params[:destination] # Passed as a GET variable
  # The line below will return either {result:"alive"} or {result:"dead"} to the browser
  {:result => Adhearsion.web.call_with_destination(destination)}.to_json
end

get '/' do
  <<-HTML
<html><head>
  
  <title>Click to Call Demo</title>
  
  <script src="jquery.js" type="text/javascript"></script>
  <script src="call.js" type="text/javascript"></script>
  <link href="style.css" media="screen" rel="stylesheet" type="text/css" />
  
</head><body>
  
  <div id="content">
    <h1>Click to Call Demo</h1>
  
    <h2>Bridge two people together</h2>
  
    <div id="call-form">
      <p><label for="source">Primary party: </label><input type="text" id="source" name="source"/></p>
      <p><label for="destination">Second party: </label><input type="text" name="destination" id="destination"/></p>
      <p><button onclick="new Call($('#call'), $('#source').val(), $('#destination').val())">Start call</button></p>
    </div>
  </div>
  
  <div id="call" class="hidden">
    <p>Starting...</p>
  </div>

</body></html>
  HTML
end
