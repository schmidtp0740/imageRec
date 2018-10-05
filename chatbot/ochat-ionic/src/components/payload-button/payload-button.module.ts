/**
 * Created by YPANSHIN on 2017-01-31.
 */
import { NgModule } from '@angular/core';
import { IonicModule } from 'ionic-angular';

import { CallButton } from './call-button/call-button';
import { PostBackButton } from './post-back-button/post-back-button';
import { UrlButton } from './url-button/url-button';


@NgModule({
  imports: [
    IonicModule
  ],
  declarations: [
    CallButton,
    PostBackButton,
    UrlButton
  ],
  exports: [
    CallButton,
    PostBackButton,
    UrlButton
  ]
})

export class PayloadButtonModule { }
