-> Explanition about algorithm: My code uses the HSV space of the image and split it into 3 components such as H, S and V and then apply
a threshold value to get binary images of them. This threshold images anded using 'bitwise_and' and final image must include ball. 
Blurring and morphologic operators are applied beforo Connected Component analysis. You can see the result of the algorithm from 'result.png'
file.

-> For best result(less wrong choice of ball) you can add trackbar to control threshold value of the HSV components.

-> Algorithm depends on the color analysis and does not affect by moving object.

-> Dependencies:
* webcam
* visual studio 2015 (i have used precompiled header file instead of empty project)
* opencv 3.1.0

-> As a future works, I planned that less dependencies colors ad light intensities.
