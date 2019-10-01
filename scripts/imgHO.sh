#!/bin/bash
# 说明
#   图片处理, 将图片转为氢壁纸风格
# 参考
#   https://imagemagick.org/script/command-line-options.php
# 参数
#   [-x coverCentreXPercent] [-y coverCentreYPercent] [-w coverWidthPercent] [-h coverHeightPercent] [-b blurNum] [-o outPath] imgPath
#       coverCentreXPercent - cover中心点在水平方向位置(百分比); 值为coverWidthPercent/2时, cover处于左边界; 值为1-coverWidthPercent/2时, cover处于右边界
#       coverCentreYPercent - cover中心点在垂直方向位置(百分比); 值为coverHeightPercent/2时, cover处于上边界; 值为1-值为coverHeightPercent/2时, cover处于下边界
#       coverWidthPercent   - cover宽度(百分比); 取值范围[0-1]
#       coverHeightPercent  - cover高度(百分比); 取值范围[0-1]
#       blurNum             - 底图模糊程度, 值越大花费的时间越长
#       outPath             - 处理后图片地址
#       imgPath             - 原始图片地址
# external
#   date       2019-09-06 22:50:04
#   face       (=^.^=)
#   weather    Shanghai Cloudy 25℃
# 备注
#   bash /sdcard/software_me/tasker/termux/imgHO.sh /sdcard/software_me/壁纸/2017-08-07.jpg
#   bash         /mnt/c/path/tasker/termux/imgHO.sh /mnt/c/path/tasker/termux/1.jpg
# TODO
#   参数范围检测
# ========================= init =========================
coverCentreXPercent=0.5
coverCentreYPercent=0.2
coverWidthPercent=0.9
coverHeightPercent=0.3
blurNum=70
basePath=`dirname $BASH_SOURCE`
outPath="$basePath/imgHO.jpg"
while getopts ":x:y:w:h:b:o:" opt; do
  case $opt in
    x) coverCentreXPercent=$OPTARG ;;
    y) coverCentreYPercent=$OPTARG ;;
    w) coverWidthPercent=$OPTARG ;;
    h) coverHeightPercent=$OPTARG ;;
    b) blurNum=$OPTARG ;;
    o) outPath=$OPTARG ;;
    ?) echo "USAGE<`basename $BASH_SOURCE`>: [-x coverCentreXPercent] [-y coverCentreYPercent] [-w coverWidthPercent] [-h coverHeightPercent] [-b blurNum] [-o outPath] imgPath"
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
# echo "=> 原始图片地址: $imgPath   宽高: $imgWidth"x"$imgHeight"
# ========================= init =========================




#========================= process =========================
coverWidth=`echo "$imgWidth*$coverWidthPercent"|bc`
coverHeight=`echo "$imgHeight*$coverHeightPercent"|bc`
coverPosX=`echo "$imgWidth*$coverCentreXPercent-$coverWidth/2"|bc`
coverPosY=`echo "$imgHeight*$coverCentreYPercent-$coverHeight/2"|bc`
imgHOCoverPath="$basePath/imgHOCover.png"
convert "$imgPath" -crop "$coverWidth"x"$coverHeight!+$coverPosX+$coverPosY" \
                         -alpha set \( +clone -background black -shadow 60x20+20+20 \) \
                         +swap -background none -mosaic "$imgHOCoverPath"
convert "$imgPath" -blur 0x$blurNum \
                         -compose over "$imgHOCoverPath" \
                         -geometry +$coverPosX+$coverPosY \
                         -composite "$outPath"
# echo "=> `basename $BASH_SOURCE`处理完成: $outPath"
echo "$outPath"
#========================= process =========================