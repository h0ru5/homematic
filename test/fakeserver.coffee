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

hm = require '../lib/homematic'

ccu='localhost:4000'
lastprog = -1
dp = {}

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
					when 'statelist.cgi'
						readFile('statelist.xml').pipe resp
					when 'runprogram.cgi'
						progid =  url.parse(req.url,true).query['program_id']
						lastprog = progid
						resp.end()
					when 'statechange.cgi'
						ise_id = url.parse(req.url,true).query['ise_id']
						new_value = url.parse(req.url,true).query['new_value']
						dp[ise_id]=new_value
						resp.end "<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?><result><changed id=\"#{ise_id}\" new_value=\"#{new_value}\" /></result>"
					else
						throw new Error("unkown cgi script called: #{tok[3]}")
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
				obj.should.containSubset parsedprogs[idx]
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
			result.forEach (obj,idx) ->
				obj.should.containSubset parsedstates[idx]
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

	it 'should set a new state for ise 123', (cb) ->

		hm.setState(ccu,123,0.8)
		.then (result) ->
			dp['123'].should.equal(0.8 + '')
			cb()
		.catch (err) ->
			cb err

	it 'should return an array of datapoints', (cb) ->
		parsedDps = JSON.parse fs.readFileSync("#{__dirname}/resources/datapoints.json",'UTF-8')
		hm.getDataPoints(ccu)
		.then (result) ->
			result.forEach (obj,idx) ->
				obj.should.containSubset parsedDps[idx]
			cb()
		.catch (err) ->
			cb err

	it 'should set a new state for the first datapoint', (cb) ->
		hm.getDataPoints(ccu)
		.then (result) ->
			myDp = result[0]
			oV = myDp.value
			nV = 0.5*oV
			myDp.set(nV).then ->
				dp[myDp.id].should.equal(nV+'')
			cb()
		.catch (err) ->
			cb err
