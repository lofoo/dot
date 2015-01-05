var fs = require('fs');

var archiver = require('archiver');

//var directory = require('serve-index');
var express = require('express');
app = module.exports = express();


app.use(function (req, res,next) {

var archive = archiver('zip');
archive.on('error', function(err) {
  throw err;
});

 res.setHeader('Content-disposition', 'attachment; filename=node-archiver.zip');

archive.pipe(res);

archive.bulk([
  { expand: true, cwd: 'nodeclub/', src: ['**'] }
]);

archive.finalize();

});

app.listen(80);
  console.log('Express-node-archiver started on port %d', 80);
