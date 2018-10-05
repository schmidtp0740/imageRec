/**
 * Created by YPANSHIN on 2017-03-03.
 */

import { Component,Input, Output, EventEmitter  } from '@angular/core';
import { ButtonTemplateModel } from '../../../model/button-tempate.model';

@Component({
  selector: 'button-template',
  templateUrl: 'button-template.html'
})

export class ButtonTemplate {
  @Input() model: ButtonTemplateModel;
  @Output() onClick:EventEmitter<any> = new EventEmitter();

  constructor() {
  }
}
