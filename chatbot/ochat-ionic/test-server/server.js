/**
 * Copyright© 2015, Oracle and/or its affiliates. All rights reserved.
 */

var express = require('express');
var bodyParser = require('body-parser');
var cors = require('cors');

var router = express();
var expressWs = require('express-ws')(router);

// Allow CORs
router.use(cors({ origin: true, credentials: true }));

// JSON parser
router.use(bodyParser.json({limit: '10mb'}));
router.use(bodyParser.urlencoded({extended: false}));


router.get('/apps/chat/botChannels', function (req, res, next){
  pipe(res, 200, [{
    id: '1',
    name: 'Test Channel',
    description: 'Test channel'
  }]);
});

router.ws('/apps/chat/ws', function(ws, req) {
  ws.on('message', function(msg) {
    msg = JSON.parse(msg);
    console.log('received', msg);
    var resp;
    switch(msg.message.text) {
      case 'button':
        resp = {
          "id": '1',
          "recipient":{
            "id":"1"
          },
          "message":{
            "attachment":{
              "type":"template",
              "payload":{
                "template_type":"button",
                "text":"What do you want to do next?",
                "buttons":[
                  {
                    "type":"phone_number",
                    "url":"+1234567890",
                    "title":"Call Mobile"
                  },
                  {
                    "type":"postback",
                    "title":"Start Chatting",
                    "payload":"USER_DEFINED_PAYLOAD"
                  },
                  {
                    "type":"web_url",
                    "title":"Show Google",
                    "url":"http://google.com"
                  }
                ]
              }
            }
          }
        };
        break;
      case 'generic':
        resp = {
          "id": '1',
          "recipient":{
            "id":"1"
          },
          "message":{
            "attachment":{
              "type":"template",
              "payload":{
                "template_type":"generic",
                "elements":[
                  {
                    "title":"Welcome to Peter\'s Hats",
                    "image_url":"https://ionicframework.com/dist/preview-app/www/assets/img/nin-live.png",
                    "subtitle":"We\'ve got the right hat for everyone.",
                    "default_action": {
                      "type": "web_url",
                      "url": "https://peterssendreceiveapp.ngrok.io/view?item=103",
                      "messenger_extensions": true,
                      "webview_height_ratio": "tall",
                      "fallback_url": "https://peterssendreceiveapp.ngrok.io/"
                    },
                    "buttons":[
                      {
                        "type":"web_url",
                        "url":"https://petersfancybrownhats.com",
                        "title":"View Website"
                      },{
                        "type":"postback",
                        "title":"Start Chatting",
                        "payload":"DEVELOPER_DEFINED_PAYLOAD"
                      }
                    ]
                  },{
                    "title":"Welcome to Peter\'s Hats",
                    "image_url":"https://ionicframework.com/dist/preview-app/www/assets/img/nin-live.png",
                    "subtitle":"We\'ve got the right hat for everyone.",
                    "default_action": {
                      "type": "web_url",
                      "url": "https://peterssendreceiveapp.ngrok.io/view?item=103",
                      "messenger_extensions": true,
                      "webview_height_ratio": "tall",
                      "fallback_url": "https://peterssendreceiveapp.ngrok.io/"
                    },
                    "buttons":[
                      {
                        "type":"web_url",
                        "url":"https://petersfancybrownhats.com",
                        "title":"View Website"
                      },{
                        "type":"postback",
                        "title":"Start Chatting",
                        "payload":"DEVELOPER_DEFINED_PAYLOAD"
                      }
                    ]
                  }
                ]
              }
            }
          }
        };
        break;
      default:
        resp = {
          "id": '1',
          "recipient":{
            "id":"1"
          },
          "message":{
            "text": msg.message.text
          }
        };
        break;
    }
    console.log('sent', resp);
    ws.send(JSON.stringify(resp));
  });
});


// now use into this server!
//router.get(service);

// run the server
var appserver = router.listen(3010, function() {
  var host = appserver.address().address;
  var port = appserver.address().port;

  console.log('Test server listening at http://%s:%s', host, port);
});


function pipe(res, code, data) {
  res.status(code || 500).json(data || {});
}
