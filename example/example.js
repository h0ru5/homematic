var hm = require('../lib/index');

hm.getStates('192.168.178.20')
	.then(console.dir)
	.catch(console.error);
