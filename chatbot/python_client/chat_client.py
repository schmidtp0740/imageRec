import websocket
import thread
import time

def on_message(ws, message):
    print message

def on_error(ws, error):
    print error

def on_close(ws):
    print "### closed ###"

def on_open(ws):
    def run(*args):
        for i in range(30000):
            time.sleep(1)
            ws.send("Hello %d" % i)
        time.sleep(1)
        ws.close()
        print "thread terminating..."
    thread.start_new_thread(run, ())


if __name__ == "__main__":
    userId = 'jhancock'
    channel = 'A1F8E79E-96FB-44D0-8019-60649C161273'
    websocket.enableTrace(True)
    ws = websocket.WebSocketApp("ws://8486cc94.ngrok.io/chat/ws",
                                on_message = on_message,
                                on_error = on_error,
                                on_close = on_close)
    ws.on_open = send_msg()

    ws.run_forever()