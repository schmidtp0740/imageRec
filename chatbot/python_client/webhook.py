from flask import Flask, request, jsonify, abort
import requests, json, hashlib, hmac

app = Flask(__name__)
#app.debug = True

APPLICATION_JSON_UTF8 = 'application/json; charset=utf-8'
SECRET_KEY = bytes('2mdkVeybquXB71Zgr3bqAzhVh61Lq6Yn', 'utf8')
USER_ID = 'jhancock'
BOT_URL = 'https://e8af89b5.ngrok.io/connectors/v1/tenants/chatbot-tenant/listeners/webhook/channels/5E11F1BA-6C84-49AA-B717-895DF595DB0F'

@app.route('/hello', methods=['GET'])
def hello():
    return 'Hello World!'

@app.route('/receive', methods=['POST'])
def receive():
    data = request.data.decode('utf8')
    print(data)
    msg = json.loads(msg)
    return data

@app.route('/send', methods=['POST'])
def send(msg):
    print(msg)
    code = hmac.new(SECRET_KEY, digestmod=hashlib.sha256)
    code.update(msg)
    signature = 'sha256=' + code.hexdigest()
    headers = {
        'Content-Type': APPLICATION_JSON_UTF8,
        'X-Hub-Signature': signature
    }
    r = requests.post(BOT_URL, data=msg, headers=headers)
    return r.text

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8888, ssl_context='adhoc')