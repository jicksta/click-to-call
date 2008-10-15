// Written by Jay Phillips

function Call(source, destination) {
  Call.prototype.init(source, destination);
}

Call.prototype = {
  
	// The update_function argument should take accept one argument: the new HTML for representing the Call.
	init: function(viewer_element, source, destination) {
	  this.viewer      = viewer_element;
	  this.source      = this.format_number_for_trunk(source);
    this.destination = this.format_number_for_trunk(destination);
    
	  this.transition_to("connecting");
	  
	  // Using the more sophisticated jQuery.ajax method instead of jQuery.post in order to handle errors.
		jQuery.ajax({
		  url:  "call",
		  type: "POST",
		  success: function(event) { $("#call").trigger("ringing") },
		  error:   function(event) { $("#call").trigger("error") },
		  data: "destination=" + this.destination + "&source=" + this.source
		});
		
		register_event_handlers();
		
	},
	
	register_event_handlers: function() {
	  jQuery.each(this.state_transitions, function(state_name, fn) {
      this.viewer.bind(state_name, fn);
    });
	},
	
	// Possible states: new, connecting, error, ringing, established, hanging_up, finished
	state: "new",
	
	// If you wish to change this, override this prototype's implementation of this.
	format_number_for_trunk: function(number) {
	  return "IAX2/voipms/" + number;
	},
  
	transition_to: function(new_state) {
	  this.state = new_state;
	  this.state_transitions[new_state]();
	},
  
  state_transitions: {
    
    connecting: function() {
      this.update_text("Connecting");
        this.viewer.removeClass("hidden");
        this.viewer.slideDown("slow");
    },
    
    ringing: function() {
      this.update_text("Ringing");
      this.queue_next_heartbeat();
    },
    
    established: function() {
      this.update_text("Call in progress!")
    },
    
    hanging_up: function() {
      this.update_text("Hanging up");
    },
    
    finished: function() {
      this.update_text("Call finished");
    },
    
    error: function() {
      this.update_text("Whoops. Error occurred!");
    }
  },
  
	update_text: function(new_text) {
	  $("#call:first-child").text(new_text);
	},
	
	heartbeat: function(has_been_answered) {
	  call_status = jQuery.getJSON("status", {destination: this.destination})
	  if(call_status == "alive" && !has_been_answered) {
	    this.transition_to("established");
	    this.queue_next_heartbeat(true);
    } else if(call_status == "dead") {
      if(has_been_answered) {
        transition_to("finished")
      } else {
        this.queue_next_heartbeat(false)
      }
    } else if(call_status == "d"){
      throw "Unrecognized call status " + call_status + "!";
    }
	},
	
	heartbeat_timeout: 1000,
	
	queue_next_heartbeat: function(has_been_answered) {
	  setTimeout("heartbeat(" + has_been_answered + ")", this.heartbeat_timeout);
	},
	
	hangup: function() {
	  transition_to("hanging_up")
	  jQuery.post("hangup", {call_to_hangup: this.destination}, function() {
	    this.transition_to("finished")
	  })
	},
	
}