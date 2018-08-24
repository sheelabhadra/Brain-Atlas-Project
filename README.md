# Brain-Atlas-Project
Matlab code for the automatic use of the Allen Brain Institute's Mouse Brain Atlas.

This program:
- Chooses the corresponding skeleton from the atlas for an image of a brain slice
- Registers the skeleton to the base image
- Counts fluorescently-marked neurons and exports them with respect to the sections they are located in

### Resources Used
- [Matlab Image Processing Toolbox](https://www.mathworks.com/products/image.html)
- [Computer Vision System Toolbox](https://in.mathworks.com/products/computer-vision.html)
- [Image Registration](https://in.mathworks.com/help/images/example-performing-image-registration.html)
- [Feature Detection and matching](https://in.mathworks.com/help/vision/examples/find-image-rotation-and-scale-using-automated-feature-matching.html)

### Registration
**Manual Control Point Selection**  
The registration process is based on placing control points on the atlas (skeleton) and corresponding control points on the base image. This is achieved by calculating the transformation function that maps the control points on the base image to the control points on the atlas. Matlab provides an easy to use tool which can be accessed using [cpselect()](https://in.mathworks.com/help/images/ref/cpselect.html) to select control points on both the atlas and the base image. In general, the higher the number of control points, the better the registration.  

Once the control points are selected manually [fitgeotrans()](https://in.mathworks.com/help/images/ref/fitgeotrans.html) can be used to find the transformation function mapping the control points. The transformation types that provided us the best results are: `polynomial` with degree 2, and `lwm`. This step is followed by using [imwarp()](https://in.mathworks.com/help/images/ref/imwarp.html) which applies the transformation function on the atlas or the base image to fit them.  

The `cpselect_warp()` method combines the control point selection and the warping steps. It takes in the path to the base image and the path to the atlas as its arguments and returns the transformation function and the image obtained after applying the transformation function to it.  

If the control points have been saved beforehand, the `warp_image()` method can be used to find the transformation function and the image after warping.  

**Automatic Control Point Selection**  
The automatic control point selection involves 2 key steps:  
- Placing control points uniformly on the outer boundary of the image  
- Selecting control points in the interior of the base image and the atlas  

The `uniform_cp_select()` function takes as input a binary image containing the outer boundary marked in white and the number of control points to be placed on the boundary. It then places these control points uniformly on the outer boundary. The recommended number of control points is 16.  

The next step of the process is to create a standard or reference image on which feature detection algorithms such as Harris corners and SURF (Speeded Up Robust Features) can find salient features. This is facilitated by creating a standard/representative image by fitting a base image to the atlas using `warp_image()` or `cpselect_warp()`. The feature detection algorithms are run on both the standard image and the base image to find keypoints. Finally, feature matching is run on the keypoints extracted from both the standard image and the base image to obtain matching keypoints. These matching keypoints are then added to the set of control points.  

These control points are used to find the transformation function which is then applied to the atlas to fit it to the base image. The new warped atlas is further used for counting neurons in its subsections.  

### Counting
A database containing the coordinates of the boundaries of each of the sections in the original atlas is created and stored in .mat files. The transformation function is applied to the original coordinates to obtain the new coordinates of the warped atlas. The coordinates of the neurons are extracted from an image containing the fluorescently-marked neurons. [inpolygon()](https://in.mathworks.com/help/matlab/ref/inpolygon.html) is used to count the number of neurons inside each subsection. The section wise count is exported to an excel file. The `count_neurons()` function can be invoked for counting the neurons.  

Running the scripts `manual_cp_counting.m` and `automatic_cp_counting.m` perform the manual and automatic control point placement respectively. Currently, the manual registration and counting works perfectly but the automatic registration needs plenty of manual parameter tuning.  

### TODO list
- [ ] Improving feature matching in automatic control point selection
- [ ] Minimizing manual parameter tuning
- [ ] Matching a given brain slice to the correct atlas