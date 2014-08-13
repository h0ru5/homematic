var rp = require('request-promise');
var Promise = require("bluebird");
var xml2js = require("xml2js");

Promise.promisifyAll(require("xml2js"));

var lists=['devicelist','functionslist','sysvarlist','statelist','programlist','favoritelist','roomlist'];

var toUrl = function(host,script) {
	return "http://" + host + "/config/xmlapi/" + script + ".cgi";
}

var parseXml = function(xml) {
	return xml2js.parseStringAsync(xml);
}

module.exports.getStates = function(addr,cb) {
	return rp(toUrl(addr,'statelist')).then(parseXml);
}
