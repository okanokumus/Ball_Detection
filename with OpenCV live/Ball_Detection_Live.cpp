// Ball_Detection_Live.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <vector>
#include <opencv2\objdetect\objdetect.hpp>
#include <opencv2\highgui\highgui.hpp>
#include <opencv2\imgproc\imgproc.hpp>

using namespace std;
using namespace cv;

int main(){

	Mat img_rgb, img_hsv, img_gray;
	Mat h_and_s, h_and_s_and_v, h_and_s_and_v_erosion, h_and_s_and_v_dilation; // for bitwise operator
	Mat filter_h, filter_s, filter_v; // filter will be obtained after applied threshold to the saturation channel of hsv
	vector <Mat> channels_hsv; // hold the hue, saturation and intensity

	VideoCapture cap(0); // open the webcam
	if (!cap.isOpened())  // check if we succeeded
		return -1;

	namedWindow("CAMERA", 1);

	for (;;)
	{
		cap >> img_rgb; // get a new frame from camera
		double m = img_rgb.rows;
		double n = img_rgb.cols;
		vector <Point2i> CCpoints;
		// [m n] represents the size of the image
		cvtColor(img_rgb, img_gray, CV_RGB2GRAY);
		cvtColor(img_rgb, img_hsv, COLOR_RGB2HSV); // convert rgb to hsv space
		split(img_hsv, channels_hsv); // Divides a multi-channel array into several single-channel arrays.

        // apply threhold to the all component of hsv image
		threshold(channels_hsv[0], filter_h, 90, 255, THRESH_BINARY);
		threshold(channels_hsv[1], filter_s, 150, 255, THRESH_BINARY);
		threshold(channels_hsv[2], filter_v, 125, 255, THRESH_BINARY);

		bitwise_and(filter_h, filter_s, h_and_s);
		bitwise_and(h_and_s, filter_v, h_and_s_and_v);
		
		// apply morphological operator to the image
		// remove any small blobs that my be left on the mask.
		// first: erosion and after that dilation
		Mat element = getStructuringElement(MORPH_ELLIPSE, Size(7, 7));
		erode(h_and_s_and_v, h_and_s_and_v_erosion, element);

		medianBlur(h_and_s_and_v_erosion, h_and_s_and_v_erosion, 7);
		Mat labels, stats, centroids;
		int N = connectedComponentsWithStats(h_and_s_and_v_erosion, labels, stats, centroids, 8, CV_32S);
		//cout << N<<endl; // number of connected components (background is included)
		//cout << centroids <<endl; // center of CC include background
		
		if (N != 1) { // dor discard background as CC
			for (int i = 1; i < N; i++) { // for CCs (exclude background)

				drawMarker(img_rgb, Point2i(int(centroids.at<double>(i, 0)), int(centroids.at<double>(i, 1))), Scalar(255, 0, 0), 0, 5, 2, 2);
			}
		}

		/*
		Moments oMoments = moments(h_and_s_and_v_erosion);
		double dM01 = oMoments.m01;
		double dM10 = oMoments.m10;
		double dArea = oMoments.m00;
		//cout << dArea<<endl;
		// cout << dArea<<endl;// if there is a ball dArea will be grater that at least 3000
		if (dArea > 5000){
			//calculate mass center position of the ball
			int posX = dM10 / dArea;
			int posY = dM01 / dArea;
			drawMarker(img_rgb, Point2i(posX, posY), Scalar(255, 0, 0), 0, 5, 2, 2);
		}*/
		imshow("CAMERA", img_rgb);
		if (waitKey(30) >= 0) break;

		
	}
	return 0;
}

/* BACKGROUND
HUE:
channels[0] -> hue
channels[1] -> saturation
channels[2] -> intensity
*/