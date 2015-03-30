module.exports = (grunt) ->

	pkg = grunt.file.readJSON('package.json')
	commitMessage = grunt.option('m') || '.';
	repo = grunt.option('repo') || "dokku";

	grunt.initConfig
		coffee:
		  dist:
		    options:
		      bare:true
		      sourceMap: false
		    expand: true
		    flatten: false
		    cwd: "src"
		    src: ["**/*.coffee"]
		    dest: "dist"
		    ext: ".js"
		copy:
			dist:
				files: [
					{
						expand: true
						cwd: "src/"
						src: ["assets/**/*", "**/*.hbs", "**/*.html"]
						dest: "dist/"
					}
				]
		clean:
			dist: ["dist/"]
		bower:
	      install:
	        options:
	          install: true
	          copy: true
	          cleanBowerDir: true
	          cleanTargetDir: true
	          targetDir: "dist/vendor/components"
	          bowerOptions:
	            production: false
		browserify:
			app:
				files:
					'dist/client/build/app.js': ["dist/client/**/*.js", "!dist/client/build/app.js"]
		foreman:
			dev:
				env: ["dev.env"]
				procfile: "Procfile"
				port: 8080
		shell:
			push:
				command: () ->
					"git add .; git commit -m '" + commitMessage + "';git push " + repo + " master"
		uglify:
			app:
				files:
					'dist/client/build/app.js': ["dist/client/build/app.js"]
		ngAnnotate:
			app:
				files: [
					{
						expand: true
						src: ["dist/client/**/*.js", "!dist/client/build/app.js"]
					}
				]



	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-sass'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-bower-task'
	grunt.loadNpmTasks 'grunt-browserify'
	grunt.loadNpmTasks 'grunt-shell'
	grunt.loadNpmTasks 'grunt-foreman'
	grunt.loadNpmTasks 'grunt-ng-annotate'

	grunt.registerTask 'initialize', ["clean:dist", "coffee", "copy", "bower", "ngAnnotate", "browserify", "uglify"]
	grunt.registerTask 'update', ["coffee", "copy", "ngAnnotate", "browserify"]

	grunt.registerTask 'serve', ["update", "foreman"]

	grunt.registerTask 'push', ["shell:push"]

	grunt.registerTask 'dokku:production', ["initialize"]