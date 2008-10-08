require 'drb'
require 'rubygems'
require 'sinatra'

# Adhearson = DRb.new_with_uri 'druby://127.0.0.1:9050'

SIP_TRUNK = "SIP/%s@voipms"

get '/' do
  <<-HTML
<html><head>
  <title>Click to call demo</title>
</head><body>
  <h1>Adhearsion Click to Call Demo</h1>
  
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
  call = Adhearsion.proxy.introduce SIP_TRUNK % source, SIP_TRUNK % destination
  id   = call.asndfjas
  {:call => {:id => call_id}}.to_xml
end

post "/hangup" do
  Adhearsion.proxy.hangup params[:call_to_hangup]
end
