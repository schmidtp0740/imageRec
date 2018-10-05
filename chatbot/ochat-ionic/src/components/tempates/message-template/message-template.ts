import { Component,Input } from '@angular/core';
import { MessageTemplateModel } from '../../../model/message-template.model';

@Component({
  selector: 'message-template',
  templateUrl: 'message-template.html'
})

export class MessageTemplate {
  @Input('model') model: MessageTemplateModel;

  constructor() {
  }
}
