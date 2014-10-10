# use karl's chat-adapter library
require 'chat-adapter'
# also use the local HerokuSlackbot class defined in heroku.rb
require './heroku'

require 'YAML'

# if we're on our local machine, we want to test our bot via shell, but when on
# heroku, deploy the actual slackbot.
# 
# Feel free to change the name of the bot here - this controls what name the bot
# uses when responding.
if ARGV.first == 'heroku'
  bot = HerokuSlackAdapter.new(nick: 'flatterybot')
else
  bot = ChatAdapter::Shell.new(nick: 'flatterybot')
end

# Feel free to ignore this - makes logging easier
log = ChatAdapter.log

compliments = YAML.load_file("compliments.yml")

# Do this thing in this block each time the bot hears a message:
bot.on_message do |message, info|
  # ignore all messages not directed to this bot
  unless message.start_with?('complimentme') || message.start_with?('compliment me')
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
  "@#{info[:user]}: #{randomcompliment}"
end

# actually start the bot
bot.start!