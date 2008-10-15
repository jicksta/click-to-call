// Written by Jay Phillips

function format_number_for_trunk(number) {
  return "IAX2/voipms/" + number;
};

function Call(viewer_element, source, destination) {
  this.viewer      = viewer_element;
  this.source      = format_number_for_trunk(source);
  this.destination = format_number_for_trunk(destination);
  
  this.viewer.slideDown();
  
  var self = this;
  
  // Using the more sophisticated jQuery.ajax method instead of jQuery.post in order to handle errors.
	jQuery.ajax({
	  url:  "call",
	  type: "POST",
	  success: function(event) { self.transition_to("ringing") },
	  error:   function(event) { self.transition_to("error")   },
	  data: "destination=" + this.destination + "&source=" + this.source
	});
	
	// Possible states: new, connecting, error, ringing, established, hanging_up, finished
	this.state = "new";
	
	// If you wish to change this, override this prototype's implementation of this.

  
	this.transition_to = function(new_state) {
	  this.state = new_state;
	  this.state_transitions[new_state]();
	};
  
  this.state_transitions = {
    
    connecting: function() {
      self.update_text("Connecting");
      self.viewer.removeClass("hidden");
      self.viewer.slideDown("slow");
    },
    
    ringing: function() {
      self.update_text("Ringing");
      self.queue_next_heartbeat();
    },
    
    established: function() {
      self.update_text("Call in progress!")
    },
    
    hanging_up: function() {
      self.update_text("Hanging up");
    },
    
    finished: function() {
      self.update_text("Call finished");
    },
    
    error: function() {
      self.update_text("Whoops. Error occurred!");
    }
  };
  
	this.update_text = function(new_text) {
	  jQuery($("#call").children()[0]).text(new_text);
	};
	
	this.heartbeat = function(has_been_answered) {
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
	};
	
	this.heartbeat_timeout = 1000;
	
	this.queue_next_heartbeat = function(has_been_answered) {
	  setTimeout("heartbeat(" + has_been_answered + ")", this.heartbeat_timeout);
	};
	
	this.hangup = function() {
	  transition_to("hanging_up")
	  jQuery.post("hangup", {call_to_hangup: this.destination}, function() {
	    this.transition_to("finished")
	  })
	};
	
  this.transition_to("connecting");
  
}