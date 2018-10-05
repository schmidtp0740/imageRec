import { Component,Input } from '@angular/core';

@Component({
  selector: 'wrapper',
  templateUrl: 'wrapper.html'
})

export class Wrapper {
  @Input() left: boolean;
  @Input() right: boolean;
  @Input() className: string;

  icon: string;

  constructor() {
  }

  ngOnChanges(changes: any) {
    if(changes.left || changes.right){
      this.icon = this.left ? 'ionitron' : 'contact';
    }
  }
}
