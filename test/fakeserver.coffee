rp = require 'request-promise'
http = require 'http'
url = require 'url'
path = require 'path'
fs = require 'fs'
expect = require('chai').expect

hm = require '../lib/index'

ccu='localhost:4000'

readFile = (fname) ->
	fpath = path.join __dirname, "resources/#{fname}"
	fs.createReadStream fpath

fakeSrv = (req, resp) ->
			urlpath = url.parse(req.url).pathname
			tok = urlpath.split('/')
			if tok[1] is 'config' && tok[2] is 'xmlapi'
				switch tok[3]
					when 'programlist.cgi'
						readFile('programlist.xml').pipe resp
						console.log('stream running')
					when 'statelist.cgi'
						readFile('statelist.xml').pipe resp
					else
						throw new Error('unkown script')
			else
				#return first token as status
				status = parseInt tok[1]
				if isNaN(status) then status = 555
				resp.writeHead status
				resp.end()

describe 'Tests against server mock', ->
	server = {}

	before ->
		#This creates a local server to test, returning the files from resources
		server = http.createServer fakeSrv
		server.listen(4000);

	after ->
        server.close()

	it 'should return success' , (done) ->
		rp('http://localhost:4000/200')
            .then ->
                done()
            .catch ->
                done(new Error('A 200 response should resolve, not reject'))

	it 'should return a parsed program list', (cb) ->
		hm.getPrograms(ccu, false)
		.then (result) ->
			expect(result).to.equal(parsedprogs)
			cb()
		.catch ->
			cb new Error('the server did return an error instead of the xml')
