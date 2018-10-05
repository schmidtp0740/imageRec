/******************************************************************************
 Copyright (c) 2016-2017, Oracle and/or its affiliates. All rights reserved.

 $revision_history$
 12-oct-2017   Steven Davelaar, Oracle A-Team
 1.2           Upgraded to IB 1.1 Conversation Model
 15-aug-2017   Steven Davelaar, Oracle A-Team
 1.2           Cleaned up the code
 12-jan-2017   Steven Davelaar, Oracle A-Team
 1.1           Modified for use with Intelligent Bots
 27-oct-2016   Steven Davelaar & Lydumil Pelov, Oracle A-Team
 1.0           initial creation
 ******************************************************************************/
define(['ojs/ojcore', 'knockout', 'jquery', './reconnecting-websocket', 'ojs/ojinputtext', 'ojs/ojknockout'
        , 'promise', 'ojs/ojlistview', 'ojs/ojarraytabledatasource'
        , 'ojs/ojfilmstrip', 'ojs/ojdialog'],
    function (oj, ko, $, ReconnectingWebSocket) {
        function model(context) {
            var self = this;
            var messageToBot;
            var currentConnection;

            self.waitingForText = ko.observable(false);

            var LOCATION_TYPE = 'location';
            var POSTBACK_TYPE = 'postback';
            var ws;
            context.props.then(function (properties) {
                self.properties = properties;
                initMessageToBot(self.properties.channel);
                ReconnectingWebSocket.debugAll = false;
                initWebSocketIfNeeded();
            });

            // close websocket connection when we leave page with tester CCA
            self.dispose = function (context) {
                if (ws) {
                    ws.close();
                }
            }

            var initWebSocketIfNeeded = function () {
                var connection = self.properties.websocketConnectionUrl + "?user=" + self.properties.userId;
                if (connection !== currentConnection) {
                    currentConnection = connection;
                    ws = new ReconnectingWebSocket(connection);
                    ws.onmessage = function (evt) {
                        self.waitingForText(false);
                        debug("Message received: " + evt.data);
                        var response = JSON.parse(evt.data);
                        if (response.hasOwnProperty('body') && response.body.hasOwnProperty('messagePayload')) {
                            // process IB V1.1 message
                            // we no longer support V1.0 messages, the webhook platform version
                            // should be set to 1.1
                            var messagePayload = response.body.messagePayload;
                            debug("Message payload: " + JSON.stringify(messagePayload));
                            self.addItem(messagePayload,true)
                        }
                        else if (response.hasOwnProperty('error')) {
                            self.addItem({"type":"text","text":response.error.message}, true);
                        }
                    };

                    ws.onclose = function () {
                        debug("Connection is closed...");
                    };

                    ws.onerror = function (error) {
                        self.waitingForText(false);
                        self.onerror(error);
                    };
                }

            }

            self.value = ko.observable("");
            self.itemToAdd = ko.observable("");
            self.scrollPos = ko.observable(5000);

            self.reset = function () {
                // re-init websocket when userId or connection url has changed
                initWebSocketIfNeeded();
                self.allItems([]);
                // re-init messageToBot to pick up changes to channel id
                initMessageToBot(self.properties.channel);
            }

            var initMessageToBot = function(channel) {
                messageToBot = {
                    "to": {
                        "type": "bot",
                        "id": channel
                    }
                };
            }

            self.getDisplayUrl = function (url) {
                var pos = url.indexOf("://");
                var startpos = pos === -1 ? 0 : pos + 3;
                var endpos = url.indexOf('/', startpos);
                endpos = endpos === -1 ? url.length : endpos;
                return url.substring(startpos, endpos);
            }

            // send message to the bot
            var sendToBot = function (message, isAcknowledge) {
                // wait for websocket until open
                waitForSocketConnection(ws, function () {
                    self.waitingForText(true);
                    ws.send(JSON.stringify(message));
                    debug('Message sent: ' + JSON.stringify(message));
                });
            }

            var waitForSocketConnection = function (socket, callback) {
                setTimeout(
                    function () {
                        if (socket.readyState === 1) {
                            callback();
                            return;

                        } else {
                            debug("waiting for connection...")
                            waitForSocketConnection(socket, callback);
                        }

                    }, 1000); // wait 1 second for the connection...
            }
            var debug = function (msg) {
                console.log(msg);
            };

            self.onerror = function (error) {
                console.error('WebSocket Error;', error);
            };

            function scrollBottom(el) {
                setTimeout(function () {
                    // scroll down to the bottom
                    $("body").animate({
                        scrollTop: !el ? $(window).height() : el.scrollHeight//el.offsetHeight
                    }, 1000);
                  /* increase / decrease animation speed */
                }, 100);
            }

            ko.extenders.scrollFollow = function (target, selector) {
                target.subscribe(function (newval) {
                    var el = document.querySelector(selector);

                    // check to see if you should scroll now?
                    //if (el.scrollTop == el.scrollHeight - el.clientHeight) {
                    scrollBottom(el);
                    //}
                });

                return target;
            };

            self.allItems = ko.observableArray([]).extend({scrollFollow: '#listview'});
            var lastItemId = self.allItems().length;
            if (lastItemId > 1)
                scrollBottom();

            //self.dataSource = new oj.ArrayTableDataSource(self.allItems, {idAttribute: "id"})

            self.addItem = function (value, isBot) {
                // TODO: don't add if value is empty!
                lastItemId++;
                self.allItems.push(
                    {
                        id: lastItemId,
                        payload: value,
                        bot: isBot
                    }
                );
            };

            // this will be when typing!
            self.valueChangeHandler = function (context, ui) {
                //var eventTime = getCuttentTime();
                if (ui.option === "value") {
                    var valueObj = {
                        previousValue: ui.previousValue,
                        value: ui.value
                    };

                    // do only if enter!
                    if (context.keyCode === 13) {
                        // Free text is entered
                        messageToBot.messagePayload= {type:"text",text:valueObj.value};
                        self.addItem(valueObj.value, false);
                        self.value("");
                        sendToBot(messageToBot);
                    }
                }
            };

            self.notSupportedMessage = ko.observable();

            // predefined selection!
            self.onClientSelection = function (action) {
                self.addItem(action.label, false);
                if (action.type === POSTBACK_TYPE) {
                    messageToBot.messagePayload = {"type":"postback","postback":action.postback};
                    sendToBot(messageToBot);
                } else if (action.type === LOCATION_TYPE) {
                    if (navigator.geolocation) {
                        navigator.geolocation.getCurrentPosition(function (position) {
                            messageToBot.messagePayload = {"type": 'location', location: {"latitude": position.coords.latitude, "longitude": position.coords.longitude}};
                            sendToBot(messageToBot);
                        });
                    } else {
                        self.notSupportedMessage('Geo location is not supported by this browser');
                        $("#notSupportedDialog").ojDialog("open");
                    }
                } else {
                    self.notSupportedMessage('Action type ' + action.type + ' is not supported in tester');
                    $("#notSupportedDialog").ojDialog("open");
                }
            };

            self.closeNotSupportedDialog = function () {
                $("#notSupportedDialog").ojDialog("close");
            }

            // film trip properties!
            // self.currentNavArrowPlacement = ko.observable("adjacent");
            // self.currentNavArrowVisibility = ko.observable("auto");
            self.currentNavArrowPlacement = ko.observable("overlay");
            self.currentNavArrowVisibility = ko.observable("hidden");

        }
        return model;
    }
)