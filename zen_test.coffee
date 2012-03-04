{Zencoder} = require './zencoder'

Zencoder::api_key = ''

###
Zencoder::api_version = 1
###

###
Zencoder::Job.create 
	input: 's3://timelesstorah.com/010308.mp3'
	outputs: [
		format: 'mp4'
		audio_normalize: yes
		rrs: yes
		public: yes
		url: 's3://timelesstorah.com/zencoder/010308.mp4'
	,
		format: 'mp3'
		audio_normalize: yes
		rrs: yes
		public: yes
		url: 's3://timelesstorah.com/zencoder/010308.mp3'
	,
		format: 'ogg'
		audio_normalize: yes
		rrs: yes
		public: yes
		url: 's3://timelesstorah.com/zencoder/010308.ogg'
	]
, (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res
###

###
Zencoder::Job.list (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.body
###

###
Zencoder::Job.details 13852800, (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.body
###

###
Zencoder::Job.resubmit 13852800, (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.code
	console.log res.body
###

###
Zencoder::Job.cancel 13852800, (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.code
	console.log res.body
###



###
Zencoder::Job.progress 13852800, (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.code
	console.log res.body
###

###
Zencoder::Input.details 13852776, (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.code
	console.log res.body
###

###
Zencoder::Input.progress 13852776, (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.code
	console.log res.body
###
###
Zencoder::Output.details 21245746, (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.code
	console.log res.body
###
###
Zencoder::Output.progress 21245746, (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.code
	console.log res.body
###

###
params =
	per_page: 10
	page: 2
Zencoder::Notification.list params, (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.code
	console.log res.body
###

###
account =
	email: 'ryan+testAccount1@faerman.net'
	terms_of_service: "1"
Zencoder::Account.create account, (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.code
	console.log res.body
###


Zencoder::Account.details (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.code
	console.log res.body

###
Zencoder::Account.integration (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.code
	console.log res.body
###
###
Zencoder::Account.live (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.code
	console.log res.body
###

###
Zencoder::Reports.minutes (res) ->
	console.log "GOT A RESPONSE IN MAH CALLBACK"
	console.log res.code
	console.log res.body
###

