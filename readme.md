## **Implementation of scale-invariant feature transform (SIFT) from scratch in MATLAB**


### **Results**
The function `sift` is responsible for computing the keypoint locations and their attributes and the descriptor for each keypoint. This function has two outputs:

1. `PoI` (Points-of-interest), a matrix, each row contains the information for one of the detected keypoints. In each row, 38 values are available. The first two values imply the y and x coordinates of the keypoint, respectively. The rest is the histogram of the prominent orientation. There are 36 orientations, and the magnitude of the **prominent** orientations have a value other than zero, and the rest have zero as their magnitude. Please note that all orientations' original value was not initially equal to zero but based on the main sift algorithm, only the prominent orientations (with an 80% rule) have the value unequal to zero. Please read the reference before getting into the code.

2. `Descs` which contains the descriptor for each keypoint.


**Fig. 1**- a sample result of the algorithm

<img src="1.jpg" width=600>


### **References**
- •	D.G. Lowe, "Distinctive Image Features from Scale-Invariant Keypoints," International Journal of Computer Vision, 2004
