import { Component,Input, Output, EventEmitter  } from '@angular/core';
import { UrlButtonModel } from '../../../model/url-button.model';

@Component({
  selector: 'url-button',
  templateUrl: 'url-button.html'
})

export class UrlButton {
  @Input('model') model: UrlButtonModel;
  @Output() onClick:EventEmitter<any> = new EventEmitter();
}
