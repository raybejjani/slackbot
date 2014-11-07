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
  bot = HerokuSlackAdapter.new(nick: 'flatterybot', channel: 'yakshack', icon_emoji: ':llamablush:')
else
  bot = ChatAdapter::Shell.new(nick: 'flatterybot')
end

# Feel free to ignore this - makes logging easier
log = ChatAdapter.log

compliments = YAML.load_file("compliments.yml")
helpmessage = File.read("help.txt")
credits = File.read("credits.txt")

hugledger = {}

# Do this thing in this block each time the bot hears a message:
bot.on_message do |message, info|
  channel = info[:channel]
  unless ['animatedgifs', 'askanything', 'gym', 'ath', 'aww', 'bot-testing', 'coffee', 'data', 'data-infra', 'kids-n-pets', 'open', 'product', 'random', 'recruiting', 'support', 'webcomix', 'yakshack'].include?(channel)
    next
  end  
  # ignore all messages not directed to this bot
  if message.start_with?('compliment')
    if message.start_with?('complimentme') || message.start_with?('compliment me')
      user = info[:user]
    elsif message.start_with?('compliment') && message.split.length == 2
      user = message.split[1] 
      if user == 'channel'
        next "tsk tsk, that's not nice"
      end
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
  elsif message.include?(':disappointed:') || message.include?(':tableflip:')
      user = info[:user]
      if rand < 0.05
        hugledger[user] = true
        next "@#{user}: You seem like you're having a bad day. Would you like a hug? You can say '@flatterybot yes' or '@flatterybot no'"
      end
  elsif message == "@flatterybot yes" && hugledger[info[:user]]
    user = info[:user]
    hugledger[user] = false
    next "@#{user} (((hug)))"
  elsif message == "@flatterybot no" && hugledger[info[:user]]
    user = info[:user]
    hugledger[user] = false
    next "@#{user} That's ok! flatterybot respects your personal space. :heart:"
  end
  
end

# actually start the bot
bot.start!
