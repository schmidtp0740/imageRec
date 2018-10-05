/**
 * Created by YPANSHIN on 2017-03-03.
 */

import { PayloadButtonModel } from './payload-button.model'
import { TemplateModel } from './template.model'
import { RecipientModel } from './recipient.model'


export class ButtonTemplateModel extends TemplateModel{
  static TYPE: string = 'button';

  text: string;
  buttons: Array<PayloadButtonModel>;

  constructor(recipient: RecipientModel, text: string, buttons: Array<PayloadButtonModel>){
    super(recipient, ButtonTemplateModel.TYPE);
    this.buttons = buttons;
    this.text = text;
  }
}
