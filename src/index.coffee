rq = require 'request-promise'
Promise = require 'bluebird'
xml2js = require 'xml2js'

Promise.promisifyAll require('xml2js');

lists=['devicelist','functionslist','sysvarlist','statelist','programlist','favoritelist','roomlist'];

urlOf = (host,script,vars,method='GET') ->
			res =
				'qs' : vars
				'url' : "http://#{host}/config/xmlapi/#{script}.cgi"

parseXml = (xml) ->
	xml2js.parseStringAsync xml

module.exports.getStates = (addr,raw) ->
	res = rq(urlOf(addr,'statelist')).then parseXml
	if raw then return res
	else res.then parseStates

module.exports.parseStates = parseStates = (result) ->
	res = []
	result.stateList.device.forEach (dev,devidx) ->
		res[devidx] = { "id" : dev.$.ise_id, "name" : dev.$.name, channels : [] }
		dev.channel.forEach (channel,chidx) ->
			res[devidx].channels[chidx] = { "id" : channel.$.ise_id, "name" : channel.$.name , datapoints : []}
			channel.datapoint.forEach (dp,dpidx) ->
				res[devidx].channels[chidx].datapoints[dpidx] = dp.$;
	return res

module.exports.parseProgs = parseProgs = (addr) ->
	(result) ->
		res = []
		result.programList.program.forEach (prog) ->
			res.push {
				"addr" : addr
				"id" : prog.$.id
				"name" : prog.$.name
				"run" : ->
					return module.exports.runProgram @addr,@id
			}
		return res

module.exports.getPrograms = (addr,raw) ->
	res = rq(urlOf(addr,'programlist')).then parseXml
	if raw then return res
	else res.then parseProgs(addr)

module.exports.runProgram = (addr,id) ->
	rq urlOf(addr,'runprogram', {'program_id' : id })
