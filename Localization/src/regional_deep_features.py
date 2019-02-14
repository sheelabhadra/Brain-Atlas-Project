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

def ssd(x,y):
    """Sum of squared distance (SSD) between 2 feature vectors.

    Args:
        x (ndarray): feature vector
        y (ndarray): feature vector
    
    Returns:
        float: SSD
    
    Raises:
        Exception if the array shapes do not match
    """
    
    if x.shape != y.shape:
        raise Exception("The shapes of the arrays are different!")
    return np.linalg.norm(x,y)


def cosine_similarity(x,y):
    """Cosine similarity between 2 feature vectors.

    Args:
        x (ndarray): feature vector
        y (ndarray): feature vector
    
    Returns:
        float: Cosine Similarity
    
    Raises:
        Exception if the array shapes do not match
    """
    
    if x.shape != y.shape:
        raise Exception("The shapes of the arrays are different!")
    return np.dot(x,y)/(np.linalg.norm(x)*np.linalg.norm(y))


def regional_vgg_features(filename, coordinates, patch_size=20):
    """Extracts VGG16 features from locations where feature matches have occured.

    Args:
        filename (str): Path to the location of the image
        coordinates (list): List of locations (x,y) of feature matches
        patch_size (int): Size of the image patch on which VGG16 features need to be extracted

    Returns:
        ndarray: VGG16 feature vector computed at all the feature matches
    """
    
    model = VGG16(weights='imagenet', include_top=False)

    # get the output of the last maxpooling layer - "block5_pool" or layer[-5]
    layer_name = 'block5_pool'
    get_vgg_features = Model(inputs=model.input, outputs=model.get_layer(layer_name).output)

    # Select the images to extract VGG features from the candidate list.
    # The candidate list should contain the exact path to the images.
    img = cv2.imread(filename)
    
    img = cv2.resize(img, None, fx=0.2, fy=0.2, interpolation=cv2.INTER_AREA)

    # Zero pad the image to handle the feature points near the edges
    # img = np.pad(img, [patch_size, patch_size], mode='constant')
    color = [0, 0, 0]
    img = cv2.copyMakeBorder(img, patch_size, patch_size, patch_size, patch_size, cv2.BORDER_CONSTANT, value=color)

    feature_vector = []
    for i,coord in enumerate(coordinates):
        cropped_img = img[int(coord[1]) - patch_size:int(coord[1]) + patch_size, int(coord[0]) - patch_size:int(coord[0]) + patch_size, :]
        x = image.img_to_array(cropped_img)
        x = np.expand_dims(x, axis=0)
        x = preprocess_input(x)
        features = get_vgg_features.predict(x)
        features_np = np.array(features)
        feature_vector.append(features_np.flatten())

    return feature_vector


def find_best_match(query_image, candidates, feature_match_points, feature_match_points_size):
    """Finds the best matching reference image for a query image

    Args:
        query_image (str): Path to the location of the query image
        candidates (list): Contains the paths to the location of the reference images
        feature_match_points (list): Contains the locations of the feature matches
        feature_match_points_size (list): The number of matching feature points for each reference image

    Returns:
        str: Best matching AP number
    """

    feature_match_points_apwise = []
    start, end = 0, 0
    for i in range(len(feature_match_points_size)):
        end = start + 2*feature_match_points_size[i]
        # Query image
        feature_match_points_apwise.append(feature_match_points[start:end,:])
        start = end

    scores = namedtuple('scores', ['ssd', 'cos_sim'])
    similarity_scores_dict = {}
    for ap,pair in enumerate(feature_match_points_apwise):
        # Query image
        query_feature_vector = regional_vgg_features(query_image, pair[:len(pair)//2, :])

        # Candidate image
        candidate_feature_vector = regional_vgg_features(candidates[ap], pair[len(pair)//2:, :])

        # Find the SSD and the Cosine Similarity
        ssd_score = ssd(query_feature_vector, candidate_feature_vector)
        cos_sim_score = cosine_similarity(query_feature_vector, candidate_feature_vector)

        ap_num = candidates[ap].split('/')[-2]
        similarity_scores_dict[ap_num].append(scores(ssd_score, cos_sim_score))

    best_match, min_ssd = None, float('inf')
    for ap_num, scores in similarity_scores_dict.items():
        if scores.ssd_score < min_ssd:
            min_ssd = scores.ssd_score
            best_match = ap_num
    
    return best_match, similarity_scores_dict


def main():
    query_image = '../Data/AP-image-data/train/-0.46/02.jpg'
    
    candidates = pd.read_csv('feature-points/candidates.csv', header=None)
    candidates = candidates.values.flatten()
    
    feature_match_points = pd.read_csv('feature-points/feature_match_points.csv', header=None)
    feature_match_points = feature_match_points.values

    feature_match_points_size = pd.read_csv('feature-points/feature_match_points_size.csv', header=None)
    feature_match_points_size = feature_match_points_size.values.flatten()

    best_matching_AP, similarity_scores_dict = find_best_match(query_image, candidates, feature_match_points, feature_match_points_size)

if __name__ == '__main__':
    main()
