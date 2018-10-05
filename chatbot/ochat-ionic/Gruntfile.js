/**
 * Copyright© 2017, Oracle and/or its affiliates. All rights reserved.
 *
 * @author Yuri Panshin
 */
'use strict';


module.exports = function(grunt) {

  grunt.initConfig({

    clean: {
      dist: [
        './dist'
      ]
    },

    copy: {
      dist: {
        expand: true,
        cwd: './platforms/browser/www/',
        src: [
          '**/*'
        ],
        dest: './dist',
        filter: 'isFile'
      },
      logo: {
        expand: true,
        cwd: './platforms/browser/img/',
        src: [
          '**/*'
        ],
        dest: './dist/img',
        filter: 'isFile'
      }
    },

    replace: {
      xml:{
        src: ['./dist/cordova.js'],
        overwrite: true,
        replacements: [{
          from: 'xhr.open("get", "/config.xml", true);',
          to: 'xhr.open("get", "config.xml", true);'
        }]
      },
      logo:{
        src: ['./dist/plugins/cordova-plugin-splashscreen/src/browser/SplashScreenProxy.js'],
        overwrite: true,
        replacements: [{
          from: 'var imageSrc = \'/img/logo.png\';',
          to: 'var imageSrc = \'img/logo.png\';'
        }]
      }
    },
  });



  grunt.registerTask('build', '', [
    'clean',
    'copy',
    'replace'
  ]);


  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-text-replace');
  grunt.loadNpmTasks('grunt-contrib-clean');

};
