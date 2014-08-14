hm = require '../lib/index'

hm.getPrograms('192.168.178.20')
.then (result) ->
	console.log 'Programs:'
	result.programList.program.forEach (prog) ->
		console.log "#{prog.$.id}: #{prog.$.name}"
