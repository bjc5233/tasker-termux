#!/bin/bash
# 说明
#   图片处理, 对图片一个矩形区域进行模糊处理, 处理后的图片作为手机壁纸对于图标显示友好
# 参考
#   https://imagemagick.org/script/command-line-options.php
# 参数
#   [-x coverCentreXPercent] [-y coverCentreYPercent] [-w coverWidthPercent] [-h coverHeightPercent] [-r coverRound] [-b coverBlur] [-o outPath] imgPath
#       coverCentreXPercent     - cover中心点在水平方向位置(百分比); 值为coverWidthPercent/2时, cover处于左边界; 值为1-coverWidthPercent/2时, cover处于右边界
#       coverCentreYPercent     - cover中心点在垂直方向位置(百分比); 值为coverHeightPercent/2时, cover处于上边界; 值为1-值为coverHeightPercent/2时, cover处于下边界
#       coverWidthPercent       - cover图宽度(百分比); 取值范围[0-1]
#       coverHeightPercent      - cover图高度(百分比); 取值范围[0到1-coverPositionPercent][剩余的0.0365是图片底部留白][0.009]
#       coverRound              - cover圆角值
#       outPath                 - 处理后图片地址
#       imgPath                 - 原始图片地址
# external
#   date       2019-09-06 22:45:44
#   face       →_→
#   weather    Shanghai Cloudy 25℃
# 备注
#   bash /sdcard/software_me/tasker/termux/imgRectBlur.sh /sdcard/software_me/壁纸/2017-08-07.jpg
#   bash         /mnt/c/path/tasker/termux/scripts/imgRectBlur.sh /mnt/c/path/tasker/termux/scripts/1.jpg
# TODO
#   参数范围检测
# ========================= init =========================
coverCentreXPercent=0.5
coverCentreYPercent=0.86555
coverWidthPercent=0.75
coverHeightPercent=0.251
coverRound=20
coverBlur=85
basePath=`dirname $BASH_SOURCE`
outPath="$basePath/imgRectBlur.jpg"
while getopts ":x:y:w:h:r:b:o:" opt; do
  case $opt in
    x) coverCentreXPercent=$OPTARG ;;
    y) coverCentreYPercent=$OPTARG ;;
    w) coverWidthPercent=$OPTARG ;;
    h) coverHeightPercent=$OPTARG ;;
    r) coverRound=$OPTARG ;;
    b) coverBlur=$OPTARG ;;
    o) outPath=$OPTARG ;;
    ?) echo "USAGE<`basename $BASH_SOURCE`>: [-x coverCentreXPercent] [-y coverCentreYPercent] [-w coverWidthPercent] [-h coverHeightPercent] [-r coverRound] [-b coverBlur] [-o outPath] imgPath"
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



# ========================= union =========================
coverWidth=`echo "$imgWidth*$coverWidthPercent"|bc`
coverHeight=`echo "$imgHeight*$coverHeightPercent"|bc`
coverPosX=`echo "$imgWidth*$coverCentreXPercent-$coverWidth/2"|bc`
coverPosY=`echo "$imgHeight*$coverCentreYPercent-$coverHeight/2"|bc`
# echo "=> cover切割信息: $coverWidth"x"$coverHeight+$coverPosX+$coverPosY"
coverPath="$basePath/imgRectBlurCover.png"
convert "$imgPath" \
        -crop "$coverWidth"x"$coverHeight!+$coverPosX+$coverPosY" \
        -blur 0x$coverBlur \
        \( +clone -alpha extract -draw "fill black polygon 0,0 0,$coverRound $coverRound,0 fill white circle $coverRound,$coverRound $coverRound,0" \
            \( +clone -flip \) -compose Multiply -composite \
            \( +clone -flop \) -compose Multiply -composite \
        \) \
        -alpha off -compose CopyOpacity -composite "$coverPath"
convert "$imgPath" -compose over "$coverPath" -geometry +$coverPosX+$coverPosY -composite "$outPath"
# echo "=> `basename $BASH_SOURCE`处理完成: $outPath"
echo "$outPath"
# ========================= union =========================