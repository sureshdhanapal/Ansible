
# coding: utf-8

# In[9]:


import keras
import numpy as np
from keras.applications import vgg16
import base64
import numpy as np
import tensorflow as tf
import io
from PIL import Image
from keras import backend as K

from flask import request
from flask import jsonify
from flask import Flask

from keras.preprocessing.image import load_img
from keras.preprocessing.image import img_to_array
from keras.applications.vgg16 import preprocess_input
from keras.applications.vgg16 import decode_predictions 
from keras.models import model_from_json

## The vgg model load some data from internet and in python3.6 it gives ssl verificaion error. to avoid it add folloiwng 
## two lines
import ssl
ssl._create_default_https_context = ssl._create_unverified_context

app = Flask(__name__)


# In[10]:


def processImg(image , size):
    if image.mode != "RGB":
        image = image.convert("RGB")
    image = image.resize(size)
    image = img_to_array(image)
    image = np.expand_dims(image, axis=0)
    processed_image = vgg16.preprocess_input(image.copy())

    return processed_image


# In[11]:


def load_model():
    # load the model and weights from the saved model.
    global IC_Model
    json_file = open('IC_Model.json', 'r')
    model_json = json_file.read()
    json_file.close()
    IC_Model = model_from_json(model_json)

    # load weights into new model
    IC_Model.load_weights("IC_Model.h5")
    # creating global graph and will use it while prediction.
    global graph
    graph = tf.get_default_graph()
    print("Loaded model from disk") 


# In[16]:


# load an image from file
load_model()

@app.route("/predict", methods=["POST"])
def predict():

    message = request.get_json(force=True) 
    encoded = message['image']
    decoded = base64.b64decode(encoded)
    image = Image.open(io.BytesIO(decoded))
    processed_image = processImg(image, size=(224, 224))

# there is issue of synchronization in case of web service. so using tensorflow graph as global and using same graph which used 
# earlier while loading the model for prediction.
    with graph.as_default():
        prediction = IC_Model.predict(processed_image)
    
    label = decode_predictions(prediction)
    jsonList = list()
    #will only read first 4 predictions
    for i in range(4):
        pred = ""
        val = 100 * float(label[0][i][2])
        val = round (val, 2)
        pred = "" + label[0][i][1] + "(" + str (val) +  "%)"
        jsonList.append(pred)
    
    response = {
        'prediction': {
            'pred1': jsonList[0],
            'pred2': jsonList[1],
            'pred3': jsonList[2],
            'pred4': jsonList[3],            
        }
    }
    print (response)
    return jsonify(response)



