import numpy as np
import os
from sklearn.model_selection import train_test_split
from tensorflow.contrib.keras import models, layers, optimizers, callbacks
import h5py
import pickle
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import sys
from contextlib import redirect_stdout

pop = sys.argv[1]
numChannels = int(sys.argv[2])

training_data = '../sims/' + pop + '/trainingData/' #for loading
to_model = '../models/' + pop + '/new/' #for saving

# load data
x = np.load(training_data + 'fvecs.npy')
x = x[:,:,:,0:numChannels]
y = np.load(training_data + 'targets.npy')
logCenter = np.load(training_data + 'center.npy')
logScale = np.load(training_data + 'scale.npy')

# untransform predicted data
def exp_transform(logZ):
    return np.exp(logScale*logZ + logCenter)

# save fit plots
def plotFit(x,y):
    #first get the predictions
    preds=model.predict(x)

    preds_transform = exp_transform(preds)
    pred_mean = preds_transform[:,0]
    pred_stdev = preds_transform[:,1]

    y_test_transform = exp_transform(y)
    test_mean = y_test_transform[:,0]
    test_stdev = y_test_transform[:,1]

    #now plot them side by side
    fig, ax = plt.subplots(1,2, figsize=(12,6))

    ax[0].scatter(test_mean, pred_mean)
    ax[0].set_xlabel("True mean")
    ax[0].set_ylabel("Predicted mean")
    x_min, x_max = ax[0].get_xlim()
    y_min, y_max = (x_min, x_max)
    ax[0].plot([x_min, x_max], [y_min, y_max])

    ax[1].scatter(test_stdev, pred_stdev)
    ax[1].set_xlabel("True standard deviation")
    ax[1].set_ylabel("Predicted standard deviation")
    x_min, x_max = ax[1].get_xlim()
    y_min, y_max = (x_min, x_max)
    ax[1].plot([x_min, x_max], [y_min, y_max])

    fig.savefig(to_model + pop + '_fit.png', dpi=1200)


# split into train, validation, and test sets
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.1)
x_train, x_val, y_train, y_val = train_test_split(x_train, y_train, test_size = 0.1)

# define model
model = models.Sequential()

model.add(layers.Conv2D(256, 6, activation='relu', padding='same', name='conv2d_1',
                        input_shape=x_train.shape[1:]))
model.add(layers.Dropout(0.3, name='dropout_1'))
model.add(layers.Conv2D(512, 2, activation='relu', padding='same', name='conv2d_2'))
model.add(layers.MaxPooling2D(2, name='maxpool2d_1'))
model.add(layers.Conv2D(1024, 3, activation='relu', padding='same', name='conv2d_3'))
model.add(layers.Dropout(0.2, name='dropout_2'))
model.add(layers.Conv2D(2048, 3, activation='relu', padding='same', name='conv2d_4'))
model.add(layers.MaxPooling2D(2, name='maxpool2d_2'))
#model.add(layers.Conv2D(2048, 3, activation='relu', padding='same', name='conv2d_5'))
#model.add(layers.Dropout(0.3, name='dropout_3'))
model.add(layers.Flatten(name='flatten'))
#model.add(layers.Dense(4096, name='dense_1'))
#model.add(layers.Dropout(0.2, name='dropout_4'))
model.add(layers.Dense(2048, name='dense_2'))
model.add(layers.Dropout(0.3, name='dropout_5'))
model.add(layers.Dense(256, name='dense_3'))
#model.add(layers.Dropout(0.2, name='dropout_6'))
model.add(layers.Dense(2, name='dense_4'))
    
model.compile(optimizer=optimizers.Adam(lr=0.00001), loss='mse', metrics=[])

# save model summary
with open(to_model + 'summary.txt', 'w') as f:
    with redirect_stdout(f):
        model.summary()

# train and save model/history
checkpoint = callbacks.ModelCheckpoint(to_model + pop + '_demog_logmodel', 
                                       monitor='val_loss',
                                       save_best_only=True, 
                                       save_weights_only=False, 
                                       mode='auto', 
                                       period=1)

history = model.fit(x_train, y_train, 
                    validation_data=[x_val, y_val],
                    epochs=150, batch_size=500,
                    callbacks=[checkpoint])

with open(to_model + pop + "_demog_history", 'wb') as my_pickle:
    pickle.dump(history.history, my_pickle)

# save training plot
plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title(pop + ' model loss')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.legend(['train', 'validation'], loc='upper right')
plt.savefig(to_model + pop + '_loss.png', dpi=1200)

# save fit plot
plotFit(x_test, y_test)

