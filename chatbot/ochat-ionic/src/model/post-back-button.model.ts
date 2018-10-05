
import { PayloadButtonModel } from './payload-button.model';

export class PostBackButtonModel extends PayloadButtonModel{
  static TYPE: string = 'postback';

  payload: string;

  constructor(payload: string, title: string, type?: string){
    super(type || PostBackButtonModel.TYPE, title);

    this.payload = payload;
  }
}
