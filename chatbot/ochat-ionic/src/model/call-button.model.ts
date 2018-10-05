
import { PostBackButtonModel } from './post-back-button.model';


export class CallButtonModel extends PostBackButtonModel{
  static TYPE: string = 'phone_number';

  constructor(phoneNumber: string, title: string){
    super(phoneNumber, title, CallButtonModel.TYPE)
  }
}
