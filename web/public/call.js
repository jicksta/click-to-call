var Call = {
	
	state: "new";
	
	// The update_function argument should take accept one argument: the new HTML for representing the Call.
	init: function(source, destination, update_function) {
		this.update_function = update_function;
		jQuery.post("/call", {source: source, destination: destination}, function(data) {
			update_function(this.initial_state());
		});
		
		// Periodically update the call until done.
		setInterval(function() {
			
		})
	}
	
	initial_state: function() {
		return "Starting..."
	}
	
}