import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';

@Component(
    selector: 'confirmation',
    useShadowDom: false,
    template:r'''
    <div class="modal-header">
  <h3 class="modal-title">{{title}}</h3>
</div>
<div class="modal-body">
  <p>{{text}}</p>
</div>
<div class="modal-footer">
  <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
  <button type="button" class="btn btn-primary" ng-click="confirm()">Confirm</button>
</div>
    '''
)
class ConfirmationComponent  {
  @NgAttr('title')
  String title;
  @NgAttr('text')
  String text;
  Modal modal;

  ConfirmationComponent(this.modal){

  }
  void confirm(){
    modal.close(true);
   // close(true);
  }

  static ModalInstance createConfirmation(Modal modal,Scope scope, String title, String text){
    return modal.open(new ModalOptions(template:'<confirmation title="$title" text="$text"></confirmation>', backdrop: 'false'), scope);

  }
}