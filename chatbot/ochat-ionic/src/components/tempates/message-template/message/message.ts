import { Component, Input } from '@angular/core';

@Component({
  selector: 'message',
  templateUrl: 'message.html'
})
export class MessageComponent {
  @Input() text: string;
  @Input() isReceived: boolean;

  icon: string;

  constructor() {
  }

  ngOnChanges(changes: any) {
    if(changes.isReceived){
      this.icon = this.isReceived ? 'ionitron' : 'contact';
    }
  }
}
