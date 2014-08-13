var request=require("request");

var lists=['devicelist','functionslist','sysvarlist','statelist','programlist','favoritelist','roomlist'];

var toUrl = function(host,script) {
	return "http://" + host + "/config/xmlapi/" + script + ".cgi";
}

module.exports.getStates = function(addr,cb) {
	console.log('function was called for ' + toUrl(addr,'statelist'));
	request(toUrl(addr,'statelist'), function(error,response,body) {
		 if (!error && response.statusCode == 200) {
			 return cb(null,body);
  		} else {
			return cb(error);
		}
	});
}
