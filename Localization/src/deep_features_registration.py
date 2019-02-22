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


def vgg16_features(img):
    """VGG16 features for an image.
    Args: 
        

    Returns:


    """

    model = VGG16(weights='imagenet', include_top=False)

    # get the output of the last maxpooling layer - "block5_pool" or layer[-5]
    layer_name = 'block5_pool'
    get_vgg_features = Model(inputs=model.input, outputs=model.get_layer(layer_name).output)
    
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

    windowed_features_1 = sliding_window(feature1[0], 7)
    windowed_features_2 = sliding_window(feature2[0], 7)

    for (f1, f2) in zip(windowed_features_1, windowed_features_2):
        if cosine_similarity(f1.flatten(), f2.flatten()) > thresh:
            roi_list.append(roi_num)
        roi_num += 1

    return roi_list


def deep_points(img, roi_list):
    """Get points from the ROIs.

    """

    stride = 32 # 2^5 = 32 (5 max-pooling layers)
    y_steps = 4
    x_steps = 9

    # Get the regions from the roi_list in the original image
    cropped_roi_features, coords = [], []

    for roi_num in roi_list:
        cropped_img = img[32*(roi_num//x_steps): 224+32*(roi_num//x_steps), 32*(roi_num//y_steps): 224+32*(roi_num//y_steps), :]
        regions = sliding_window(cropped_img, 32)

        xS = (roi_num//y_steps)*32
        yS = (roi_num//x_steps)*32

        for i in range(len(regions)):
            cropped_roi_features.append(vgg16_features(regions[i]))
            xC = xS + 16 + i%(224 - 32)
            yC = yS + 16 + i//(224 - 32)
            coords.append((xC, yC))

    return cropped_roi_features, coords


def get_matching_points(que_roi_features, que_coords, ref_roi_features, ref_coords):
    thresh = 0.5
    matching_points = []

    i = 0
    for (qf, rf) in zip(que_roi_features, ref_roi_features):
        if cosine_similarity(qf.flatten(), rf.flatten()) > thresh:
            matching_points.append(que_coords[i])
        i += 1

    return matching_points


def main():
    que_img = cv2.imread('../Data/AP-image-data/train/-0.46/01.jpg')
    que_img = cv2.resize(que_img, (480, 320), interpolation=cv2.INTER_CUBIC)
    features_que = vgg16_features(que_img)

    ref_img = cv2.imread('../Data/AP-image-data/train/-0.46/02.jpg')
    ref_img = cv2.resize(ref_img, (480, 320), interpolation=cv2.INTER_CUBIC)
    features_ref = vgg16_features(ref_img)

    roi_list = deep_roi(features_que, features_ref)

    que_roi_features, que_coords = deep_points(que_img, roi_list)

    ref_roi_features, ref_coords = deep_points(ref_img, roi_list)

    print(matching_points(que_roi_features, que_coords, ref_roi_features, ref_coords))



if __name__ == "__main__":
    main()







