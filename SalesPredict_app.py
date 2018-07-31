import pandas as pd
import numpy as np
import io
from flask import request
from flask import jsonify
from flask import Flask
import json
import pickle

app = Flask(__name__)

def get_model():
    global model
    model = pickle.load(open("rev_model.sav", 'rb'))
    print(" Model loaded!")

print(" * Loading Sales Prediction model...")
get_model()

@app.route("/predict", methods=["POST"])
def predict():
    message = request.get_json(force=True)
    print (message)
    EM_EXP = float (message["EM_EXP_INPUT"])
    RAD_EXP = float (message["RAD_EXP_INPUT"])
    PM_EXP = float (message["PM_EXP_INPUT"])
    
     
    test_Data = np.array([[EM_EXP, RAD_EXP , PM_EXP]])
    prediction = model.predict(test_Data)
    sales_value = int (prediction[0])
    
  

    response = {
        'prediction': {
            'EXP_SALES': sales_value

        }
    }
    return jsonify(response)

	