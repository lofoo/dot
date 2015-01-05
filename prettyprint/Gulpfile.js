var gulp=require('gulp');
var webserver = require('gulp-webserver');

gulp.task('webserver', function() {
  gulp.src(['./','!node_modules','!vendor','!.git'])
    .pipe(webserver({
      livereload: true,
      directoryListing: true,
      host:'0.0.0.0'
    }));
});