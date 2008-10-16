events.after_initialized.each do
  
  def call_with_destination(destination)
    ahn_log.web "Finding call with destination #{destination.inspect} in #{Adhearsion.active_calls.size} active calls"
    Adhearsion.active_calls.to_a.find do |call|
      call.variables[:destination] == destination
    end ? "alive" : "dead"
  end

  # Register the method above with Adhearsion's RPC system. In the future, with the new components system, this will
  # be much cleaner.
  Adhearsion::DrbDoor.instance.add "web", "call_with_destination", method("call_with_destination")
  
end