import { Injectable, NgZone } from '@angular/core';
import { Http } from '@angular/http';
import 'rxjs/add/operator/map';

import {MessageModel} from "../model/message.model";
import {RecipientModel} from "../model/recipient.model";
import {MessageTemplateModel} from "../model/message-template.model";
import {ElementModel} from "../model/element.model";
import {GenericTemplateModel} from "../model/generic-tempate.model";
import {PayloadButtonModel} from "../model/payload-button.model";
import {CallButtonModel} from "../model/call-button.model";
import {PostBackButtonModel} from "../model/post-back-button.model";
import {UrlButtonModel} from "../model/url-button.model";
import {ButtonTemplateModel} from "../model/button-tempate.model";


@Injectable()
export class DataService {

  host: string;
  port: string;

  static get channelsEndPoint(){
    return '/apps/chat/botChannels';
  }

  subscribers: any;
  messages: any = {};
  ws: any;
  user: any;
  users: any[] = [];

  constructor(public http: Http, private zone: NgZone) {
    this.subscribers = {};

    this.users = [];
    for(var i = 1; i <= 10; i++){
      this.users.push({
        name:'User ' + i,
        id: i
      });
    }

    this.host = 'localhost';
    this.port = '8888';
  }

  setHostPort(host, port){
    this.host = host;
    this.port = port;
    if(this.ws){
      this.ws.close();
      this.openSocket();
    }
  }

  openSocket(){
    this.ws = new WebSocket('ws://' + this.host + ':' + this.port + '/chat/ws?user=' + this.user.id);
    this.ws.addEventListener('open', event => {
      this.zone.run(() => {
        console.log('ws.Open');
      });
    });
    this.ws.addEventListener('message', event => {
      this.zone.run(() => {
        console.log('msg: ', event.data);
        var msg = JSON.parse(event.data);
        this.broadcast(msg);
      });
    });
    this.ws.addEventListener('close', event => {
      this.zone.run(() => {
        console.log('ws.Close');
      });
    });
    this.ws.addEventListener('error', event => {
      console.error("The socket had an error", event);
    });
  }

  getCurrentUser(){
    return this.user;
  }

  login(username, password){
    console.log('username', username);
    for(var user in this.users){
      if(this.users.hasOwnProperty(user) && this.users[user].name === username){
        this.user = this.users[user];
      }
    }
    this.openSocket();
    return this.user ? Promise.resolve() : Promise.reject('User not found');
  }

  loadChannels() {
    return new Promise(resolve => {
      this.http.get('http://' + this.host + ':' + this.port + DataService.channelsEndPoint)
        .map(res => res.json())
        .subscribe(data => {
          resolve(data);
        });
    });
  }

  subscribe(channelId, fn){
    console.log('subscribe to channel:', channelId);
    this.subscribers[channelId] = fn;
  }

  unSubscribe(channelId){
    console.log('unsubscribe to channel:', channelId);
    delete this.subscribers[channelId];
  }

  loadChat(channelId){
    if(!this.messages[channelId]){
      this.messages[channelId] = [];
    }
    return Promise.resolve(this.messages[channelId]);
  }

  broadcast(msg){
    console.log('broadcast to channel:', msg);
    if(msg.from && msg.from.id) {
      let message = this.parseModel(msg);
      this.messages[msg.from.id].push(message);
      this.subscribers[msg.from.id](message);
    }else{
      let txt = msg.error && msg.error.message ? msg.error.message : 'ERROR:' + JSON.stringify(msg);
      let message = new MessageTemplateModel(new RecipientModel('1'), txt);
      console.error(msg);
      for(let key of Object.keys(this.subscribers)) {
        this.messages[key].push(message);
        this.subscribers[key](message);
      }
    }
  }

  send(channel: string, text: string): MessageTemplateModel {
    let message = {
      to:{
        type: 'bot',
        id: channel
      },
      text: text
    };
    console.log('send to channel:', channel, message);


    let obj = new MessageTemplateModel(null, text);
    this.messages[channel].push(obj);

    let predefinedMessage = this.processPredefinedMessages(channel, text);
    if(predefinedMessage){
      setTimeout(() => {
        this.messages[channel].push(predefinedMessage);
        this.subscribers[channel](predefinedMessage);
      }, 100);
    } else {
      this.ws.send(JSON.stringify(message));
    }
    return obj;
  }

  processPredefinedMessages(channel: string, text: string): MessageModel{
    if(text === '@message'){
      return this.parseModel({
        from:{
          id: channel
        },
        body:{
          text: 'Hello, world!'
        }
      });
    } else if(text === '@buttons-list'){
      return this.parseModel({
        from:{
          id: channel
        },
        body:{
          attachment:{
            type: 'template',
            payload: {
              text: 'Please select from follow options:',
              template_type: 'button',
              buttons: [{
                type: 'phone_number',
                title: 'Call Oracle',
                payload: '+18003922999'
              },{
                type: 'postback',
                title: 'Hello Oracle',
                payload: 'Hello Oracle'
              },{
                type: 'web_url',
                title: 'Open Oracle Page',
                url: 'http://oracle.com'
              }]
            }
          }
        }
      });
    } else if(text === '@generic'){
      return this.parseModel({
        from:{
          id: channel
        },
        body:{
          attachment:{
            type: 'template',
            payload: {
              template_type: 'generic',
              elements:[{
                title: 'What is a Chatbot?',
                subtitle: 'Learn how chatbots will change the way you build apps.',
                image_url: 'https://www.oracle.com/assets/c78-what-is-chatbot-3678507.jpg',
                buttons: [{
                  type: 'web_url',
                  title: 'Watch the video (2:19)',
                  url: 'https://www.oracle.com/solutions/mobile/bots.html?bcid=5403853473001'
                }]
              },{
                title: 'Larry Ellison Introduces Chatbots at OpenWorld',
                subtitle: 'Watch Larry Ellison introduce one of the most innovative technologies that will transform your business.',
                image_url: 'https://www.oracle.com/assets/c78-larry-chatbots-3678505.jpg',
                buttons: [{
                  type: 'web_url',
                  title: 'Watch the video (8:17)',
                  url: 'https://www.oracle.com/solutions/mobile/bots.html?bcid=5403747060001'
                }]
              },{
                title: 'Chatbots 101',
                subtitle: 'Check out these insightful stats on how bots will change the landscape and interface of future applications.',
                image_url: 'https://www.oracle.com/assets/c78-chatbots-101-3678508.jpg',
                buttons: [{
                  type: 'web_url',
                  title: 'View the infographic (PDF)',
                  url: 'http://www.oracle.com/us/technologies/mobile/chatbot-infographic-3672253.pdf'
                }]
              }]
            }
          }
        }
      });
    }
    return null;
  }

  parseModel(json: any): MessageModel{
    var recipient;
    if(json.from){
      recipient = new RecipientModel(json.from.id);
    }
    if(json.body.text){
      return new MessageTemplateModel(recipient, json.body.text)
    } else if(json.body.attachment.type === 'template'){
      return this.parseTemplatePayload(recipient, json.body.attachment.payload);
    }
  }

  parseTemplatePayload(recipient: RecipientModel, payload: any): MessageModel{
    if(payload.template_type === 'button'){
      var buttons = payload.buttons.map(b => {
        switch(b.type){
          case CallButtonModel.TYPE:
            return <PayloadButtonModel>new CallButtonModel(b.payload, b.title);
          case PostBackButtonModel.TYPE:
            return <PayloadButtonModel>new PostBackButtonModel(b.payload, b.title);
          case UrlButtonModel.TYPE:
            return <PayloadButtonModel>new UrlButtonModel(b.url, b.title);
        }
      });
      return new ButtonTemplateModel(recipient, payload.text, buttons)
    } else if(payload.template_type === 'generic'){
      var elements = payload.elements.map(elem => {
        var buttons = elem.buttons.map(b => {
          console.log(b);
          switch(b.type){
            case CallButtonModel.TYPE:
              return <PayloadButtonModel>new CallButtonModel(b.payload, b.title);
            case PostBackButtonModel.TYPE:
              return <PayloadButtonModel>new PostBackButtonModel(b.payload, b.title);
            case UrlButtonModel.TYPE:
              return <PayloadButtonModel>new UrlButtonModel(b.url, b.title);
          }
        });
        return new ElementModel(elem.title, elem.image_url, elem.subtitle, null, buttons)
      });
      return new GenericTemplateModel(recipient, elements, null)
    }
  }
}
