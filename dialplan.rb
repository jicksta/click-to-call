adhearsion {
  # This channel variable is set when doing an originate.
  # If it exists, then this is the second leg of the call.
  @destination = self.call.variables[:destination] = variable("destination")
  
  if @destination
    play 'one-moment-please'
    dial @destination
  end
}