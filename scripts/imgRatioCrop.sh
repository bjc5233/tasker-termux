#!/bin/bash
# 说明
#   图片处理, 对图片按照比例切割
# 参考
#   https://imagemagick.org/script/command-line-options.php
# 参数
#   [-w screenWidth] [-h screenHeight] [-o outPath] imgPath
#       screenWidth     - 屏幕宽度, 用于计算分辨率, 裁剪原图
#       screenHeight    - 屏幕高度, 用于计算分辨率, 裁剪原图
#       outPath         - 处理后图片地址
#       imgPath         - 原始图片地址
# external
#   date       2019-09-07 02:39:11
#   face       (^>﹏^<)
#   weather    Shanghai Cloudy 24℃
# 备注
#   bash /sdcard/software_me/tasker/termux/imgRatioCrop.sh /sdcard/software_me/壁纸/2017-08-07.jpg
#   bash         /mnt/c/path/tasker/termux/scripts/imgRatioCrop.sh /mnt/c/path/tasker/termux/scripts/1.jpg
# TODO
#   参数范围检测
# ========================= init =========================
screenWidth=1080
screenHeight=2160
basePath=`dirname $BASH_SOURCE`
outPath="$basePath/imgRatioCrop.jpg"
while getopts ":w:h:o:" opt; do
  case $opt in
    w) screenWidth=$OPTARG ;;
    h) screenHeight=$OPTARG ;;
    o) outPath=$OPTARG ;;
    ?) echo "USAGE<`basename $BASH_SOURCE`>: [-w screenWidth] [-h screenHeight] [-o outPath] imgPath"
       exit 1 ;;
  esac
done
shift $(($OPTIND - 1))
if [ -n "$1" ] && [ -r "$1" ]; then     # 变量存在且文件可读
    imgPath="$1"
else
    echo "img not exist"
    exit 1
fi
imgResult=(`identify -format "%w %h" "$imgPath"`)
imgWidth=${imgResult[0]}  imgHeight=${imgResult[1]}
# echo "=> 原始图片地址: $imgPath   宽高: $imgWidth"x"$imgHeight"
# ========================= init =========================



# ========================= crop =========================
# 以宽度为基准计算符合手机分辨率的高度值
imgWidthTemp=$imgWidth; imgHeightTemp=`echo "($screenHeight*$imgWidth)/$screenWidth"|bc`
imgCutX=0; imgCutY=`echo "($imgHeight-$imgHeightTemp)/2"|bc`
if [ $imgHeightTemp -ge $imgHeight ];then
    # 以高度为基准计算符合手机分辨率的宽度值
    imgWidthTemp=`echo "($screenWidth*$imgHeight)/$screenHeight"|bc`; imgHeightTemp=$imgHeight
    imgCutX=`echo "($imgWidth-$imgWidthTemp)/2"|bc`; imgCutY=0
fi


if [ $imgWidth -eq $imgWidthTemp ] && [ $imgHeight -eq $imgHeightTemp ];then
    outPath=$imgPath
    # echo "=> 图片符合分辨率, 不进行裁剪"
else
    imgWidth=$imgWidthTemp; imgHeight=$imgHeightTemp
    # echo "=> 按分辨率裁剪位置: $imgCutX,$imgCutY   宽高: $imgWidth"x"$imgHeight"
    # -crop Geometry{widthxheight!}{+-}x{+-}y  其中!表示忽略原图宽高比例
    convert "$imgPath" -crop "$imgWidth"x"$imgHeight!+$imgCutX+$imgCutY" "$outPath"
fi
# echo "=> `basename $BASH_SOURCE`处理完成: $outPath"
echo "$outPath"
# ========================= crop =========================