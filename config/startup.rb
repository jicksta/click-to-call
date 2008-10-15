unless defined? Adhearsion
  if File.exists? File.dirname(__FILE__) + "/../adhearsion/lib/adhearsion.rb"
    # If you wish to freeze a copy of Adhearsion to this app, simply place a copy of Adhearsion
    # into a folder named "adhearsion" within this app's main directory.
    require File.dirname(__FILE__) + "/../adhearsion/lib/adhearsion.rb"
  else  
    require 'rubygems'
    gem 'adhearsion', '>= 0.7.999'
    require 'adhearsion'
  end
end

Adhearsion::Configuration.configure do |config|
  
  config.logging :level => :debug
  
  config.enable_asterisk
  config.asterisk.enable_ami :host => "10.0.1.97", :username => "jicksta", :password => "roflcopter"
  
  config.enable_drb 
  
  # config.enable_rails :path => 'gui', :env => :development
  
end

Adhearsion::Hooks::AfterInitialized.create_hook do

  def call_with_destination(destination)
    puts "got hereee"
    Adhearsion.active_calls.to_a.find { |call| call.variables[:destintion] == destination }
  end

  Adhearsion::DrbDoor.instance.add "web", "call_with_destination", method("call_with_destination")
  
end

Adhearsion::Initializer.start_from_init_file(__FILE__, File.dirname(__FILE__) + "/..")