var gulp = require('gulp'),
	coffee = require('gulp-coffee'),
	mocha = require('gulp-mocha');


var paths = {
	libsrc  : 'src/**/*.coffee',
	examples : 'example/**/*.coffeee',
	tests : 'test/**/*.coffee'
}

gulp.task('lib', function() {
	return gulp.src(paths.libsrc)
		.pipe(coffee({bare:true}))
		.pipe(gulp.dest('lib'))
});

gulp.task('examples', function() {
	return gulp.src(paths.examples)
		.pipe(coffee({bare:true}))
		.pipe(gulp.dest('example'))
});

gulp.task('test',['lib'],function() {
	return gulp.src(paths.tests)
		.pipe(coffee({bare:true}))
		.pipe(gulp.dest('test'))
		.pipe(mocha());
});

gulp.task('watch',function() {
	gulp.watch(paths.lib,['lib']);
	gulp.watch(paths.examples,['examples']);
	gulp.watch([paths.lib,paths.tests],['test']);
});
