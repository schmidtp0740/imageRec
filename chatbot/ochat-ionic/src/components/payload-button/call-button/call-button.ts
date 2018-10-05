import { Component,Input  } from '@angular/core';
import { CallButtonModel } from '../../../model/call-button.model';

@Component({
  selector: 'call-button',
  templateUrl: 'call-button.html'
})

export class CallButton {
  @Input('model') model: CallButtonModel;
}
