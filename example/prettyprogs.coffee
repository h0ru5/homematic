hm = require '../lib/index'

url = '192.168.178.20'
pid = 1

hm.getPrograms url, true
.then (result) ->
	console.log 'Programs:'
	result.programList.program.forEach (prog) ->
		console.log "#{prog.$.id}: #{prog.$.name}"

hm.getPrograms url, false
.then (result) ->
	console.dir result
	console.log 'Programs:'
	result.forEach (prog) ->
		console.log "#{prog.id}: #{prog.name}"

#hm.runProgram url,'1681'
