# Ionic Hybrid BOTS Chat Client
This is a client application for the BOTS Chat Server.

## Requirements ##

- NodeJS ([https://nodejs.org/en/](https://nodejs.org/en/))
- Ionic ([http://ionicframework.com/](http://ionicframework.com/))

## Building the Ionic App ##


Install the package using the `npm install` command and then spin up the server using the `ionic serve` command. To run this app in a browser, use the following commands to generate the web app itself in the `dest` folder:


    npm install -g cordova ionic
    npm install
    ionic cordova platform add browser
    ionic cordova build browser
    node_modules/grunt/bin/grunt build


## Setting Up the Bots Chat Server
Refer to the Bot Chat Server  [README file](/source/apps/chat/README.md).

## Using the Templates##

The client app has templates that show you the expected formats for the responses returned by custom code. These templates demonstrate how the app displays lists of buttons or slide shows.

- `@message`
- `@buttons-list`
- `@generic`


### Response Formats ###



#### buttons-list ####

    {
      attachment:{
    type: 'template',
    payload: {
      text: 'Please select from the following options:',
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

#### generic ####

    {
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
