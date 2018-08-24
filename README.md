# Brain-Atlas-Project
Matlab code for the automatic use of the Allen Brain Institute's Mouse Brain Atlas.

This program:
- Chooses the corresponding skeleton from the atlas for an image of a brain slice
- Registers the skeleton to the base image
- Counts fluorescently-marked neurons and exports them with respect to the sections they are located in

### Resources Used
- [Matlab Image Processing Toolbox](https://www.mathworks.com/products/image.html)

### Registration
The registration process used in the project is based on placing control points on the atlas and corresponding control points on the base image. This is achieved by calculating the transformation function that maps the control points placed on the base image to the control points placed on the atlas. Matlab provides an easy to use tool which may be accessed using `[cpselect()](https://in.mathworks.com/help/images/ref/cpselect.html)` to select control points on both the atlas and the base image. In general, the more the number of control points selected, the better the registration.  

Once the control points are selected manually `[fitgeotrans()](https://in.mathworks.com/help/images/ref/fitgeotrans.html)` can be used to find the transformation function mapping the control points. The transformation types that provided us the best results are: `polynomial` with degree 2, and 'lwm'. This step is followed by using `imwarp()[https://in.mathworks.com/help/images/ref/imwarp.html]` which applies the transformation function on the atlas or the base image to fit them.  

The `cpselect_warp()` method combines the control point selection and the warping steps. It takes in the path to the base image and the path to the atlas as its arguments and returns the transformation function and the image obtained after applying the transformation function to it.  

If the control points have been saved beforehand, the `warp_image()` method can be used to find the transformation function and the image after warping.  
The automatic control point selection involves 2 key steps:  
1. Placing control points uniformly on the outer boundary of the image  
2. Selecting control points in the interior of the base image and the atlas  

The `uniform_cp_select()` function takes as input a binary image containing the outer boundary marked in white and the number of control points to be placed on the boundary. The recommended number of control points is 16. It then places these control points uniformly on the outer boundary.  

The next step of the process is to create a standard or reference image on which a feature detection algorithms such as Harris corners and SURF can find salient features. This is achieved by creating a warped base image after fitting a standard/representative image to the atlas using `warp_image()` or `cpselect_warp`. The feature detection algorithms were also run on the base image to find keypoints. Finally, feature matching was run on both the standard image and the base image to obtain matching keypoints. These matching keypoints are then added to the set of control points.  