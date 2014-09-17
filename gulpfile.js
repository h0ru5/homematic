var gulp = require('gulp'),
	coffee = require('gulp-coffee'),
	mocha = require('gulp-mocha'),
	browserify = require('gulp-browserify'),
	git = require('gulp-git'),
	gutil = require('gulp-util'),
	bump = require('gulp-bump'),
	sourcemaps = require('gulp-sourcemaps'),
	uglify = require('gulp-uglify'),
	fs = require('fs');


var paths = {
	libsrc: 'src/**/*.coffee',
	examples: 'example/**/*.coffeee',
	tests: 'test/**/*.coffee',
}

gulp.task('lib', function () {
	return gulp.src(paths.libsrc)
		.pipe(coffee({
			bare: true
		}))
		.pipe(gulp.dest('dist/npm'))
});

gulp.task('examples', function () {
	return gulp.src(paths.examples)
		.pipe(coffee({
			bare: true
		}))
		.pipe(gulp.dest('example'))
});

gulp.task('test', ['lib'], function () {
	return gulp.src(paths.tests)
		.pipe(coffee({
			bare: true
		}))
		.pipe(gulp.dest('test'))
		.pipe(mocha());
});

gulp.task('browserify', ['lib'], function () {
	return gulp.src(paths.libsrc)
		.pipe(coffee({
			bare: true
		}))
		.pipe(browserify({
			standalone: 'homematic'
		}))
		.pipe(gulp.dest('dist/bower'));

});

gulp.task('bower-repo', function (cb) {
	fs.exists('dist/bower', function (exists) {
		if (!exists) {
			git.clone('git@github.com:h0ru5/homematic-bower.git', {
				args: '--tags dist/bower'
			}, cb);
		} else {
			git.pull('origin', 'master', {
				cwd: 'dist/bower'
			}, cb);
		}
	});
});

gulp.task('compile-bower', ['bower-repo'], function () {
	gutil.log('running browserify (takes a lot of time)...');

	return gulp.src(paths.libsrc)
		.pipe(sourcemaps.init({
			loadMaps: true
		}))
		.pipe(coffee({
			bare: true
		}))
		.pipe(browserify({
			standalone: 'homematic',
			debug : true
		}))
		.pipe(uglify())
		.pipe(sourcemaps.write('./'))
		.pipe(gulp.dest('dist/bower'))
});

gulp.task('bump-bower', ['bower-repo'], function () {
	gulp.src('dist/bower/bower.json')
		.pipe(bump())
		.pipe(gulp.dest('dist/bower/'));
});


gulp.task('commit-bower', ['compile-bower','bump-bower'], function () {
	gulp.src('dist/bower/*')
		.pipe(git.add({
			cwd: 'dist/bower'
		}))
		.pipe(git.commit('gulp auto-commit', {
			cwd: 'dist/bower'
		}))
});

gulp.task('publish-bower', ['commit-bower'], function (cb) {
	var version = JSON.parse(fs.readFileSync('dist/bower/bower.json', 'utf8')).version;
	gutil.log('publishing version ' + version);

	git.tag('v' + version, 'Version ' + version + ' (auto-created by gulp)', {
		cwd: 'dist/bower'
	}, function (err) {
		if (err) {
			gutil.log('created tag');
			cb(err);
		} else {
			gutil.log('pushing to github...');
			git.push('origin', 'master', {
				cwd: 'dist/bower',
				args: '--tags'
			}, function (err) {
				if (err) {
					gutil.log('error: ' + err);
					cb(err);
				} else {
					gutil.log('pushed commits & tags');
					cb();
				}
			}).end(); //dirty trick to call the pipe as a function
		}
	});
});
