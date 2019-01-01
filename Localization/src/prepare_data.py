import cv2
import glob

path = '../../Data/AP-image-data/validation'
image_ext = "jpg"

for file in glob.glob(path+'/*'):
    images = glob.glob(file+'/*.'+image_ext)
    print(file)
    for img in images:
        gray = cv2.imread(img, 0) # Convert to grayscale/single color
        x = cv2.cvtColor(gray, cv2.COLOR_GRAY2RGB)
        cv2.imwrite(img, x)
