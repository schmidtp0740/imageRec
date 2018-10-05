/**
 * Created by YPANSHIN on 2017-03-03.
 */

import { Component,Input, Output, EventEmitter  } from '@angular/core';
import { PayloadButtonModel, CallButtonModel, PostBackButtonModel, UrlButtonModel } from '../../../../model';

@Component({
  selector: 'button-item',
  templateUrl: 'button-item.html'
})

export class ButtonItem {
  @Input('model') model: PayloadButtonModel;
  @Output() onClick:EventEmitter<any> = new EventEmitter();

  callButtonModelType: any = CallButtonModel.TYPE;
  postBackButtonModelType: any = PostBackButtonModel.TYPE;
  urlButtonModelType: any = UrlButtonModel.TYPE;

  constructor() {
  }


}
