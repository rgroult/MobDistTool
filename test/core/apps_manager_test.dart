import 'package:test/test.dart';
import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../../server/config/src/mongo.dart' as mongo;
import '../../server/managers/managers.dart' as mdt_mgr;
/*
import '../bin/managers/apps_manager.dart' as app_mgr;
import '../bin/managers/users_manager.dart' as user_mgr;

*/
void main() {
  test("init database", () async {
    var value = await mongo.initialize();
  });

  allTests();

  test("close database", () async {
    var value = await objectory.close();
  });
}

void allTests()  {
  test("Clean database", () async {
    await objectory.dropCollections();
  });
  group("Application", () {
    test("Create app empty fields", () async {
      //null platform
      var result = false;
      try {
        var result = await mdt_mgr.createApplication("test", null);
      } on StateError catch (e) {
        result = true;
        expect((e is mdt_mgr.AppError), isTrue);
      }
      expect(result, isTrue);
      //null name
      result = false;
      try {
        var result = await mdt_mgr.createApplication(null, "IOS");
      } on StateError catch (e) {
        result = true;
        expect((e is mdt_mgr.AppError), isTrue);
      }
      expect(result, isTrue);
    });
    var appName = "test";
    var appIOS = "IOS";
    var appAndroid = "Android";
    var description = 'blah blah blah';
    var description2 = 'blah blah blah again';
    test("Create app", () async {
      var email = "testApp@user.com";
      var user = await mdt_mgr.createUser("usertemp",email,"password");
      var app = await mdt_mgr.createApplication(appName,appIOS,description:description,adminUser:user);
      expect(app.name, equals(appName));
      expect(app.platform, equals(appIOS));
      expect(app.description, equals(description));
      expect(app.uuid, isNotNull);
      expect(app.adminUsers.isEmpty,isFalse);
    });
    test("Create same app", () async {
      var result = false;
      try {
        var result = await mdt_mgr.createApplication(appName,appIOS);
      } on StateError catch (e) {
        result = true;
        expect((e is mdt_mgr.AppError), isTrue);
      }
      expect(result, isTrue);
    });
    test("Create app same name, another platform", () async {
      var app = await mdt_mgr.createApplication(appName,appAndroid);
      expect(app.name, equals(appName));
      expect(app.platform, equals(appAndroid));
      expect(app.adminUsers.isEmpty,isTrue);
    });
    test("search app", () async {
      var app = await mdt_mgr.findApplication(appName,appIOS);
      expect(app.name, equals(appName));
      expect(app.platform, equals(appIOS));
      expect(app.adminUsers.isEmpty,isFalse);

      app = await mdt_mgr.findApplication(appName,appAndroid);
      expect(app.name, equals(appName));
      expect(app.platform, equals(appAndroid));
      expect(app.adminUsers.isEmpty,isTrue);
    });

    test("search app by id", () async {
      var app = await mdt_mgr.findApplication(appName,appIOS);
      var appByUuid = await mdt_mgr.findApplicationByUuid(app.uuid);
      expect(app.name, equals(appByUuid.name));
    });

    test("Add admin user to app", () async {
        var email = "test@user.com";
        var user = await mdt_mgr.createUser("user1",email,"password");
        var appiOS = await mdt_mgr.findApplication(appName,appIOS);
        await mdt_mgr.addAdminApplication(appiOS,user);
        expect(appiOS.adminUsers.contains(user),isTrue);
       // app.adminUsers.add(user);
     //   await app.save();
        appiOS = await mdt_mgr.findApplication(appName,appIOS);
        expect(appiOS.adminUsers.contains(user),isTrue);

        //retrieve other app
        var applicationAndroid = await mdt_mgr.findApplication(appName,appAndroid);
        expect(applicationAndroid.adminUsers.isEmpty,isTrue);

        //alls apps for user
        var allApps = await mdt_mgr.findAllApplicationsForUser(user);
        var currentAdminUserNbre = appiOS.adminUsers.length;
        //delete user
        await mdt_mgr.deleteUserByEmail(email);
        //check user deleted
        user = await mdt_mgr.findUserByEmail(email);
        expect(user,isNull);
        //retrieve app and check admin users is empty
        appiOS = await mdt_mgr.findApplication(appName,appIOS);
        expect(appiOS.adminUsers.length,equals(currentAdminUserNbre-1));
    });
    test("alls apps", () async {
      var allApps = await mdt_mgr.allApplications();
      expect(allApps.length,equals(2));
    });

    test("update app KO", () async {
      var result = false;
      var app = await mdt_mgr.findApplication(appName,appAndroid);
      try {
        await mdt_mgr.updateApplication(app,platform:appIOS);
      }on StateError catch (e) {
        result = true;
        expect((e is mdt_mgr.AppError), isTrue);
      }
      expect(result, isTrue);
    });

    test("update app OK", () async {
      var result = true;
      var app = await mdt_mgr.findApplication(appName,appAndroid);
      try {
        var newDesc = "new descrioption";
        var newPlatform ="TVOS";
        await mdt_mgr.updateApplication(app,platform:newPlatform,description:newDesc);
        expect(app.description,equals(newDesc));
        expect(app.platform,equals(newPlatform));
      }on StateError catch (e) {
        result = false;
      }
      expect(result, isTrue);
    });

    test("delete app", () async {
      var app = await mdt_mgr.findApplication(appName,appIOS);
      expect(app,isNotNull);
      await mdt_mgr.deleteApplication(appName,appIOS);
      app = await mdt_mgr.findApplication(appName,appIOS);
      expect(app,isNull);
    });
  });
}

/*Future updateApplication(MDTApplication app, {String name, String platform, MTDUser adminUser,String description}) async {
*/