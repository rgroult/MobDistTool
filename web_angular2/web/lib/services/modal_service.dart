import 'package:angular2/core.dart';
import 'dart:html';
import '../components/user_login_component.dart';

@Injectable()
class ModalService {
  Injector _injector;

  ModalService(this._injector);

  //retrieve modal contentNode
  HtmlElement get modalComponent => document.body.querySelector("ModalContent");

  void createModal(String htmlTemplate){
    // new ModalAlert('Error', htmlTemplate,html: true)..open();
   // var comp = _injector.get(UserLoginComponent);
    //document.body.children.add(comp);
   //   ..open();
   // _compiler(rootElements, _directiveMap)(scope, _injector, rootElements);
    return;

      closeCurrentModal();
      var content = modalComponent;
      if (content == null) {
        content = document.createElement("ModalContent");
        document.body.children.add(content);
      }

      var template =  '''
<div tabindex="-1" class="modal modal fade"
    style="{'z-index': '1050', 'display': 'block'}">
    <div class="modal-dialog">
      <div class="modal-content">
       ${htmlTemplate}
      </div>
    </div>
</div>''';

      //List<dom.Element> rootElements = toNodeList(html);

    content.setInnerHtml(template);
  }



  void closeCurrentModal(){
      var content = modalComponent;
      if (content != null) {
          content.innerHtml = "";
      }
  }
}