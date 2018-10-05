import { Component } from '@angular/core';

import { ViewController } from 'ionic-angular';
import { DataService } from '../../providers/data-service';

@Component({
  selector: 'page-login',
  templateUrl: 'login.html'
})

export class Login {
  username: string;
  password: string;

  constructor(public viewCtrl: ViewController, public dataService: DataService) {
  }

  login() {
    this.dataService.login(this.username, this.password).then(() => {
      this.viewCtrl.dismiss();
    });
  }
}
