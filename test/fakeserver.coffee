rp = require 'request-promise'
http = require 'http'
url = require 'url'
path = require 'path'
fs = require 'fs'
xml2js = require 'xml2js'
expect = require('chai').expect
should = require('chai').should()

hm = require '../lib/index'

ccu='localhost:4000'

readFile = (fname) ->
	fpath = path.join __dirname, "resources/#{fname}"
	fs.readFileSync fpath

fakeSrv = (req, resp) ->
			urlpath = url.parse(req.url).pathname
			tok = urlpath.split('/')
			if tok[1] is 'config' && tok[2] is 'xmlapi'
				switch tok[3]
					when 'programlist.cgi'
						resp.writeHead 200
						resp.end readFile('programlist.xml')
						#readFile('programlist.xml').pipe resp
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

describe 'calling the lib against the server mock', ->
	server = {}

	before ->
		#This creates a local server to test, returning the files from resources
		server = http.createServer fakeSrv
		server.listen(4000);

	after ->
        server.close()

	it 'should return success for urls like 200' , (done) ->
		rp('http://localhost:4000/200')
            .then ->
                done()
            .catch ->
                done(new Error('A 200 response should resolve, not reject'))

	it 'should return the xml for the ccu urls' , (cb) ->
		fname = path.join __dirname, "resources/programlist.xml"
		xml = fs.readFileSync fname, 'UTF-8'

		rp('http://localhost:4000/config/xmlapi/programlist.cgi')
		.then (result) ->
			result.should.equal xml
			cb()
		.catch (err) ->
			cb err


	it 'should return a parsed program list when calling getprograms', (cb) ->
		parsedprogs = [
			{ id: '1681', name: 'first program' },
  			{ id: '1653', name: 'second program' }
		]

		hm.getPrograms(ccu, false)
		.then (result) ->
			result.should.deep.equal parsedprogs
			cb()
		.catch (err) ->
			cb err

	it 'should return the xml for getPrograms with raw flag' , (cb) ->
		fname = path.join __dirname, "resources/programlist.xml"
		xml = fs.readFileSync fname, 'UTF-8'

		xml2js.parseStringAsync(xml).then (expectation) ->
			hm.getPrograms(ccu, true)
			.then (result) ->
				result.should.deep.equal expectation
				cb()
			.catch (err) ->
				cb err



