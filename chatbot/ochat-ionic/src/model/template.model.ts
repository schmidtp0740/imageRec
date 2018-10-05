import {MessageModel} from './message.model';
import {RecipientModel} from './recipient.model';

export class TemplateModel extends MessageModel{
  template_type: string;

  constructor(recipient: RecipientModel, type: string){
    super(recipient);
    this.template_type = type;
  }

}
