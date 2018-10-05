import { Component } from '@angular/core';

import { NavController, LoadingController, ModalController } from 'ionic-angular';
import { DataService } from '../../providers/data-service';

import {Chat} from '../chat/chat'
import { Login } from '../login/login';


@Component({
  selector: 'page-channels',
  templateUrl: 'channels.html'
})
export class Channels {
  bots: Array<{id: string, name: string, description: string}>;

  constructor(public navCtrl: NavController,
              public loadingCtrl: LoadingController,
              public dataService: DataService,
              public modalCtrl: ModalController) {

    var loading;
    if (dataService.getCurrentUser()) {
      loading = this.loading('Loading bots ...');
      loading.present();
    } else {
      let modal = this.modalCtrl.create(Login);
      modal.present();
    }

    var _this = this;
    dataService.loadChannels()
      .then((bots) => {
        _this.bots = JSON.parse(JSON.stringify(bots));
        if (loading) {
          loading.dismiss();
        }
      });
  }

  itemTapped(event, channel) {
    // That's right, we're pushing to ourselves!
    this.navCtrl.push(Chat, {
      channel: channel
    });
  }

  loading(message){
    return this.loadingCtrl.create({
      content: message
    });
  }
}
