import pickle
import numpy as np
import pandas as pd
import cv2

from collections import namedtuple

from keras.models import Model
from keras.models import load_model
from keras.applications.vgg16 import VGG16
from keras.preprocessing import image
from keras.applications.vgg16 import preprocess_input

from regional_deep_features import cosine_similarity, euclidean_distance


def vgg16_features(filename):
    """VGG16 features for an image.
    Args: 
        

    Returns:


    """

    model = VGG16(weights='imagenet', include_top=False)

    # get the output of the last maxpooling layer - "block5_pool" or layer[-5]
    layer_name = 'block5_pool'
    get_vgg_features = Model(inputs=model.input, outputs=model.get_layer(layer_name).output)

    # Select the images to extract VGG features from the candidate list.
    # The candidate list should contain the exact path to the images.
    img = cv2.imread(filename)
    
    # Set a fixed input dimension: (320x480)
    img = cv2.resize(img, (480, 320), interpolation=cv2.INTER_CUBIC)

    # Get the VGG16 features
    x = image.img_to_array(img)
    x = np.expand_dims(x, axis=0)
    x = preprocess_input(x)
    features = get_vgg_features.predict(x)
    features_np = np.array(features)
    
    return features_np


def sliding_window(M, win):
    """Regions obtained from sliding windows
    Args:
        M (ndarray): 
        win (ndarray): 
    Returns:
        list[ndarray]
    """

    x_steps = M.shape[1] - win + 1 
    y_steps = M.shape[0] - win + 1

    regions = []

    for y in range(y_steps):
        for x in range(x_steps):
            regions.append(M[y:y+win, x:x+win, :])

    return np.array(regions)


def deep_roi(feature1, feature2):
    """Regions of interest.

    """
    
    roi_list, thresh = [], 0.5

    # Get the feature vectors for the subregions
    roi_num = 0

    print(feature1.shape)

    windowed_features_1 = sliding_window(feature1[0], 7)
    windowed_features_2 = sliding_window(feature2[0], 7)

    for (f1, f2) in zip(windowed_features_1, windowed_features_2):
        if cosine_similarity(f1.flatten(), f2.flatten()) > thresh:
            roi_list.append(roi_num)
        roi_num += 1

    return roi_list


def deep_points(roi_list):
    """Get points from the ROIs.

    """
    pass


def main():
    features_que = vgg16_features('../Data/AP-image-data/train/-0.46/01.jpg')
    features_ref = vgg16_features('../Data/AP-image-data/train/-0.46/02.jpg')

    roi_list = deep_roi(features_que, features_ref)
    print(roi_list)

if __name__ == "__main__":
    main()







