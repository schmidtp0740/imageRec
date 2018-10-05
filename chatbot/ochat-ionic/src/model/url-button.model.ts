
import { PayloadButtonModel } from './payload-button.model';

export class UrlButtonModel extends PayloadButtonModel{
  static TYPE: string = 'web_url';
  url: string;

  constructor(url: string, title: string){
    super(UrlButtonModel.TYPE, title);
    this.url = url;
  }
}
