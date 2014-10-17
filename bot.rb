# use karl's chat-adapter library
require 'chat-adapter'
# also use the local HerokuSlackbot class defined in heroku.rb
require './heroku'

require 'yaml'

# if we're on our local machine, we want to test our bot via shell, but when on
# heroku, deploy the actual slackbot.
# 
# Feel free to change the name of the bot here - this controls what name the bot
# uses when responding.
if ARGV.first == 'heroku'
  bot = HerokuSlackAdapter.new(nick: 'flatterybot', icon_emoji: ':llamablush:')
else
  bot = ChatAdapter::Shell.new(nick: 'flatterybot')
end

# Feel free to ignore this - makes logging easier
log = ChatAdapter.log

compliments = YAML.load_file("compliments.yml")
helpmessage = File.read("help.txt")
credits = File.read("credits.txt")



# Do this thing in this block each time the bot hears a message:
bot.on_message do |message, info|
  channel = info[:channel]
  unless ['animatedgifs', 'aww', 'bot-testing', 'coffee', 'open', 'random', 'support', 'webcomix' 'yakshack'].include?(channel)
    next
  end  
  # ignore all messages not directed to this bot
  if message.start_with?('compliment')
    if message.start_with?('complimentme') || message.start_with?('compliment me')
      user = info[:user]
    elsif message.start_with?('compliment') && message.split.length == 2
      user = message.split[1]
    else  
      next # don't process the next lines in this block
    end

    # Conditionally send a direct message to the person saying whisper
    #if message == 'flatterybot: whisper'
      # log some info - useful when something doesn't work as expected
    #  log.debug("Someone whispered! #{info}")
      # and send the actual message
    #  bot.direct_message(info[:user], "whisper-whisper")
    #end

    # split the message in 2 to get what was actually said.
    # botname, command = message.split(': ', 2)

    randomcompliment = compliments['Compliments'].sample

    # answer the query!
    # this bot simply echoes the message back
    "@#{user}: #{randomcompliment}"
  elsif /flattery?b(ot|utt)\s*h(a|e)lp( me)?/ =~ message
  # elsif message.start_with?('flatterybot') && message.include?('help')
    helpmessage
  elsif message == "flatterybot credits"
    credits
  end
  
end



# actually start the bot
bot.start!