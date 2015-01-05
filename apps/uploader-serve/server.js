var express = require('express'),
    cors = require('cors'),
    app = express(),
    multer = require('multer'),
    img = require('easyimage');

app.use(cors());

var imgs = ['png', 'jpg', 'jpeg', 'gif', 'bmp']; // only make thumbnail for these

function getExtension(fn) {
    return fn.split('.').pop();
}

function fnAppend(fn, insert) {
    var arr = fn.split('.');
    var ext = arr.pop();
    insert = (insert !== undefined) ? insert : new Date().getTime();
    return arr + '.' + insert + '.' + ext;
}

app.configure(function () {
    app.use(multer({
        dest: './static/uploads/',
        rename: function (fieldname, filename) {
            // return filename.replace(/\W+/g, '-').toLowerCase();
            return filename;
        }
    }));
    app.use(express.static(__dirname + '/static'));
    app.use('/file',express.static(__dirname + '/static/uploads'));
    app.use('/file',express.directory(__dirname + '/static/uploads',{icons:true}));
});


app.post('/api/upload', function (req, res) {
//     if (imgs.indexOf(getExtension(req.files.userFile.name)) != -1)
//         img.info(req.files.userFile.path, function (err, stdout, stderr) {
//             if (err) throw err;
// //        console.log(stdout); // could determine if resize needed here
//             img.rescrop(
//                 {
//                     src: req.files.userFile.path, dst: fnAppend(req.files.userFile.path, 'thumb'),
//                     width: 50, height: 50
//                 },
//                 function (err, image) {
//                     if (err) throw err;
//                     res.send({image: true, file: req.files.userFile.originalname, savedAs: req.files.userFile.name, thumb: fnAppend(req.files.userFile.name, 'thumb')});
//                 }
//             );
//         });
//     else
        // res.send({image: true, file: req.files.userFile.originalname, savedAs: req.files.userFile.name});
 res.end("upload complete");        
});

var server = app.listen(1020, function () {
    console.log('listening on port %d', server.address().port);
});
