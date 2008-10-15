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
  <h1>Adhearsion Click to Call Demo</h1>
  
  <h2>Start a call between two numbers</h2>
  
  <div id="call-form">
    <p>The number <input type="text" id="source" name="source"/> will appear to call <input type="text" name="destination" id="destination"/><br/>
    <button onclick="new Call($('#source').value, $('#destination').value)">Start call</button>
  </div>
  
  <div id="call">
    <p>Starting...</p>
  </div>
  
  <h2>Hangup a particular call</h2>
  
  <h3>Active calls</h3>
  
  <ul>
    <li><a href="hangup/123812831">1231231231</a></li>
  </ul>
  
  <h3>or enter a call ID below</h3>
  
  <form action="hangup" method="post">
    <label for="call_to_hangup">Call to hangup:</label> <input type="text" name="call_to_hangup"/>
    <input type="submit" value="Hangup"/>
  </form>
  
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