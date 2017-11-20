# Intrinsic Image

![](https://img.shields.io/badge/PyAMG-3.3.2-blue.svg?style=flat-square)
![](https://img.shields.io/badge/Matlab-2015a-green.svg?style=flat-square)  ![](https://img.shields.io/badge/Language-Mat%20|%20Python-yellowgreen.svg?style=flat-square) ![](https://img.shields.io/badge/Platform-Windows-lightgray.svg?style=flat-square)

## 1. Project Introduction

This project is the final project of course **Software Engineering** and **Computer Graphics**.

Functionality: takes a series of images of one object as input, this program could derive its **intrinsic image** (reflectance + shading).

<div align=center>
	<img src="https://i.imgur.com/7J7iH5P.png" width="600">
</div>


By utilizing **Matlab** and python's library **PyAMG**, the program is mainly written in **Mat** and **Python**.

## 2. Technique Details

This project primarily referenced the method in **Yair Weiss**'s paper [*Deriving intrinsic images from image sequences*](http://ieeexplore.ieee.org/document/937606/).

The derivation process is illustrated as follows:

1. Input the image sequences and normalize.
2. Calculate gradients of adjacent pixels horizontally and vertically.
3. Use the median to get estimates.
4. Solve a Possion equation on 2-D grid to get the result.


## 3. How To Use

### a. Environment Setting

Make sure you have already installed **Matlab** and **Python** on your equipment.

Required **Python** packages:

- python.numpy
- python.scipy
- python.pyamg

### b. Input and Output Path

Input:

    ./data/<case_name>/*.png

Output:

    ./output/<case_name>_*.png

### c. Run

Switch to root of this folder in **MATLAB**

    >> cd '...\<your_path>\Intrinsic Image'

Then input the following command will execute the program:

    >> intrinsic data_name

*\* Some intermediate files will be generated during the processing, never mind.*