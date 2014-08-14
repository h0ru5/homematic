rq = require 'request-promise'
Promise = require 'bluebird'
xml2js = require 'xml2js'

Promise.promisifyAll require('xml2js');

lists=['devicelist','functionslist','sysvarlist','statelist','programlist','favoritelist','roomlist'];

urlOf = (host,script) ->
	"http://#{host}/config/xmlapi/#{script}.cgi"

parseXml = (xml) ->
	xml2js.parseStringAsync xml


module.exports.getStates = (addr,raw) ->
	res = rq(urlOf(addr,'statelist')).then parseXml
	if raw then return res
	res.then parseStates

module.exports.parseStates = parseStates = (result) ->
	res = []
	console.log 'entering state parser'
	result.stateList.device.forEach (dev,devidx) ->
		res[devidx] = { "id" : dev.$.ise_id, "name" : dev.$.name, channels : [] }
		dev.channel.forEach (channel,chidx) ->
			res[devidx].channels[chidx] = { "id" : channel.$.ise_id, "name" : channel.$.name , datapoints : []}
			channel.datapoint.forEach (dp,dpidx) ->
				res[devidx].channels[chidx].datapoints[dpidx] = dp.$;
	return res


module.exports.getPrograms = (addr) ->
	rq(urlOf(addr,'programlist')).then parseXml
