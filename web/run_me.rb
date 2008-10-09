require 'drb'
require 'rubygems'
require 'sinatra'  # Get with "gem install sinatra"

# Adhearsion must be running also. Type "ahn start ." from within this folder
Adhearson = DRbObject.new_with_uri 'druby://127.0.0.1:9050'

get '/' do
  <<-HTML
<html><head>
  <title>Click to call demo</title>
  <script src="jquery.js" type="text/javascript"></script>
</head><body>
  
  <h1>Adhearsion Click to Call Demo</h1>
  
  <a href='#' onclick='javascript:jQuery.get("/ajax", {}, function(data) { alert(data); });'>Alert from /ajax</a>
  
  <h2>Start a call between two numbers</h2>
  
  <form action="call" method="post">
    <label for="source">Source:</label> <input type="text" name="source"/><br/>
    <label for="destination">Destination:</label> <input type="text" name="destination"/><br/>
    <input type="submit" value="Call">
  </form>
  
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
  source, destination = params.values_at :source, :destination
  call = Adhearsion.proxy.introduce "IAX2/voipms/#{source}", "IAX2/voipms/#{destination}"
  # {:call => {:id => call_id}}.to_xml
end

post "/hangup" do
  Adhearsion.proxy.hangup params[:call_to_hangup]
  "ok"
end

get '/ajax' do
  "O HAI"
end