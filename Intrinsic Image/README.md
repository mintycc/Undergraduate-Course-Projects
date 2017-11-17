## 运行步骤 ##
首先在 MATLAB 中打开 project 的根目录

    >> cd '...\Intrinsic Image'

然后输入

    >> intrinsic data_name

#####其中 data_name 为 /data 中的文件夹名(apple, box, cup1, ...)

python文件 get_amg.py 将被自动调用

## 需要环境 ##
- python.numpy
- python.scipy
- python.pyamg

## 文件说明 ##
> intrinsic.m 

主文件
> *.m 

MATLAB 各函数

> get_amg.py

python 文件，讲在intrinsic的执行过程中自动被调用

> /data

输入文件夹

> /output

输出文件夹

## 输入输出文件 ##

（根据执行时输入的 'data_name'）

输入文件为

    ./data/<data_name>/*.png

输出文件为

    ./output/<data_name>_*.png

## 另外一些说明 ##

程序在执行过程中将会自动生成一些 txt 文件， 无须在意