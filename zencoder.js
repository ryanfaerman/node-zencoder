(function() {
  var fs, https, querystring, url, _;

  https = require('https');

  url = require('url');

  _ = require('underscore');

  fs = require('fs');

  querystring = require('querystring');

  exports.Zencoder = (function() {
    var process;
    var _this = this;

    function Zencoder() {}

    Zencoder.prototype.base_url = 'https://app.zencoder.com/api/v2';

    Zencoder.prototype.api_key = '';

    Zencoder.prototype.cert = fs.readFileSync('zencoder_ca_chain.crt');

    Zencoder.prototype.version = '0.0.1';

    Zencoder.prototype.default_options = {
      timeout: 10000,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': "node-zencoder v-" + Zencoder.prototype.version
      }
    };

    Zencoder.Response = {
      code: 0,
      body: '',
      raw_body: ''
    };

    Zencoder.prototype.Job = {
      list: function(cb) {
        return Zencoder.get('/jobs', cb);
      },
      create: function(job, cb) {
        return Zencoder.post('/jobs', job, cb);
      },
      details: function(jobId, cb) {
        return Zencoder.get("/jobs/" + jobId + ".json", cb);
      },
      resubmit: function(jobId, cb) {
        return Zencoder.put("/jobs/" + jobId + "/resubmit.json", cb);
      },
      cancel: function(jobId, cb) {
        return Zencoder.put("/jobs/" + jobId + "/cancel.json", cb);
      },
      progress: function(jobId, cb) {
        return Zencoder.get("/jobs/" + jobId + "/progress.json", cb);
      }
    };

    Zencoder.prototype.Input = {
      details: function(inputId, cb) {
        return Zencoder.get("/inputs/" + inputId + ".json", cb);
      },
      progress: function(inputId, cb) {
        return Zencoder.get("/inputs/" + inputId + "/progress.json", cb);
      }
    };

    Zencoder.prototype.Output = {
      details: function(outputId, cb) {
        return Zencoder.get("/outputs/" + outputId + ".json", cb);
      },
      progress: function(outputId, cb) {
        return Zencoder.get("/outputs/" + outputId + "/progress.json", cb);
      }
    };

    Zencoder.prototype.Notification = {
      list: function(options, cb) {
        return Zencoder.get('/notifications', options, cb);
      }
    };

    Zencoder.prototype.Account = {
      create: function(params, options, cb) {
        return Zencoder.post('/account', params, options);
      },
      details: function(cb) {
        return Zencoder.get('/account', cb);
      },
      integration: function(cb) {
        return Zencoder.put('/account/integration', cb);
      },
      live: function(cb) {
        return Zencoder.put('/account/live', cb);
      }
    };

    Zencoder.prototype.Reports = {
      minutes: function(options, cb) {
        return Zencoder.get('/reports/minutes', options, cb);
      }
    };

    process = function(method, request_url, body, options, cb) {
      var headers, http_options, payload, req, response;
      if (body == null) body = {};
      if (options == null) options = {};
      if (cb == null) cb = function() {};
      if (typeof body === 'function') cb = body;
      if (typeof options === 'function') cb = options;
      method = method.toUpperCase();
      request_url = url.parse(Zencoder.prototype.base_url + request_url);
      request_url.protocol = request_url.protocol.replace(':', '');
      body = _.extend({
        api_key: Zencoder.prototype.api_key
      }, body);
      if (method !== 'GET') payload = JSON.stringify(body);
      options = _.extend(Zencoder.prototype.default_options, options);
      headers = options.headers;
      if (method !== 'GET') {
        headers = _.extend({
          'Content-Length': payload.length
        }, headers);
      }
      http_options = {
        host: request_url.hostname,
        port: request_url.port,
        path: request_url.path,
        method: method,
        headers: headers,
        cert: Zencoder.prototype.cert
      };
      if (method === 'GET') {
        http_options.path += "?" + (querystring.stringify(body));
      }
      response = _.clone(Zencoder.Response);
      req = https.request(http_options, function(res) {
        response.code = res.statusCode;
        res.on('data', function(d) {
          return response.raw_body += d;
        });
        return res.on('end', function() {
          if ((response.raw_body != null) && response.raw_body.trim().length > 0) {
            response.body = JSON.parse(response.raw_body);
          }
          return cb(response);
        });
      });
      req.setTimeout(options.timeout);
      req.on('error', function(e) {
        return console.log(e);
      });
      if (method !== 'GET') req.write("" + payload + "\n");
      return req.end();
    };

    Zencoder.post = function(request_url, body, options, cb) {
      if (body == null) body = {};
      if (options == null) options = {};
      if (cb == null) cb = function() {};
      return process('POST', request_url, body, options);
    };

    Zencoder.get = function(request_url, body, options, cb) {
      if (body == null) body = {};
      if (options == null) options = {};
      if (cb == null) cb = function() {};
      return process('GET', request_url, body, options, cb);
    };

    Zencoder.put = function(request_url, body, options, cb) {
      if (body == null) body = {};
      if (options == null) options = {};
      if (cb == null) cb = function() {};
      return process('PUT', request_url, body, options);
    };

    return Zencoder;

  }).call(this);

}).call(this);
