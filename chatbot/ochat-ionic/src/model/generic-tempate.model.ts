/**
 * Created by YPANSHIN on 2017-03-03.
 */

import { PayloadButtonModel } from './payload-button.model'
import { TemplateModel } from './template.model'
import { RecipientModel } from './recipient.model'


export class GenericTemplateModel extends TemplateModel{
  static TYPE: string = 'generic';

  imageAspectRatio: string; // horizontal or square
  elements: Array<PayloadButtonModel>;

  constructor(recipient: RecipientModel, elements: Array<PayloadButtonModel>, imageAspectRatio: string){
    super(recipient, GenericTemplateModel.TYPE);
    this.elements = elements;
  }
}
