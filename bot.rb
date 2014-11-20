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
flatteryledger = {}

def recently_complimented?(flatteryledger, user, channel)
  channel_dictionary = flatteryledger[user]
  return false if channel_dictionary.nil?
  compliment_time = channel_dictionary[channel] # the time when we complimented the user
    return false unless compliment_time
  # return true unless compliment_time.nil?
  if compliment_time < (Time.now - 45)
    return false
  else
    return true
  end
end

# Do this thing in this block each time the bot hears a message:
bot.on_message do |message, info|
  channel = info[:channel]
  message = message.downcase
  unless ['animatedgifs', 'askanything', 'ath', 'aww', 'bot-testing', 'coffee', 'data', 'data-infra', 'fcrchat', 'flatterybot-testing', 'gym', 'kids-n-pets', 'open', 'product', 'random', 'recruiting', 'support', 'support-spinup', 'webcomix', 'yakshack'].include?(channel)
    next
  end  
  # ignore all messages not directed to this bot
  if message.start_with?('compliment')
    user = info[:user]
    flatteryledger[user] ||= {}
    flatteryledger[user][channel] = Time.now
    if message.start_with?('complimentme') || message.start_with?('compliment me')
      user = info[:user]
    elsif message.start_with?('compliment') && message.split.length == 2
      user = message.split[1].downcase
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
  elsif message.include?("thank you") || message.include?("thanks")
    user = info[:user]
    if recently_complimented?(flatteryledger, user, channel)
      flatteryledger[user][channel] = false
      next "@#{user}: You're welcome!"
      # Send message
    end
  elsif /flattery?b(ot|utt)\s*h(a|e)lp( me)?/ =~ message
  # elsif message.start_with?('flatterybot') && message.include?('help')
    helpmessage
  elsif message == "flatterybot credits"
    credits
  elsif message.include?(':disappointed:') || message.include?(':tableflip:') || message.include?(':(')
      user = info[:user]
      if rand < 0.10
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