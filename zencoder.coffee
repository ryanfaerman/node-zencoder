https = require 'https'
url = require 'url'
_ = require 'underscore'
fs = require 'fs'
querystring = require 'querystring'


class exports.Zencoder
	base_url: 'https://app.zencoder.com/api/v2'
	api_key: ''
	cert: fs.readFileSync 'zencoder_ca_chain.crt'

	version: '0.0.1'
	default_options:
		timeout: 10000
		headers:
			'Accept': 'application/json'
			'Content-Type': 'application/json'
			'User-Agent': "node-zencoder v-#{@::version}"
	@Response =
		code: 0
		body: ''
		raw_body: ''

	Job:
		list: (cb) =>
			@get '/jobs', cb
		create: (job, cb) =>
			@post '/jobs', job, cb
		details: (jobId, cb) =>
			@get "/jobs/#{jobId}.json", cb
		resubmit: (jobId, cb)=>
			@put "/jobs/#{jobId}/resubmit.json", cb
		cancel: (jobId, cb) =>
			@put "/jobs/#{jobId}/cancel.json", cb
		progress: (jobId, cb) =>
			@get "/jobs/#{jobId}/progress.json", cb
	
	Input:
		details: (inputId, cb) =>
			@get "/inputs/#{inputId}.json", cb
		progress: (inputId, cb) =>
			@get "/inputs/#{inputId}/progress.json", cb
	
	Output:
		details: (outputId, cb) =>
			@get "/outputs/#{outputId}.json", cb
		progress: (outputId, cb) =>
			@get "/outputs/#{outputId}/progress.json", cb
	
	Notification:
		list: (options, cb) =>
			@get '/notifications', options, cb
	
	Account:
		create: (params, options, cb)=>
			@post '/account', params, options
		details: (cb)=>
			@get '/account', cb
		integration: (cb) =>
			@put '/account/integration', cb
		live: (cb) =>
			@put '/account/live', cb
	
	Reports:
		minutes: (options, cb) =>
			@get '/reports/minutes', options, cb

	process = (method, request_url, body = {}, options = {}, cb = () ->) =>
		cb = body if typeof body is 'function'
		cb = options if typeof options is 'function'

		method = method.toUpperCase()

		request_url = url.parse @::base_url + request_url
		request_url.protocol = request_url.protocol.replace ':', ''
		
		body = _.extend api_key: @::api_key, body
		payload = JSON.stringify(body) unless method is 'GET'
		

		options = _.extend @::default_options, options
		headers = options.headers
		headers = _.extend('Content-Length': payload.length, headers) unless method is 'GET'
		

		http_options =
			host: request_url.hostname
			port: request_url.port
			path: request_url.path
			method: method
			headers: headers
			cert: @::cert

		if method is 'GET' then http_options.path += "?#{querystring.stringify body}" 
		response = _.clone @Response
		
		req = https.request http_options, (res) ->
			response.code = res.statusCode
			res.on 'data', (d) ->
				response.raw_body += d
			res.on 'end', ->

				if response.raw_body? and response.raw_body.trim().length > 0
					response.body = JSON.parse response.raw_body

				cb(response)
			
		req.setTimeout options.timeout
		req.on 'error', (e) ->
			console.log e

		unless method is 'GET'
			req.write "#{payload}\n"
		req.end()
		
	
	@post = (request_url, body = {}, options = {}, cb = () ->) =>
		process 'POST', request_url, body, options
	@get = (request_url, body = {}, options = {}, cb = () ->) =>
		process 'GET', request_url, body, options, cb
	@put = (request_url, body = {}, options = {}, cb = () ->) =>
		process 'PUT', request_url, body, options






