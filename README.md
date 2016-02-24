![MDT icon](DOC/MDT_banner.png)  
  
#  
#  

[![Build Status](https://travis-ci.org/rgroult/MobDistTool.svg?branch=master)](https://travis-ci.org/rgroult/MobDistTool)
[![License](http://img.shields.io/:license-mit-blue.svg)](https://github.com/codeship/documentation/blob/master/LICENSE.md)
[![Codeship Status](https://codeship.com/projects/dc7cfa30-5957-0133-768c-4255fd5efb39/status?branch=master)](https://codeship.com/projects/109988)
[![codecov.io](https://codecov.io/github/rgroult/MobDistTool/coverage.svg?branch=master)](https://codecov.io/github/rgroult/MobDistTool?branch=master)

**Note**: The `master` branch may be in an *unstable or even broken state* during development. Please use [releases][github-release] instead of the `master` branch in order to get stable binaries.
***
###Glossary
*Artifact*: A specific version of an application (etc: My great App V1.2.3) in an installable package (ex: IPA, APK)

*OTA*: Over the air.
***
# MDT


MDT is a mobile application OTA platform which allows to distribute and install multiple application's versions to registred users.

The mains specifications are:

* **RESTful server**
* **Responsive Web Client/admin interface**
* Upload of artifacts through Web Interface or with ** integration server like Jenkins**.
* Artifacts can be **grouped for a specific version** to have multiples artifacts per version (ex: production, integration, dev,etc..)
* **Artifacts have a branch parameters to reflect your git branch workflow** (or other structure if you want) to be capable of produce same version between them if necessary (ex: version X.Y.Z on dev branch for tests before commit to master).
* **All registered applications are public for all registered users. No need to manage application acess by users**. 
* Users registration can be filtered by **white emails domains with activation email**.
* **Application has a specific version latest version** witch allows to provided latest builds to continuous tester after each build.
* **Install OTA for artifacts**.


## Supported Mobile platforms

MDT can manage any kind of artifacts but yet, only **IOS And Android** OTA install is managed so platform allows only IOS and Android application for now (aka .ipa and .apk artifacts). 

# Architecture

MDT server is written in [Dart] with mongoDB database for Users,Application an artifacts metadata. Artifact files(.ipa, .apk) are stored on an external storage (now: googledrive). 

MDT web is written in Dart with Angular dart [AngularDart], [Angular UI] and and bootstrap with material theme. Web GUI is also compiled in javascript for running in all browsers (build/web).

**Note**:A mobile application written with [Flutter] will be available in next months.

[Dart]: https://www.dartlang.org
[AngularDart]:https://angulardart.org
[Angular UI]:http://www.angulardartui.com
[Flutter]:https://flutter.io


## Getting Started

### Getting and running MDT

The easiest way to get ant test MDT is to use **[docker pre-built images][docker]**.
Instructions to configure it is on configuration section.

You can install manually MDT from the `master` branch and run:

```
pub install
dart bin/server.dart

>> MDT starting ...
>> logging file : mdt_logs_20160220.txt
>> ...
>> bind localhost on port 8080
>> MDT started on port 8080.
>> You can access server Web UI on http://localhost:8080/web/

```

**Note**: You need a reachable mongoDB server to start server.

See instructions section to configure server.
[docker]:https://hub.docker.com/r/rgroult/mobdisttool/


# Configuration

Configuration can be done with a 'config.json' file in 'server/config/' directory.
Each config key can be overridden by environnement value with same key.

Sample:

```
cat ./server/config/config.json

{
  "MDT_DATABASE_URI":"mongodb://localhost:27017/mdt_dev",
  "MDT_STORAGE_NAME":"yes_storage_manager",
  "MDT_STORAGE_CONFIG":{},
  "MDT_SMTP_CONFIG":{
    "serverUrl" : "smtp.gmail.com",
    "username":"XXXX@gmail.com",
    "password":"XXXXXXX"
  },
  "MDT_REGISTRATION_WHITE_DOMAINS":["@gmail.com"],
  "MDT_REGISTRATION_NEED_ACTIVATION":"true"
 }
  
```
* ***MDT_DATABASE_URI***:  MongoDB database location.
* ***MDT_STORAGE_NAME***:  External storage used for artifact file.
* ***MDT_STORAGE_CONFIG***:  External storage configuration, see External Storage configuration for info.
* ***MDT_SMTP_CONFIG***:  SMTP server configuration for emails (activation,...).
* ***MDT_REGISTRATION_WHITE_DOMAINS***: Array of white suffix emails allowed for registration. If empty, no filter will be apply for registration.
* ***MDT_REGISTRATION_NEED_ACTIVATION***: 'true' if registration use a activation email to activate account.

### External Storages 

work in progress ..


#Why use MDT ?

* Unlike other solutions ([Fabrics], [TestFlight],...), you have no need to add all your users emails or manage groups to distribute your apps. Users can register themself (with white domains email configuration if needed) and access all your distributes apps. This is very usefull for example on IOS with 'InHouse' certificates in company where anybody can test beta versions of applications.

* You can delete artifacts, to avoid out of date versions (certificats expiration, bad versions, etc..)

* MDT have a special "latest" version usefull if you have continous testers: no need to make a new version after each fonctionality implemented.

* All your artifacts are stored in **yours** storage area 



[Fabrics]: https://get.fabric.io
[TestFlight]: https://developer.apple.com/testflight/
  
### License

MDT is under the MIT license. See the [LICENSE](LICENSE) file for details.