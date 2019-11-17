
# import modules
import math
import os
import numpy as np
import pickle
from tensorflow.contrib.keras import models, layers, optimizers, callbacks
from sklearn.model_selection import train_test_split

# import data
x = np.load('dl_data/stacked_windows/demog_images.npy')
y = np.load('dl_data/stacked_windows/demog_moments.npy')

# split data into train, validation, and test sets
np.random.seed(1)
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.1)
x_train, x_val, y_train, y_val = train_test_split(x_train, y_train, test_size = 0.1)

# build and compile model
model = models.Sequential()

model.add(layers.Conv2D(256, 6, activation='relu', padding='same', name='conv2d_1',
                        input_shape=(36,45,200)))
model.add(layers.Dropout(0.1, name='dropout_1'))
model.add(layers.Conv2D(512, 4, activation='relu', padding='same', name='conv2d_2'))
model.add(layers.MaxPooling2D(4, name='maxpool2d_1'))
model.add(layers.Conv2D(1024, 6, activation='relu', padding='same', name='conv2d_3'))
model.add(layers.Dropout(0.2, name='dropout_2'))
model.add(layers.Conv2D(2048, 6, activation='relu', padding='same', name='conv2d_4'))
model.add(layers.MaxPooling2D(4, name='maxpool2d_2'))
model.add(layers.Flatten(name='flatten_1'))
model.add(layers.Dense(4096, name='dense_1'))
model.add(layers.Dropout(0.5, name='dropout_4'))
model.add(layers.Dense(2048, name='dense_2'))
model.add(layers.Dropout(0.2, name='dropout_5'))
model.add(layers.Dense(256, name='dense_3'))
model.add(layers.Dropout(0.1, name='dropout_6'))
model.add(layers.Dense(2, name='dense_4'))
    
model.compile(optimizer=optimizers.Adam(lr=0.00001), loss='mse', metrics=[])

# fit and save model
checkpoint = callbacks.ModelCheckpoint('dl_data/stacked_windows/euro_demog_model', 
                                       monitor='val_loss',
                                       save_best_only=True, 
                                       save_weights_only=False, 
                                       mode='auto', 
                                       period=1)

history = model.fit(x_train, y_train, 
                    validation_data=[x_val, y_val],
                    epochs=300, batch_size=50,
                    callbacks=[checkpoint])

# pickle model history
with open("dl_data/stacked_windows//euro_demog_history", 'wb') as my_pickle:
    pickle.dump(history.history, my_pickle)
