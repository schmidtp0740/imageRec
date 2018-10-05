import os, io, sys, base64
import urllib, tarfile, zipfile
import six.moves.urllib as urllib
import tensorflow as tf
import numpy as np
from flask import Flask, request, jsonify, render_template
from flask import Response, redirect, url_for, flash, send_file
from configparser import ConfigParser
from PIL import Image
#from matplotlib import pyplot as plt
import cv2
#cap = cv2.VideoCapture(0)
# This is needed since the notebook is stored in the object_detection folder.
sys.path.append("..")
from utils import label_map_util
from utils import visualization_utils as vis_util

#parser = ConfigParser()
#pwd = os.path.dirname(__file__)
#parser.read(os.path.join(os.path.abspath(pwd), "../../", "settings.conf"))
#DEBUG = bool(parser.get("ENV", "DEBUG"))
#HOST = str(parser.get("ENV", "HOST"))
#PORT = int(parser.get("ENV", "PORT"))

app = Flask(__name__)
#app.debug = DEBUG

# Path to frozen detection graph. This is the actual model that is used for the object detection.
PATH_TO_CKPT = 'output_graph/frozen_inference_graph.pb'

# List of the strings that is used to add correct label for each box.
PATH_TO_LABELS = os.path.join('data', 'object_detection.pbtxt')
NUM_CLASSES = 1
ALLOWED_EXTENSIONS = set(['txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'])

# ## Load a (frozen) Tensorflow model into memory.
detection_graph = tf.Graph()
with detection_graph.as_default():
    od_graph_def = tf.GraphDef()
    with tf.gfile.GFile(PATH_TO_CKPT, 'rb') as fid:
        serialized_graph = fid.read()
        od_graph_def.ParseFromString(serialized_graph)
        tf.import_graph_def(od_graph_def, name='')

# ## Loading label map
# Label maps map indices to category names, so that when our convolution network predicts `5`, we know that this corresponds to `airplane`.  Here we use internal utility functions, but anything that returns a dictionary mapping integers to appropriate string labels would be fine
label_map = label_map_util.load_labelmap(PATH_TO_LABELS)
categories = label_map_util.convert_label_map_to_categories(label_map, max_num_classes=NUM_CLASSES, use_display_name=True)
category_index = label_map_util.create_category_index(categories)


# ## Helper code
def load_image_into_numpy_array(image):
    (im_width, im_height) = image.size
    rgbValues = np.array(image.getdata())
    if rgbValues.shape[1] == 4: rgbValues = np.delete(rgbValues, 3, 1)
    return rgbValues.reshape((im_height, im_width, 3)).astype(np.uint8)
'''
def gen():
    """Video streaming generator function."""
    with detection_graph.as_default():
        with tf.Session(graph=detection_graph) as sess:    
            while True:
                image_tensor = detection_graph.get_tensor_by_name('image_tensor:0')
                detection_boxes = detection_graph.get_tensor_by_name('detection_boxes:0')
                detection_scores = detection_graph.get_tensor_by_name('detection_scores:0')
                detection_classes = detection_graph.get_tensor_by_name('detection_classes:0')
                num_detections = detection_graph.get_tensor_by_name('num_detections:0')

                ret, image_np = cap.read()
                # Expand dimensions since the model expects images to have shape: [1, None, None, 3]
                image_np_expanded = np.expand_dims(image_np, axis=0)
                # Actual detection.
                (boxes, scores, classes, num_detections) = sess.run([detection_boxes, detection_scores, detection_classes, num_detections], 
                feed_dict={image_tensor: image_np_expanded})
                # Visualization of the results of a detection.
                vis_util.visualize_boxes_and_labels_on_image_array(
                    image_np,
                    np.squeeze(boxes),
                    np.squeeze(classes).astype(np.int32),
                    np.squeeze(scores),
                    category_index,
                    use_normalized_coordinates=True,
                    line_thickness=8)
                cv2.imwrite('output_stream.jpg', cv2.resize(image_np, (800,600)))
                yield (b'--frame\r\n'
                    b'Content-Type: image/jpeg\r\n\r\n' + open('output_stream.jpg', 'rb').read() + b'\r\n')
'''
@app.route('/detection_stream')
def detection_stream():
    """Video streaming home page."""
    return render_template('stream.html')

@app.route('/video_feed')
def video_feed():
    """Video streaming route. Put this in the src attribute of an img tag."""
    return Response(gen(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/upload')
def upload_file():
    return render_template('upload.html', host=HOST)

@app.route("/detect", methods=['GET', 'POST'])
def detect():
    with detection_graph.as_default():
        with tf.Session(graph=detection_graph) as sess:
            image_tensor = detection_graph.get_tensor_by_name('image_tensor:0')
            detection_boxes = detection_graph.get_tensor_by_name('detection_boxes:0')
            detection_scores = detection_graph.get_tensor_by_name('detection_scores:0')
            detection_classes = detection_graph.get_tensor_by_name('detection_classes:0')
            num_detections = detection_graph.get_tensor_by_name('num_detections:0')

            img64 = request.form['image']
            msg = base64.b64decode(img64)
            buf = io.BytesIO(msg)
            img = Image.open(buf)
            image_np = load_image_into_numpy_array(img)
            image_np_expanded = np.expand_dims(image_np, axis=0)
            # Actual detection.
            (boxes, scores, classes, num) = sess.run(
                [detection_boxes, detection_scores, detection_classes, num_detections],
                feed_dict={image_tensor: image_np_expanded})
            
            # Visualization of the results of a detection.
            vis_util.visualize_boxes_and_labels_on_image_array(
                image_np,
                np.squeeze(boxes),
                np.squeeze(classes).astype(np.int32),
                np.squeeze(scores),
                category_index,
                use_normalized_coordinates=True,
                line_thickness=8)
            img = Image.fromarray(image_np)
            width, height = img.size
            classes = classes[0]
            boxes = boxes[0]
            scores = scores[0]
            dclasses = [category_index.get(value) for index,value in enumerate(classes) if scores[index] > 0.3]
            boxes = boxes[:len(dclasses)]
            for i, box in enumerate(boxes):
                dclasses[i]['ymin'] = box[0]*height
                dclasses[i]['xmin'] = box[1]*width
                dclasses[i]['ymax'] = box[2]*height
                dclasses[i]['xmax'] = box[3]*width
            return jsonify({
                "data": dclasses
            })
    #img.save("output_image.jpg"+ftype)
    #return send_file("./output_image.jpg", mimetype='image/jpeg')

@app.route('/stream.mjpg')
def stream():
    return render_template('webrtc.html', host=HOST)

@app.route("/detect_upload", methods=['GET', 'POST'])
def detect_upload():
    if 'file' not in request.files:
        flash('No file part')
        return redirect(request.url)
    file = request.files['file']
    # if user does not select file, browser also
    # submit a empty part without filename
    if file.filename == '':
        flash('No selected file')
        return redirect(request.url)
    ftype = file.filename.split(".")[-1]
    if file is None or ftype not in ALLOWED_EXTENSIONS:
        return jsonify({
            "success": False,
            "message": "File corrupted or file type not allowed."
        })
    with detection_graph.as_default():
        with tf.Session(graph=detection_graph) as sess:
            image_tensor = detection_graph.get_tensor_by_name('image_tensor:0')
            detection_boxes = detection_graph.get_tensor_by_name('detection_boxes:0')
            detection_scores = detection_graph.get_tensor_by_name('detection_scores:0')
            detection_classes = detection_graph.get_tensor_by_name('detection_classes:0')
            num_detections = detection_graph.get_tensor_by_name('num_detections:0')
            # image processing
            image = Image.open(file)
            image_np = load_image_into_numpy_array(image) # the array of the image is used later to prepare the result image with boxes and labels on it.
            image_np_expanded = np.expand_dims(image_np, axis=0) # Expand dimensions since the model expects images to have shape: [1, None, None, 3]
            # Actual detection.
            (boxes, scores, classes, num) = sess.run([detection_boxes, detection_scores, detection_classes, num_detections],
                                                    feed_dict={image_tensor: image_np_expanded})
            # Visualization of the results of a detection.
            vis_util.visualize_boxes_and_labels_on_image_array(
                image_np,
                np.squeeze(boxes),
                np.squeeze(classes).astype(np.int32),
                np.squeeze(scores),
                category_index,
                use_normalized_coordinates=True,
                line_thickness=8)
            im = Image.fromarray(image_np)
            im.save("output_image."+ftype)
            return send_file("./output_image."+ftype, mimetype='image/'+ftype)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8088, debug=True)
