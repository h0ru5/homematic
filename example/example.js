var hm = require('../index');

hm.getStates('192.168.178.20')
	.then(console.log)
	.catch(console.error);
