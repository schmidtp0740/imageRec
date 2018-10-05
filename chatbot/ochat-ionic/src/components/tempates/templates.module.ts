import { NgModule } from '@angular/core';
import { PayloadButtonModule } from '../payload-button/payload-button.module';
import { IonicModule } from 'ionic-angular';
import { LinkyModule } from 'angular2-linky';

import { ButtonTemplate } from './button-template/button-template';
import { MessageTemplate } from './message-template/message-template';
import { GenericTemplate } from './generic-template/generic-template';

import { MessageComponent } from './message-template/message/message';
import { ButtonItem } from './button-template/button-item/button-item';
import { Wrapper } from './wrapper/wrapper';


@NgModule({
  imports: [
    PayloadButtonModule,
    IonicModule,
    LinkyModule
  ],
  declarations: [
    ButtonTemplate,
    MessageTemplate,
    GenericTemplate,
    ButtonItem,
    MessageComponent,
    Wrapper
  ],
  exports: [
    ButtonTemplate,
    MessageTemplate,
    GenericTemplate,
    ButtonItem,
    MessageComponent
  ]
})

export class TemplatesModule { }
