expect = require('chai').expect
rewire = require 'rewire'
uut = rewire('../lib/index').__get__('urlOf')



describe "Url generation", ->
	it "should return the plain URL", ->
		ip = '192.168.178.20'
		script = 'statelist'
		vars = {}
		ref = 'http://192.168.178.20/config/xmlapi/statelist.cgi'

		res = uut(ip,script,vars)
		expect(res.url).to.equal ref

	it "should return the URL and one query param", ->
		ip = '192.168.178.20'
		script = 'statelist'
		vars = { 'id' : 55 }
		ref = 'http://192.168.178.20/config/xmlapi/statelist.cgi'

		res = uut(ip,script,vars)
		expect(res.url).to.equal ref
		expect(res.qs).to.equal vars

	it "should return the URL and several query params", ->
		ip = '192.168.178.20'
		script = 'statelist'
		vars = { 'id' : 55, 'mode' : 'foreced' }
		ref = 'http://192.168.178.20/config/xmlapi/statelist.cgi'

		res = uut(ip,script,vars)
		expect(res.url).to.equal ref
		expect(res.qs).to.equal vars
