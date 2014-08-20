rp = require 'request-promise'
http = require 'http'
url = require 'url'
path = require 'path'
fs = require 'fs'
xml2js = require 'xml2js'
chai = require('chai')
expect = chai.expect
chai.should()
chai.use require('chai-subset')
chai.use require('chai-as-promised')


hm = require '../lib/index'

ccu='localhost:4000'
lastprog = -1

readFile = (fname) ->
	fpath = path.join __dirname, "resources/#{fname}"
	fs.readFileSync fpath

fakeSrv = (req, resp) ->
			urlpath = url.parse(req.url).pathname
			tok = urlpath.split('/')
			if tok[1] is 'config' && tok[2] is 'xmlapi'
				switch tok[3]
					when 'programlist.cgi'
						resp.end readFile('programlist.xml')
						#readFile('programlist.xml').pipe resp
					when 'statelist.cgi'
						resp.end readFile('statelist.xml')
						#readFile('statelist.xml').pipe resp
					when 'runprogram.cgi'
						progid =  url.parse(req.url,true).query['program_id']
						lastprog = progid
						resp.end()
					else
						throw new Error("unkown script: #{tok[3]}")
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
		parsedprogs = JSON.parse fs.readFileSync("#{__dirname}/resources/parsedprogs.json",'UTF-8')

		hm.getPrograms(ccu, false)
		.then (result) ->
			#result.should.deep.equal parsedprogs
			result.forEach (obj,idx) ->
				obj.should.containSubset(parsedprogs[idx])
			cb()
		.catch (err) ->
			cb err

	it 'should run the first program in the list', (cb) ->
		parsedprogs = JSON.parse fs.readFileSync("#{__dirname}/resources/parsedprogs.json",'UTF-8')

		hm.getPrograms(ccu, false)
		.then (result) ->
			result[0].run().then ->
				lastprog.should.equal result[0].id
				cb()
		.catch (err) ->
			cb err

	it 'should return the xml as object for getPrograms with raw flag' , (cb) ->
		fname = path.join __dirname, "resources/programlist.xml"
		xml = fs.readFileSync fname, 'UTF-8'

		xml2js.parseStringAsync(xml).then (expectation) ->
			hm.getPrograms(ccu, true)
			.then (result) ->
				result.should.deep.equal expectation
				cb()
			.catch (err) ->
				cb err

	it 'should return a parsed state list when calling getStates', (cb) ->
		parsedstates = JSON.parse fs.readFileSync("#{__dirname}/resources/parsedstates.json",'UTF-8')

		hm.getStates(ccu, false)
		.then (result) ->
			result.should.deep.equal parsedstates
			cb()
		.catch (err) ->
			cb err

	it 'should return the xml as object for getStates with raw flag' , (cb) ->
		fname = path.join __dirname, "resources/statelist.xml"
		xml = fs.readFileSync fname, 'UTF-8'

		xml2js.parseStringAsync(xml).then (expectation) ->
			hm.getStates(ccu, true)
			.then (result) ->
				result.should.deep.equal expectation
				cb()
			.catch (err) ->
				cb err
