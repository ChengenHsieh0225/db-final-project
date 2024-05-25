import tensorflow as tf
from tensorflow.keras import layers, models
import json
import mysql.connector
import time
import numpy as np

# 設置打印選項，打印所有的資料，不被省略
np.set_printoptions(threshold=np.inf)

with open('hw5_config.json') as f:
    config = json.load(f)

host = config['host']
user = config['user']
passwd = config['passwd']
mydb = mysql.connector.connect(host=host, user=user, passwd=passwd)
mycursor = mydb.cursor()

DB_NAME = "final_project"
mycursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME};")
mycursor.execute(f"USE {DB_NAME};")

# 定義CNN模型
def create_cnn_model():
    model = models.Sequential()
    model.add(layers.Conv2D(32, (3, 3), activation='relu', input_shape=(28, 28, 1)))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(64, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(64, (3, 3), activation='relu'))
    model.add(layers.Flatten())
    model.add(layers.Dense(64, activation='relu'))
    model.add(layers.Dense(10, activation='softmax')) # 10個類別的輸出層
    return model
def create_cnn_model_2():
    model = models.Sequential()
    model.add(layers.Conv2D(8, (3, 3), activation='relu', input_shape=(28, 28, 1)))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(4, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Flatten())
    model.add(layers.Dense(16, activation='relu'))
    model.add(layers.Dense(10, activation='softmax')) # 10個類別的輸出層
    return model
def update_conv2d_weight_1(shape, arr):
    if len(shape) == 4:
        for idx in range(shape[3]):
            for dim1 in range(shape[0]):
                for dim2 in range(shape[1]):
                    mycursor.execute(f"INSERT INTO conv2d_1_weights (filter_index, dim1, dim2, weight ) VALUES (%s, %s, %s, %s) ON DUPLICATE KEY UPDATE weight = VALUES(weight);", [idx, dim1, dim2, float(arr[dim1][dim2][0][idx])])
                    mydb.commit()

    else:
        for idx in range(shape[0]):
            mycursor.execute(f"INSERT INTO conv2d_1_biases (filter_index, weight ) VALUES (%s, %s) ON DUPLICATE KEY UPDATE weight = VALUES(weight);", [idx, float(arr[idx])])
            mydb.commit()

def update_conv2d_weight_2(shape, arr):
    if len(shape) == 4:
        for idx in range(shape[3]):
            for dim1 in range(shape[0]):
                for dim2 in range(shape[1]):
                    for channel in range(shape[2]):
                        mycursor.execute(f"INSERT INTO  conv2d_2_weights (filter_index, dim1, dim2, channel, weight ) VALUES (%s, %s, %s, %s, %s) ON DUPLICATE KEY UPDATE weight = VALUES(weight);", [idx, dim1, dim2, channel, float(arr[dim1][dim2][channel][idx])])
                        mydb.commit()

    else:
        for idx in range(shape[0]):
            mycursor.execute(f"INSERT INTO conv2d_2_biases (filter_index, weight ) VALUES (%s, %s) ON DUPLICATE KEY UPDATE weight = VALUES(weight);", [idx, float(arr[idx])])
            mydb.commit()

def update_dense_weight_1(shape, arr):
    if len(shape) == 2:
        for dim1 in range(shape[0]):
            for idx in range(shape[1]):
                mycursor.execute(f"INSERT INTO  dense_1_weights  (filter_index, dim1, weight ) VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE weight = VALUES(weight);", [idx, dim1, float(arr[dim1][idx])])
                mydb.commit()

    else:
        for idx in range(shape[0]):
            mycursor.execute(f"INSERT INTO dense_1_biases (filter_index, weight ) VALUES (%s, %s) ON DUPLICATE KEY UPDATE weight = VALUES(weight);", [idx, float(arr[idx])])
            mydb.commit()

def update_dense_weight_2(shape, arr):
    if len(shape) == 2:
        for dim1 in range(shape[0]):
            for idx in range(shape[1]):
                mycursor.execute(f"INSERT INTO  dense_2_weights   (filter_index, dim, weight ) VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE weight = VALUES(weight);", [idx, dim1, float(arr[dim1][idx])])
                mydb.commit()

    else:
        for idx in range(shape[0]):
            mycursor.execute(f"INSERT INTO dense_2_biases (filter_index, weight ) VALUES (%s, %s) ON DUPLICATE KEY UPDATE weight = VALUES(weight);", [idx, float(arr[idx])])
            mydb.commit()



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

# 創建模型
model = create_cnn_model_2()
loss_fn = tf.keras.losses.CategoricalCrossentropy()
optimizer = tf.keras.optimizers.Adam()
model.compile(optimizer=optimizer, loss=loss_fn, metrics=['accuracy'])
# 定義訓練步驟函數
# @tf.function
def train_step(images, labels):
    
    with tf.GradientTape() as tape:
        # 前向傳播
        predictions = model(images, training=True)
        # print(predictions)        

        # predictions = myprediction
        # tf.print(predictions, summarize=-1)
        # print(predictions)
        # 計算損失
        loss = loss_fn(labels, predictions)
    
    # 計算梯度
    gradients = tape.gradient(loss, model.trainable_variables)
    # 手動更新權重
    optimizer.apply_gradients(zip(gradients, model.trainable_variables))
    # tf.print("Start here: ")
    # tf.print(model.trainable_variables, summarize=-1)
    # print(model.trainable_variables)
    # cnt=0
    for var in model.trainable_variables:
        # cnt+=1
        # print(cnt)
        # print(var.name, var.numpy())
        # print(var.name)
        print(f"{var.name} shape={var.shape} dtype={var.dtype}")
        if (var.name == "conv2d/kernel:0" or var.name ==  "conv2d/bias:0"):
            update_conv2d_weight_1(var.shape, var.numpy())
        elif(var.name == "conv2d_1/kernel:0" or var.name ==  "conv2d_1/bias:0"):
            update_conv2d_weight_2(var.shape, var.numpy())
        elif(var.name == "dense/kernel:0" or var.name ==  "dense/bias:0"):
            update_dense_weight_1(var.shape, var.numpy())
        elif(var.name == "dense_1/kernel:0" or var.name ==  "dense_1/bias:0"):
            update_dense_weight_2(var.shape, var.numpy())

    
    return loss, predictions

# 訓練模型
epochs = 1
batch_size = 750
num_batches = train_images.shape[0] // batch_size
# cnt=0
# print(train_images.shape[0])
for epoch in range(epochs):
    for batch in range(num_batches):
        # print("batch")
        # print(batch)
        batch_start = batch * batch_size
        batch_end = (batch + 1) * batch_size
        batch_images = train_images[batch_start:batch_end]
        batch_labels = train_labels[batch_start:batch_end]
        # print(batch_labels)
        
        loss, predictions = train_step(batch_images, batch_labels)
        # cnt+=1
        
        # print(f"Epoch {epoch + 1}, Batch {batch + 1}, Loss: {loss.numpy()}")
        # print(f"Softmax layer output after batch {batch + 1}:")
        # print(predictions.numpy())
# print(cnt)



# model.compile(optimizer='adam',
#               loss='categorical_crossentropy',
#               metrics=['accuracy'])

# # 訓練模型
# model.fit(train_images, train_labels, epochs=1, batch_size=750, validation_split=0.2, callbacks=[LayerTimeCallback()])

# 評估模型
test_loss, test_acc = model.evaluate(test_images, test_labels)
print('Test accuracy:', test_acc)

mycursor.close()
mydb.close()