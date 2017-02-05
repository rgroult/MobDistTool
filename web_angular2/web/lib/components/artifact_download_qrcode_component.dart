import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'dart:async';
import 'dart:html';
import 'dart:math' as math;
import 'package:qr/qr.dart';
import '../commons.dart';
import '../model/mdt_model.dart';

@Component(
    selector: 'qr_code_component',
    directives: const [ErrorComponent,materialDirectives],
    providers: materialProviders,
    templateUrl: 'artifact_download_qrcode_component.html')
class ArtifactDownloadQRCodeComponent extends BaseComponent implements OnInit  {
  @Input()
  void set parameters(Map<String,dynamic> params) {
    _timer?.cancel();
    if (params == null){
      return;
    }
    artifact = params["artifact"];
    title = params["title"];
    loadQrCode();
  }

  MDTArtifact artifact;
  String title;

  //String artifactId;
  Modal modal;
  bool isloading = true;
  bool errorOccured = false;
  MDTQueryService _mdtQueryService;
  @Output()
  int sliderValue = 100;
  var qrCodeValidity = 0;
  var qrCodeEndOfValidity = null;
  Timer _timer = null;

  Future ngOnInit() async {
  }

  Future loadQrCode() async {
    try {
      if (_timer != null) {
        _timer.cancel();
      }
      var downloadInfos = await _mdtQueryService.artifactDownloadInfo(artifact.uuid);
      generateQRCode(downloadInfos["installUrl"]);
      var validity = downloadInfos["validity"];
      if (validity != null) {
        sliderValue = 100;
        qrCodeValidity = validity -10;
        DateTime now = new DateTime.now();
        qrCodeEndOfValidity = now.add(new Duration(seconds: qrCodeValidity));
        _timer = new Timer.periodic(new Duration(seconds: 1), ((timer) {
          var delta = qrCodeEndOfValidity.difference(new DateTime.now()).inSeconds;
          sliderValue = math.max(0,delta/qrCodeValidity*100).toInt();
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

  ArtifactDownloadQRCodeComponent(this._mdtQueryService){
  }

  void generateQRCode(String Url) {
    CanvasElement canvas = querySelector("#content");

    SimpleQrCode simpleQrCode = new SimpleQrCode(canvas,10,QrErrorCorrectLevel.L);
    simpleQrCode.addData = Url;

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