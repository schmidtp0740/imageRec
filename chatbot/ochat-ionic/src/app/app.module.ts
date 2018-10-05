import { NgModule, ErrorHandler } from '@angular/core';
import { IonicApp, IonicModule, IonicErrorHandler } from 'ionic-angular';
import { MyApp } from './app.component';
import { Channels } from '../pages/channels/channels';
import { Settings } from '../pages/settings/settings';
import { Chat } from '../pages/chat/chat';
import { LinkyModule } from 'angular2-linky';
import { Login } from '../pages/login/login';
import { DataService } from '../providers/data-service';

import { TemplatesModule } from "../components/tempates/templates.module";

@NgModule({
  declarations: [
    MyApp,
    Channels,
    Settings,
    Chat,
    Login
  ],
  imports: [
    IonicModule.forRoot(MyApp),
    LinkyModule,
    TemplatesModule
  ],
  bootstrap: [IonicApp],
  entryComponents: [
    MyApp,
    Channels,
    Settings,
    Chat,
    Login
  ],
  providers: [{provide: ErrorHandler, useClass: IonicErrorHandler}, DataService]
})
export class AppModule {}
