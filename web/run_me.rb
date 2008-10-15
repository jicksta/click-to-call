require 'drb'
require 'rubygems'
require 'sinatra'  # Get with "gem install sinatra"

# Adhearsion must be running also. Type "ahn start ." from within this folder
Adhearsion = DRbObject.new_with_uri 'druby://localhost:9050'

get '/' do
  <<-HTML
<html><head>
  <title>Click to call demo</title>
  <script src="jquery.js" type="text/javascript"></script>
  <link href="style.css" media="screen" rel="stylesheet" type="text/css" />
  
</head><body>
  
  <h1>Adhearsion Click to Call Demo</h1>
  
  <a href='#' onclick='javascript:new Call();'>Alert from /ajax</a>
  
  <h2>Start a call between two numbers</h2>
  
  <div id="call-form">
    <form action="call" method="post">
      <p>The number <input type="text" name="source"/> will appear to call <input type="text" name="destination"/><br/>
      <input type="submit" value="Start Call!">
    </form>
  </div>
  
  <div id="call">
    <img src="/spinner.gif" />Starting...
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
end

post "/hangup" do
  Adhearsion.proxy.hangup params[:call_to_hangup]
  "ok"
end

get '/status' do
  destination = params[:destination]
  call = Adhearsion.web.call_with_destination destination
  call.inspect
end