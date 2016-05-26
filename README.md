![MDT icon](doc/MDT_banner.png)  
  
#  
#  

[![Build Status](https://travis-ci.org/rgroult/MobDistTool.svg?branch=master)](https://travis-ci.org/rgroult/MobDistTool)
[![License](http://img.shields.io/:license-mit-blue.svg)](https://github.com/codeship/documentation/blob/master/LICENSE.md)
[![Codeship Status](https://codeship.com/projects/dc7cfa30-5957-0133-768c-4255fd5efb39/status?branch=master)](https://codeship.com/projects/109988)
[![codecov.io](https://codecov.io/github/rgroult/MobDistTool/coverage.svg?branch=master)](https://codecov.io/github/rgroult/MobDistTool?branch=master)

**Note**: The `master` branch may be in an *unstable or even broken state* during development. Please use [releases](https://github.com/rgroult/MobDistTool/releases) instead of the `master` branch in order to get stable binaries.
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

## Gallery

[![Home ][1]][2]
  [1]: doc/Gallery/home_small.png
  [2]: doc/Gallery/home.png
  
 [![Apps ][3]][4]
  [3]: doc/Gallery/apps_small.png
  [4]: doc/Gallery/apps.png

[![Apps ][5]][6]
  [5]: doc/Gallery/versions_small.png
  [6]: doc/Gallery/versions.png
  
[![Apps ][7]][8]
  [7]: doc/Gallery/qrcode_small.png
  [8]: doc/Gallery/qrcode.png

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

[docker]:https://hub.docker.com/r/rgroult2/mobdisttool/


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
  "MDT_REGISTRATION_NEED_ACTIVATION":"true",
  "MDT_TOKEN_SECRET":"secret token",
  "MDT_LOG_DIR":"",
  "MDT_SYSADMIN_INITIAL_PASSWORD":"sysadmin",
  "MDT_SYSADMIN_INITIAL_EMAIL":"admin@localhost.com",
  "MDT_LOGIN_DELAY":0,
  "MDT_PASSWORD_MIN_STRENGTH":0
 }
  
```
* ***MDT_DATABASE_URI***:  MongoDB database location.
* ***MDT_STORAGE_NAME***:  External storage used for artifact file.
* ***MDT_STORAGE_CONFIG***:  External storage configuration, see External Storage configuration for info.
* ***MDT_SMTP_CONFIG***:  SMTP server configuration for emails (activation,...).
* ***MDT_REGISTRATION_WHITE_DOMAINS***: Array of white suffix emails allowed for registration. If empty, no filter will be apply for registration.
* ***MDT_REGISTRATION_NEED_ACTIVATION***: 'true' if registration use a activation email to activate account.
* ***MDT_TOKEN_SECRET***: Secret used to secure links web token.
* ***MDT_LOG_DIR***: Log directory.
* ***MDT_SYSADMIN_INITIAL_PASSWORD***: Initial sysadmin password, created when no sysadmin present.
* ***MDT_SYSADMIN_INITIAL_EMAIL***: Initial sysadmin email, created when no sysadmin present.
* ***MDT_LOGIN_DELAY***: Delay before handle each login request. It can be use to limit load of brut force attack.
* ***MDT_PASSWORD_MIN_STRENGTH***: Minimum strength password required. [0,1,2,3,4] if crack time is less than [10\*\*2, 10\*\*4, 10\*\*6, 10\*\*8, Infinity]. See [xcvbnm] for more details.

[xcvbnm]: https://github.com/exitlive/xcvbnm

### External Storages 

MDT use mongoDB to store Users account, Applications and Artifact info but use a external storage for Artifact files (etc: .ipa, .apk).

There are currently 3 external storage managed by MDT.

#### Yes Storage

Yes storage is a fake storage wich respond always yes on storage requests en return always same file on get artifact file requests. It can be use for platform tests without install managed. 

Sample: 

```
cat ./server/config/config.json

{
  ...
  "MDT_STORAGE_NAME":"yes_storage_manager",
  "MDT_STORAGE_CONFIG":{},
  ...
 }
  
```


#### Google Drive Storage

As his name said, it use [Google Drive] as storage for Artifacts files.

[Google Drive]: https://www.google.com/intl/us_us/drive/

To use this storage you need to create a projet and download credentials file in [Google Developers Console] and copy it in the MDT_STORAGE_CONFIG value in config file (or through env set). 

For more informations and how to create project and download credentials, see [google documentation apis].

Sample: 

```
cat ./server/config/config.json

{
  ...
  "MDT_STORAGE_NAME":"google_drive_manager",
  "MDT_STORAGE_CONFIG":{
  	"project_id": "<please fill in>",
  	"private_key_id": "<please fill in>",
  	"private_key": "<please fill in>",
  	"client_email": "<please fill in>@developer.gserviceaccount.com",
  	"client_id": "<please fill in>.apps.googleusercontent.com",
  	"auth_uri": "<please fill in>",
  	"token_uri": "<please fill in>",
  	"auth_provider_x509_cert_url": "<please fill in>",
  	"client_x509_cert_url": "<please fill in>",
  	"type": "service_account"}, 
  ...
 }
  
```


[Google Developers Console]:https://console.developers.google.com/
[google documentation apis]: https://github.com/dart-lang/googleapis#using-a-service-account-for-a-cloud-api

#### Local Storage

This storage uses a local directory to store Artifacts file. Usefull with a NAS directory or Docker volumes. It create directory structure to store files.

Sample: 

```
cat ./server/config/config.json

{
  ...
  "MDT_STORAGE_NAME":"local_storage_manager",
  "MDT_STORAGE_CONFIG"={
  	"RootDirectory":"/data/MDT"
  	}, 
  ...
 }
  
```

#Artifacts provisionning

Artifacts provisionning can be done either through UI web or ethier directly on a non authenticate REST Api, only application private apiKey is needed. Usefull for integration server.

Apis:

* POST/DELETE on `/api/in/v1/artifacts/{apiKey}/{branch}/{version}/{artifactName}`
* POST/DELETE on `/api/in/v1/artifacts/{apiKey}/{branch}/{version}/{artifactName}`
* POST/DELETE on `/api/in/v1/artifacts/{apiKey}/last/{artifactName}`
* POST/DELETE on `/api/in/v1/artifacts/{apiKey}/last/{artifactName}`


MDT provides a python script to help using artifact provisionning.

**Note**: You need requests python module installed to use it.

For help:

```
curl -Ls http://<myserver>/api/in/v1/artifacts/{apiKey}/deploy | python - -h
```

Sample

```
From deploy input file:
	- version:
curl -Ls http://<myserver>/api/in/v1/artifacts/{apiKey}/deploy | python - ADD|DELETE fromFile sample.json

	- latest:
curl -Ls http://<myserver>/api/in/v1/artifacts/{apiKey}/deploy | python - ADD|DELETE --latest fromFile sample.json

cat sample.json
[{
    "branch":"master",
    "version":"X.Y.Z",
    "name":"dev",
     "file":"myGreatestApp_dev.ipa"
},{
    "branch":"master",
    "version":"X.Y.Z",
    "name":"prod",
     "file":"myGreatestApp.ipa"
},...]
Note : For latest deploy/delete somes unused values will be ignore.
Note: "file" path is relative from deployement file (sample.json in example)

From parameters:
	- version:
curl -Ls http://<myserver>/api/in/v1/artifacts/{apiKey}/deploy | python - ADD|DELETE fullParameters -version X.Y.Z -branch master -name prod -file app.apk|.ipa

	- latest:
curl -Ls http://<myserver>/api/in/v1/artifacts/{apiKey}/deploy | python - ADD|DELETE --latest fullParameters -name prod -file app.apk|.ipa


```
## Jenkins MDT deployment Plugin


**MDT provides a [Jenkins Plugin]** to make deployment easier and avoids use of python deploy script in Jenkins job configuration.

[Jenkins Plugin]:https://wiki.jenkins-ci.org/display/JENKINS/Mobile+App+Distribution+(MDT)++Plugin


# Additional functionality

## Retrieve Max Version for specific branch


In order to allows application to check if a newer version is available, MDT provides a anonymous check to retrieve the max version on a application (regarding a provided branch and a version name).

The mechanism use here is a share secret between application and MDT server (each MDT application has his own secret) and a timestamped request.** The validity of a signed request is yet 30 secs (regarding the server date of course)**. 

To enable this functionality you have to **selected it through UI in the create/update application panel ("Enable max version check (share secret will be generated)" checkbox)**. 
next, AppId and AppSecret will be displayed in the application versions details view (**'MAX VERSION' link**, don't forget to enable admin options to see it). 



MDT server Url :
    
    https://<myserver\>/api/applications/v1/app/<appId\>/maxversion/\<version name\>?\<signed query\>
    
 Signed query format :
 
    "ts=" + currentMillisecondTimestampSince1970 +"&branch=" + branch + "&hash=" + hash
  
  Hash computation:
  
```   
  hash = md5("ts=" + currentMillisecondTimestampSince1970 +"&branch=" + branch + "&hash=" + appSecret) 
```

The result of the request as a format :

```
 {
    data = {
        branch = master;  // requested branch
        downloadInfo =  {
            directLinkUrl = "<download link>"; // direct link for max version artifact 
            installUrl = "<install link>"; // install link for max version artifact 
            validity = 180; //links validity
        };
        name = prod; // requested version name
        version = "X.Y.8"; //  max version found
        };
    status = 200; // not used yet
 }
```

Example:

```
 appId = 33-343-4343
 appSecret = sqd*$/ùmzefmùqs
 branch = master
 name = prod
 
 currentMillisecondTimestampSince1970 = 122402423042342
 
 queryToSign format: "ts=" + currentMillisecondTimestampSince1970 +"&branch=" + branch + "&hash=" + appSecret
 
 md5("ts=122402423042342&branch=master&hash=sqd*$/ùmzefmùqs") =  "ed15111cfd7ec0674dc34a3ea8425907"
 
 finalQuery Format : "ts=" + currentMillisecondTimestampSince1970 +"&branch=" + branch + "&hash=" + md5
 query = "ts=122402423042342&branch=master&hash=ed15111cfd7ec0674dc34a3ea8425907"
 
 curl "https://<myserver>/api/applications/v1/app/33-343-4343/maxversion/prod?ts=122402423042342&branch=master&hash=ed15111cfd7ec0674dc34a3ea8425907"
 
 >>> 
 
  {
     data = {
         branch = master;
         downloadInfo =  {
             directLinkUrl = "https://<myserver>/api/.../file";
             installUrl = "itms-services://?action=download-manifest&url=https...";
             validity = 180;
         };
         name = prod;
         version = "<MyVersion>";
         };
     status = 200;
  }


 
```

# Why use MDT ?

* Unlike other solutions ([Fabrics], [TestFlight],...), you have no need to add all your users emails or manage groups to distribute your apps. Users can register themself (with white domains email configuration if needed) and access all your distributes apps. This is very usefull for example on IOS with 'InHouse' certificates in company where anybody can test beta versions of applications.

* You can delete artifacts, to avoid out of date versions (certificats expiration, bad versions, etc..)

* MDT have a special "latest" version usefull if you have continous testers: no need to make a new version after each fonctionality implemented.

* All your artifacts are stored in **your** storage area 


[Fabrics]: https://get.fabric.io
[TestFlight]: https://developer.apple.com/testflight/
  
### License

MDT is under the MIT license. See the [LICENSE](LICENSE) file for details.
