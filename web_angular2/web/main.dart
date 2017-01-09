// Copyright (c) 2016, rgroult. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:angular2/platform/browser.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';
import 'package:angular2/router.dart' show ROUTER_PROVIDERS;
import "package:angular2/src/platform/location.dart";
import 'lib/components/app_component.dart';
import 'lib/components/modals_components.dart';
import 'lib/services/modal_service.dart';
import 'lib/services/src/mdt_http_client.dart';

main() {
  bootstrap(AppComponent,
      [
        ROUTER_PROVIDERS,
        provide(Client, useFactory: () => new  MDTHttpClient()/* BrowserClient()*/, deps: []),
        provide(LocationStrategy, useClass: HashLocationStrategy)
      ]);
}
