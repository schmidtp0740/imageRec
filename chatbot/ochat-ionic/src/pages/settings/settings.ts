import { Component } from '@angular/core';

import { AlertController } from 'ionic-angular';
import { DataService } from '../../providers/data-service';

@Component({
  selector: 'page-settings',
  templateUrl: 'settings.html'
})
export class Settings {

  host: string;
  port: string;

  constructor(public alertCtrl: AlertController, public dataService: DataService) {
    this.host = this.dataService.host;
    this.port = this.dataService.port;
  }

  showPrompt() {
    let prompt = this.alertCtrl.create({
      title: 'Host',
      message: "Enter you host name and port number.",
      inputs: [
        {
          name: 'host',
          placeholder: 'Host',
          value: this.host
        },{
          name: 'port',
          placeholder: 'Port',
          value: this.port,
          type: 'number'
        },
      ],
      buttons: [
        {
          text: 'Cancel'
        },
        {
          text: 'Save',
          handler: data => {
            this.host = data.host;
            this.port = data.port;
            this.dataService.setHostPort(data.host, data.port);
          }
        }
      ]
    });
    prompt.present();
  }
}
