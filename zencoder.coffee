https = require 'https'
url = require 'url'
_ = require 'underscore'
fs = require 'fs'
querystring = require 'querystring'


class exports.Zencoder
	# These are our environment settings for the most part
	base_url: 'https://app.zencoder.com/api'
	api_key: ''
	api_version: 2
	cert: fs.readFileSync "#{__dirname}/zencoder_ca_chain.crt"

	# Version of the library
	version: '0.0.3'

	default_options:
		timeout: 10000
		api_version: @::api_version
		headers:
			'Accept': 'application/json'
			'Content-Type': 'application/json'
			'User-Agent': "node-zencoder v-#{@::version}"
	
	# Response object
	@Response =
		code: 0
		# JSON of the body
		body: ''
		# Raw Body String
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
			@post '/account', params, options, cb
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
		# Find the callback
		cb = body if typeof body is 'function'
		cb = options if typeof options is 'function'

		# Force method name to be consistent
		method = method.toUpperCase()

		payload = JSON.stringify(body) unless method is 'GET'

		options = _.extend @::default_options, options
		headers = options.headers
		headers = _.extend('Zencoder-Api-Key': @::api_key, headers)
		headers = _.extend('Content-Length': payload.length, headers) unless method is 'GET'

		
		use_version = options.api_version || @::api_version 
		api_version = ''
		if use_version > 1
			api_version = "/v#{use_version}"

		request_url = url.parse @::base_url + api_version + request_url
		request_url.protocol = request_url.protocol.replace ':', ''

		http_options =
			host: request_url.hostname
			port: request_url.port
			path: request_url.path
			method: method
			headers: headers
			ca: @::cert

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
		
	# Helper methods to make most of the methods clearer
	@post = (request_url, body = {}, options = {}, cb = () ->) =>
		process 'POST', request_url, body, options
	@get = (request_url, body = {}, options = {}, cb = () ->) =>
		process 'GET', request_url, body, options, cb
	@put = (request_url, body = {}, options = {}, cb = () ->) =>
		process 'PUT', request_url, body, options






