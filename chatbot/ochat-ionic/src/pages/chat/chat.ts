import { Component } from '@angular/core';

import { NavParams, LoadingController } from 'ionic-angular';
import { DataService } from '../../providers/data-service';
import * as m from "../../model";

@Component({
  selector: 'page-chat',
  templateUrl: 'chat.html'
})

export class Chat {
  modelTypes: any;

  selectedChannel: any;
  items: Array<m.MessageModel>;
  message: string = '';

  constructor(public navParams: NavParams,
              public loadingCtrl: LoadingController,
              public dataService: DataService) {

    this.modelTypes = m;

    // If we navigated to this page, we will have an item available as a nav param
    this.selectedChannel = navParams.get('channel');

    this.items = [];

    var loading = this.loadingCtrl.create({
      content: 'Please wait ...'
    });
    loading.present();

    var _this = this;
    dataService.loadChat(this.selectedChannel.id).then((messages) => {
      _this.items = messages.slice();
      setTimeout(() => {
        _this.scrollToBottom();
        loading.dismiss();
        dataService.subscribe(_this.selectedChannel.id, _this.onMessageReceived.bind(_this));
      }, 0);
    });
  }

  ionViewDidEnter(){
    this.scrollToBottom();
  }

  onMessageReceived(message){
    console.log('onMessageReceived:', message);
    this.items.push(message);
    this.scrollToBottom();
  }

  sendMessage(){
    var message = this.dataService.send(this.selectedChannel.id, this.message);
    this.scrollToBottom();
    this.items.push(message);
    this.message = '';
  }

  onButtonTemplateClick(payload){
    var message = this.dataService.send(this.selectedChannel.id, typeof payload === 'string' ? payload : JSON.stringify(payload));
    this.scrollToBottom();
    this.items.push(message);
  }


  onProfilePicError(img) {

  }

  isTypeOf(model: any, type: any){
    return model instanceof type;
  }

  scrollToBottom(){
    var element = document.getElementById("lastItem");
    setTimeout(()=>{element.scrollIntoView(true)},0);
  }
}
