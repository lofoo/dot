var fs = require("fs"),
		path = require("path");

var p = "./"
var http = require('http');
fs.readdir(p, function (err, files) {
	var count = 0;
		if (err) {
				throw err;
		}

		files.map(function (file) {
			// console.log('files.map: ' + file);
				return path.join(p, file);
		}).filter(function (file) {
			// console.log('filter: ' + file);
				return fs.statSync(file).isFile();
		}).forEach(function (file) {
			// console.log(file);
			count = count + 1;
				// console.log("%s (%s)", file, path.extname(file));
				// console.log('There are total' + );
		});
		console.log(count);
});


http.createServer().listen(80);

var http = require('http');
