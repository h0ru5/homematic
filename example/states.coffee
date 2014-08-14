hm = require '../lib/index'

hm.getStates('192.168.178.20')
.then (result) ->
	result.stateList.device.forEach (dev) ->
		console.log "#{dev.$.ise_id}: #{dev.$.name}"
		dev.channel.forEach (channel) ->
			console.log "  #{channel.$.ise_id}: #{channel.$.name}"
			channel.datapoint.forEach (dp) ->
				console.log("    #{dp.$.ise_id}: #{dp.$.type} = #{dp.$.value}")
