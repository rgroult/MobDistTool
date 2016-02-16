# MobDistTool : Mobile Application Distribution Tool

[![Build Status](https://travis-ci.org/rgroult/MobDistTool.svg?branch=master)](https://travis-ci.org/rgroult/MobDistTool)
[![License](http://img.shields.io/:license-mit-blue.svg)](https://github.com/codeship/documentation/blob/master/LICENSE.md)
[![Codeship Status](https://codeship.com/projects/dc7cfa30-5957-0133-768c-4255fd5efb39/status?branch=master)](https://codeship.com/projects/109988)
[![codecov.io](https://codecov.io/github/rgroult/MobDistTool/coverage.svg?branch=master)](https://codecov.io/github/rgroult/MobDistTool?branch=master)

# Overview

This solution allows to store different application's versions IOS and Android and distribute them to tester. 
You can upload them manually through Web Interface or automatically with integration server like Jenkins. 
Application's version can be grouped to be able to have multiple application file called "artifact" for a specific version (ex dev, integration, prod...).

Artifacts also have a branch parameter to reflect your git branches (or other structure if you want) and have the capability to produce same versions between them if necessary.

Platform have also a specific version 'latest' version witch allows to provided latest builds to continuous tester after each build.

# Supported platforms

Platform can manage any kind of file but yet, only IOS And Android installation of artifact is managed so platform allows only IOS and Android application for now, aka .ipa and .apk. 

# Glossary
writing in progress ..

# Goal
writing in progress ..
# Architecture

All platform is written with Dart (https://www.dartlang.org). Server use mongoDB for Users, Applications and Artifacts data. Artifact files (ipa, apk) are stored in another storage.
Platform provides yet 2 artifact storage : fake storage (yes storage) and google drive. Another storage backends will be implemented soon..
RPC Api is provided by Shelf (RPC, ROUTE, AUTH, CORS) frameworks.

Web client is also written in Dart language with angular dart framework and bootstrap with material theme.

A mobile application written with flutter will be available in next months.

# Install
writing in progress ..
    # Local
    # Docker
    
# Configuration
writing in progress ..
# Versus other solutions

  writing in progress ..