rq = require 'request-promise'
Promise = require 'bluebird'
xml2js = require 'xml2js'

Promise.promisifyAll require('xml2js');

lists=['devicelist','functionslist','sysvarlist','statelist','programlist','favoritelist','roomlist'];

urlOf = (host,script) ->
	"http://#{host}/config/xmlapi/#{script}.cgi"

parseXml = (xml) ->
	xml2js.parseStringAsync xml


module.exports.getStates = (addr,cb) ->
	rq(urlOf(addr,'statelist')).then parseXml
