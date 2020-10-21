## **Implementation of scale-invariant feature transform (SIFT) from scratch in MATLAB**


### **Results**
The function `sift` is responsible for computing the keypoint locations and their attributes and the descriptor for each keypoint. This function has two outputs:

1. `PoI` (Points-of-interest) which is a matrix each row contains the information for one of detected keypoints. In each row, 38 values are available. The first two value imply the y and x cordinates of the keypoint respectivly. The rest is the histogram of the prominent orientation. There are 36 orientations and the magnitude of the **prominent** orientations have a value other that zero and the rest have zero as their magnitude. Please note that, the original value of all orientations were not originaly equal zero but based on the main sift algorithm only the prominent orientations (with a 80% rule)has the value unequal to zero. Please read the reference before getting into the code.

2. `Descs` which contains the descriptor for each keypoint.


**Fig. 1**- a sample result of the algorithm

<img src="1.jpg" width=600>


### **References**
- D.G. Lowe, "Distinctive Image Featuresfrom Scale-Invariant Keypoints", International Journal of Computer Vision, 2004
