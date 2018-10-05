import { Component,Input, Output, EventEmitter  } from '@angular/core';
import { PostBackButtonModel } from '../../../model/post-back-button.model';

@Component({
  selector: 'post-back-button',
  templateUrl: 'post-back-button.html'
})

export class PostBackButton {
  @Input() model: PostBackButtonModel;
  @Output() onClick:EventEmitter<any> = new EventEmitter();
}
