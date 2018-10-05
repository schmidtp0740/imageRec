
import {RecipientModel} from './recipient.model';

export class MessageModel{
  recipient: RecipientModel;

  constructor(recipient: RecipientModel){
    this.recipient = recipient;
  }
}
