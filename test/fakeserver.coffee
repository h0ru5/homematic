expect = require('chai').expect
rp = require 'request-promise'
http = require 'http'
url = require 'url'
uut = require '../lib/index'

describe 'Tests against server mock', ->
	server = {}

	before ->
		#This creates a local server to test, returning the files from resources
		server = http.createServer (req, resp) ->
			path = url.parse(req.url).pathname
			status = parseInt path.split('/')[1]
			if isNaN(status) then status = 555
			resp.writeHead status
			resp.end()
		server.listen(4000);

	after ->
        server.close()

	it 'should return success' , (done) ->
		rp('http://localhost:4000/200')
            .then ->
                done()
            .catch ->
                done(new Error('A 200 response should resolve, not reject'))
