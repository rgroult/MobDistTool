import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';
import 'package:qr/qr.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:html';
import '../service/mdt_query.dart';

@Component(
    selector: 'qr_code',
    useShadowDom: false,
    templateUrl: 'artifact_download_qrcode.html'
)
class ArtifactDownloadQRCode extends ShadowRootAware  {
  @NgAttr('title')
  String title;
  @NgAttr('artifactId')
  String artifactId;
  Modal modal;
  bool isloading = true;
  bool errorOccured = false;
  MDTQueryService mdtService;
  var sliderValue = 100;
  var qrCodeValidity = 0;
  var qrCodeEndOfValidity = null;
  Timer _timer = null;

  void onShadowRoot(ShadowRoot shadowRoot) {
    loadQrCode();
  }

  Future loadQrCode() async {
    try {
      if (_timer != null) {
        _timer.cancel();
      }
      var downloadInfos = await mdtService.artifactDownloadInfo(artifactId);
      generateQRCode(downloadInfos["installUrl"]);
      var validity = downloadInfos["validity"];
      if (validity != null) {
        sliderValue = 100;
        qrCodeValidity = validity -10;
        DateTime now = new DateTime.now();
        qrCodeEndOfValidity = now.add(new Duration(seconds: qrCodeValidity));
        _timer = new Timer.periodic(new Duration(seconds: 1), ((timer) {
          var delta = qrCodeEndOfValidity.difference(new DateTime.now()).inSeconds;
          sliderValue = math.max(0,delta/qrCodeValidity*100);
          if (sliderValue == 0){
            //reload qrCode
            loadQrCode();
          }
        }));
      }
    } catch (e) {
      errorOccured = true;
    }
    isloading = false;
  }

  ArtifactDownloadQRCode(this.modal,this.mdtService){
  }

  void generateQRCode(String Url) {
    CanvasElement canvas = querySelector("#content");

    SimpleQrCode simpleQrCode = new SimpleQrCode(canvas,10,QrErrorCorrectLevel.L);
    simpleQrCode.addData = Url;

  }

  static ModalInstance createQRCode(Modal modal,Scope scope, String title, String artifactid){
    return modal.open(new ModalOptions(template:'<qr_code title="$title" artifactId="$artifactid"></qr_code>', backdrop: 'true'), scope);

  }
}

class SimpleQrCode {
  CanvasRenderingContext2D _ctx;
  QrCode _qrCode;
  int _minDimension;

  bool _frameRequested = false;

  SimpleQrCode(CanvasElement canvas, int typeNumber, int errorCorrectLevel) {
    _ctx = canvas.context2D;
    _ctx.fillStyle = 'black';
    _minDimension = math.min(canvas.width, canvas.height);
    _qrCode = new QrCode(typeNumber, errorCorrectLevel);
  }

  void set addData(String input) {
    _qrCode.addData(input);
    _qrCode.make();
    requestFrame();
  }

  void requestFrame() {
    if (!_frameRequested) {
      _frameRequested = true;
      window.requestAnimationFrame(_onFrame);
    }
  }

  void _onFrame(double highResTime) {
    int scale = _minDimension ~/ _qrCode.moduleCount;

    for (int x = 0; x < _qrCode.moduleCount; x++) {
      for (int y = 0; y < _qrCode.moduleCount; y++) {
        if (_qrCode.isDark(y, x)) {
          _ctx.fillRect(x * scale, y * scale, scale, scale);
        } else {
          _ctx.clearRect(x * scale, y * scale, scale, scale);
        }
      }
    }

    _ctx.restore();
    _frameRequested = false;
  }
}