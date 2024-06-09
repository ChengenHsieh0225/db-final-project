import tensorflow as tf
from tensorflow.keras import layers, models
import mysql.connector
import json

# 載入資料集
mnist = tf.keras.datasets.mnist
(train_images, train_labels), (test_images, test_labels) = mnist.load_data()

# 預處理資料
train_images = train_images.reshape((60000, 28, 28, 1))
train_images = train_images.astype('float32') / 255

test_images = test_images.reshape((10000, 28, 28, 1))
test_images = test_images.astype('float32') / 255

train_labels = tf.keras.utils.to_categorical(train_labels)
test_labels = tf.keras.utils.to_categorical(test_labels)

# ==== connect to mySQL ====
# TODO: add database info to hw5_config.json
with open('hw5_config.json') as f:
    config = json.load(f)

host = config['host']
user = config['user']
passwd = config['passwd']

mydb = mysql.connector.connect(
  host=host,
  user=user,
  passwd=passwd
)
mycursor = mydb.cursor()

DB_NAME = "final_project"

# create database
mycursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME};")
mycursor.execute(f"USE {DB_NAME};")

# TODO: add tables (call create_tables.sql)

# insert train_images
for train_index, r0 in enumerate(train_images):
    for x, r1 in enumerate(r0):
        for y, r2 in enumerate(r1):
            if not r2[0]:
                continue
            mycursor.execute(f"INSERT INTO input_image (image_index, dim1, dim2, channel, value) VALUES (%s, %s, %s, 0, %s);", 
                             [train_index, x, y, float(r2[0])])
            
mydb.commit()

# insert train_labels
for image_index, r0 in enumerate(train_labels):
    for index, value in enumerate(r0):
        if (value == 0):
            continue
        else:
            mycursor.execute(f"INSERT INTO image_labels (image_index, label) VALUES (%s, %s);", 
                              [image_index, index])
mydb.commit()