adhearsion {
  ahn_log.dialplan "Okay, cool. Handling a call"
  # This channel variable is set when doing an originate. If it exists, then this is the second leg of the call.
  @destination = self.call.variables[:destination] = variable("destination")
  ahn_log.dialplan "This is the destination #{@destination.inspect}"

  if @destination
    +outgoing_call
  else
    +incoming_call
  end
}

incoming_call {
  # This would be the main IVR of your app if you needed one.
  play 'hello-world'
}

outgoing_call {
  ahn_log "Calling destination now. Wee."
  play 'one-moment-please'
  dial @destination
}