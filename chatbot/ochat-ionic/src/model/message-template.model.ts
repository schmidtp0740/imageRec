import {MessageModel} from "./message.model";
import {RecipientModel} from "./recipient.model";

export class MessageTemplateModel extends MessageModel{
  text: string;

  constructor(recipient: RecipientModel, text: string){
    super(recipient);
    this.text = text;
  }
}
