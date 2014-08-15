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
		expect(res).to.equal ref
