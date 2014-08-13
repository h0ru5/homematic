var rp = require('request-promise');

var lists=['devicelist','functionslist','sysvarlist','statelist','programlist','favoritelist','roomlist'];

var toUrl = function(host,script) {
	return "http://" + host + "/config/xmlapi/" + script + ".cgi";
}

module.exports.getStates = function(addr,cb) {
	console.log('function was called for ' + toUrl(addr,'statelist'));

	return rp(toUrl(addr,'statelist'));
}
