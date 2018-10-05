

import {UrlButtonModel} from "./url-button.model";
import {PayloadButtonModel} from "./payload-button.model";

export class ElementModel{
  title: string;
  imageUrl: string;
  subtitle: string;
  defaultAction: UrlButtonModel;
  buttons: Array<PayloadButtonModel>;

  constructor(title: string, imageUrl: string, subtitle: string, defaultAction: UrlButtonModel, buttons: Array<PayloadButtonModel>){
    this.title = title;
    this.imageUrl = imageUrl;
    this.subtitle = subtitle;
    this.defaultAction = defaultAction;
    this.buttons = buttons;
  }
}
