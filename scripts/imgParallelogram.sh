#!/bin/bash
# 说明
#   图片处理, 除了指定的倾斜矩形区域外，其他区域进行模糊处理
# 参考
#   https://imagemagick.org/script/command-line-options.php
# 参数
#   [-y coverCentreYPercent] [-h coverHeightPercent] [-a coverAngle] [-b coverBlur] [-o outPath] imgPath
#       coverCentreYPercent - cover中心点在垂直方向位置(百分比); 当coverPoint1Y值为0时, cover处于上边界; 当coverPoint3Y值为imgHeight时, cover处于下边界
#       coverHeightPercent  - cover高度(百分比); 取值范围[0-1]
#       coverAngle          - 平行四边形角度值
#       coverBlur           - 底图模糊程度, 值越大花费的时间越长
#       outPath             - 处理后图片地址
#       imgPath             - 原始图片地址
# external
#   date       2019-09-11 12:55:09
#   face       -_-#
#   weather    Shanghai Sunny 31℃
# 备注
#   bash /sdcard/software_me/tasker/termux/imgParallelogram.sh /sdcard/software_me/壁纸/2017-08-07.jpg
#   bash         /mnt/c/path/tasker/termux/imgParallelogram.sh /mnt/c/path/tasker/termux/1.jpg
# TODO
#   参数范围检测
# ========================= init =========================
coverCentreYPercent=0.32
coverHeightPercent=0.3
coverAngle=30
coverBlur=60
basePath=`dirname $BASH_SOURCE`
outPath="$basePath/imgParallelogram.jpg"
while getopts ":y:h:a:b:o:" opt; do
  case $opt in
    y) coverCentreYPercent=$OPTARG ;;
    h) coverHeightPercent=$OPTARG ;;
    a) coverAngle=$OPTARG ;;
    b) coverBlur=$OPTARG ;;
    o) outPath=$OPTARG ;;
    ?) echo "USAGE<`basename $BASH_SOURCE`>: [-y coverCentreYPercent] [-h coverHeightPercent] [-a coverAngle] [-b coverBlur] [-o outPath] imgPath"
       exit 1 ;;
  esac
done
shift $(($OPTIND - 1))
if [ -n "$1" ] && [ -r "$1" ]; then     # 变量存在且文件可读
    imgPath="$1"
else
    exit 1
fi
imgResult=(`identify -format "%w %h" "$imgPath"`)
imgWidth=${imgResult[0]}  imgHeight=${imgResult[1]}
 echo "=> 原始图片地址: $imgPath   宽高: $imgWidth"x"$imgHeight"
# ========================= init =========================



#========================= process =========================
# 四个point坐标[右上, 左上, 左下, 右下]; bc -l支持角度计算
coverPoint1X=$imgWidth; coverPoint1Y=`echo "$imgHeight*$coverCentreYPercent-$imgHeight*$coverHeightPercent/2-a($coverAngle*4*a(1)/180)*$imgWidth/2"|bc -l`
coverPoint2X=0; coverPoint2Y=`echo "a($coverAngle*4*a(1)/180)*$imgWidth+($coverPoint1Y)"|bc -l`
coverPoint3X=0; coverPoint3Y=`echo "$coverPoint2Y+$imgHeight*$coverHeightPercent"|bc`
coverPoint4X=$imgWidth; coverPoint4Y=`echo "$coverPoint1Y+$imgHeight*$coverHeightPercent"|bc`
coverWidth=$imgWidth;coverHeight=`echo "$coverPoint3Y-($coverPoint1Y)"|bc`  # 多边形整体宽度 高度
coverPosX=0; coverPosY=$coverPoint1Y    #多边形在底图坐标
 echo "$coverPoint1X, $coverPoint1Y"
 echo "$coverPoint2X, $coverPoint2Y"
 echo "$coverPoint3X, $coverPoint3Y"
 echo "$coverPoint4X, $coverPoint4Y"
 echo "$coverWidth, $coverHeight"
 echo "$coverPosX, $coverPosY"
coverPath="$basePath/imgParallelogramCover.png"
# -alpha Transparent在魅族上疑似未生效
convert "$imgPath" \
        \( +clone -alpha Transparent -size "$imgWidth"x"$imgHeight" xc:white \
           -draw "fill black polygon $coverPoint1X,$coverPoint1Y $coverPoint2X,$coverPoint2Y $coverPoint3X,$coverPoint3Y $coverPoint4X,$coverPoint4Y" \
        \) \
        -crop "$coverWidth"x"$coverHeight!+$coverPosX+$coverPosY" \
        -alpha off -compose CopyOpacity -composite "$coverPath"
convert "$imgPath" -blur 0x$coverBlur \
                   -compose over "$coverPath" \
                   -geometry +$coverPosX+$coverPosY \
                   -composite "$outPath"
echo "$outPath"
#========================= process =========================