require 'drb'
require 'rubygems'
require 'json'
require 'sinatra'  # Get with "gem install sinatra"

# Adhearsion must be running also. Type "ahn start ." from within this folder
Adhearsion = DRbObject.new_with_uri 'druby://localhost:9050'

get '/' do
  <<-HTML
<html><head>
  <title>Click to call demo</title>
  <script src="jquery.js" type="text/javascript"></script>
  <script src="call.js" type="text/javascript"></script>
  <link href="style.css" media="screen" rel="stylesheet" type="text/css" />
  
</head><body>
  <div id="content">
  <h1>Click to Call Demo</h1>
  
  <h2>Bridge two people together</h2>
  
  <div id="call-form">
    <label for="source">Primary party: </label><input type="text" id="source" name="source"/><br/>
    <label for="destination">Second party: </label><input type="text" name="destination" id="destination"/><br/>
    <button onclick="new Call($('#call'), $('#source').value, $('#destination').value)">Start call</button>
  </div>
  
  <div id="call" class="hidden">
    <p>Starting...</p>
  </div>
  
</body></html>
  HTML
end

post "/call" do
  source, destination = params.values_at(:source, :destination).map { |number| "IAX2/voipms/#{number}" }
  Adhearsion.proxy.call_into_context source, 'adhearsion', :variables => {:destination => destination}
  "ok".to_json
end

post "/hangup" do
  Adhearsion.proxy.hangup params[:call_to_hangup]
  "ok"
end

get '/status' do
  destination = params[:destination] # Passed as a GET variable
  # The line below will return either "alive" or "dead" to the browser
  Adhearsion.web.call_with_destination destination
end