hm = require '../lib/homematic'

hm.getStates('192.168.178.20')
.then (result) ->
	result.forEach (dev) ->
		console.log "#{dev.id}: #{dev.name}"
		dev.channels.forEach (channel) ->
			console.log "  #{channel.id}: #{channel.name}"
			channel.datapoints.forEach (dp) ->
				console.log("    #{dp.ise_id}: #{dp.type} = #{dp.value}")
