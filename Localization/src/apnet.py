# Import the modules
import glob
import cv2
import numpy as np

APmodel = ap_reco_model(input_shape=(3, 96, 96))


def triplet_loss(y_true, y_pred, alpha=0.3):
	"""Implementation of Triplet Loss function

	Args:
		y_true ():
		y_pred ():

	Returns:
		float - loss 
	"""
	anchor, positive, negative = y_pred[0], y_pred[1], y_pred[2]
	# Step 1: Compute the (encoding) distance between the anchor and the positive, you will need to sum over axis=-1
	pos_dist = tf.reduce_sum(tf.square(tf.subtract(anchor, positive)), axis=-1)
	# Step 2: Compute the (encoding) distance between the anchor and the negative, you will need to sum over axis=-1
	neg_dist = tf.reduce_sum(tf.square(tf.subtract(anchor, negative)), axis=-1)
	# Step 3: subtract the two previous distances and add alpha.
	basic_loss = tf.add(tf.subtract(pos_dist, neg_dist), alpha)
	# Step 4: Take the maximum of basic_loss and 0.0. Sum over the training examples.
	loss = tf.reduce_sum(tf.maximum(basic_loss, 0.0))

	return loss


APmodel.compile(optimizer = 'adam', loss = triplet_loss, metrics = ['accuracy'])
load_weights_from_FaceNet(APmodel)


def prepare_database(path="../../Data/AP-image-data/", image_ext="tif"):
	X, y = [], []
	labels = {}

	i = 0
	for file in glob.glob(path+'*'):
		labels[i] = file.split('/')[-1].split('_')[0]
		print(labels[i])
		images = glob.glob(file+'/*.'+image_ext)
		y.extend([i]*len(images))
		for img in images:
			x = cv2.imread(img, 1) # Keep images in original color - change this to grayscale/single color
			x = cv2.resize(x, (96, 96)) # Reshape the images to 96x96
			x = x/255.0 # Normalization
			X.append(x)
		i += 1
	
	# Save labels in a text file
	with open('../../Data/labels.txt', 'w') as f:
		print(labels, file=f)

	# Save the dataset in numpy format
	np.save('../../Data/X.npy', X)
	np.save('../../Data/y.npy', y)
	
	return np.array(X), np.array(y)


def main():
	X, y = prepare_database()
	

if __name__ == '__main__':
	main()

