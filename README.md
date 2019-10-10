# tasker-termux
> 用于与termux交互的项目。主要用于图片处理设置壁纸，可以执行按分辨率裁剪、氢壁纸、特定区域模糊、整体模糊、图片主色提取等


### 使用方法
1. 安装tasker、termux
2. 在termux中安装imagemagick
3. 在tasker中，导入tasker项目[termux.prj.xml]；导入项目使用到的公共任务[comm_random_img.tsk.xml]
4. 在tasker中，打开任务[termuxComm]修改全局变量[%TERMUX_BASE_PATH]为自己的路径，并将所有脚本文件[scripts\*.*]放入这个路径
5. 在tasker中，打开任务[comm-random-img]修改局部变量[%imags_paths]为自己的壁纸路径
6. 执行图片处理任务。eg: 执行[termuxRectBlur]任务会进行如下动作：a.通过[comm-random-img]获取一张随机图片; b.通过[imgRatioCrop.sh]脚本对图片进行裁剪; c.通过[imgRectBlur.sh]脚本对图片指定区域模糊处理; d.将处理后的图片设置为桌面壁纸



### 脚本说明
|脚本|功能|
|-|-|
|imgBlur.sh|整体模糊|
|imgDominantColor.sh|图片主色提取|
|imgHO.sh|氢壁纸(底图为模糊后的原图)|
|imgHO2.sh|氢壁纸(底图为原图主色调)|
|imgParallelogram.sh|除特定倾斜四边形区域外模糊处理<br>(在ubuntu上执行成功，但在魅族16上执行失败，可能某些系统函数不支持)|
|imgRatioCrop.sh|按分辨率裁剪|
|imgRectBlur.sh|特定区域模糊|
|pyWebServer.py|启动termux中python-flask的Web服务器|


### 演示
|imgRectBlur.sh|imgParallelogram.sh|
|-|-|
|<img src="https://github.com/bjc5233/tasker-termux/raw/master/resources/demo1.png"/>|<img src="https://github.com/bjc5233/tasker-termux/raw/master/resources/demo2.jpg"/>|

|imgHO.sh|imgHO2.sh|
|-|-|
|<img src="https://github.com/bjc5233/tasker-termux/raw/master/resources/demo3.jpg"/>|<img src="https://github.com/bjc5233/tasker-termux/raw/master/resources/demo4.jpg"/>|