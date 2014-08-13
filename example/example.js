var hm = require('../index');

var states = hm.getStates('192.168.178.20',function(err,states) {
	if(!err) {
		console.log(states);
	} else
		console.log(err);
});

