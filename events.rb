events.after_initialized.each do
  Kernel.module_eval do
    
    # This method is invoked over DRb and helps the GUI determine whether the call is still active.
    def call_with_destination(destination)
      ahn_log.web "Finding call with destination #{destination.inspect} in #{Adhearsion.active_calls.size} active calls"
      Adhearsion.active_calls.to_a.find do |call|
        call.variables[:destination].include? destination
      end ? "alive" : "dead"
    end

    # This method is invoked over DRb and traverses Adhearsion's data structure for active calls and returns
    # the proper channel name that Asterisk needs to hangup a call.
    def channel_with_destination(destination)
      found_call = Adhearsion.active_calls.to_a.find do |call|
        call.variables[:destination].include? destination
      end
      if found_call
        found_call.variables[:channel]
      else
        nil
      end
    end

    # Register the method above with Adhearsion's RPC system. In the future, with the new components system,
    # this will be much cleaner.
    Adhearsion::DrbDoor.instance.add "web", "call_with_destination", method("call_with_destination")   
    Adhearsion::DrbDoor.instance.add "web", "channel_with_destination", method("channel_with_destination")
    
  end
end