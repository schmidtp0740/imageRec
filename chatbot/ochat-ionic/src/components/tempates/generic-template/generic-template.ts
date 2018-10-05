/**
 * Created by YPANSHIN on 2017-03-03.
 */

import { Component,Input, Output, EventEmitter  } from '@angular/core';
import {GenericTemplateModel} from "../../../model/generic-tempate.model";

@Component({
  selector: 'generic-template',
  templateUrl: 'generic-template.html'
})

export class GenericTemplate {
  @Input() model: GenericTemplateModel;
  @Output() onClick:EventEmitter<any> = new EventEmitter();

  options: any = {
    slidesPerView: 1,
    pager: true,
    spaceBetween: 100,
    onInit:()=>{
    }
  };

  constructor() {
  }

  onSlideClick(element){
    if(element.defaultAction){
      window.open(element.defaultAction.url, '_system');
    }
  }
}
