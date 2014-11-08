while true
	comment = gets.chomp.downcase
	unless comment.include?("@flatterybot")
		next
	end