#!/bin/bash
# 说明
#   图片处理, 对图片进行模糊处理
# 参考
#   https://imagemagick.org/script/command-line-options.php
# 参数
#   [-b blurNum] [-o outPath] imgPath
#       blurNum - 底图模糊程度, 值越大花费的时间越长
#       outPath - 处理后图片地址
#       imgPath - 原始图片地址
# external
#   date       2019-09-07 01:32:02
#   face       (ΘｏΘ)
#   weather    Shanghai Cloudy 24℃
# 备注
#   bash /sdcard/software_me/tasker/termux/imgBlur.sh /sdcard/software_me/壁纸/2017-08-07.jpg
#   bash         /mnt/c/path/tasker/termux/scripts/imgBlur.sh /mnt/c/path/tasker/termux/scripts/1.jpg
# TODO
#   参数范围检测
# ========================= init =========================
blurNum=27
basePath=`dirname $BASH_SOURCE`
outPath="$basePath/imgBlur.jpg"
while getopts ":b:o:" opt; do
  case $opt in
    b) blurNum=$OPTARG ;;
    o) outPath=$OPTARG ;;
    ?) echo "USAGE<`basename $BASH_SOURCE`>: [-b blurNum] [-o outPath] imgPath"
       exit 1 ;;
  esac
done
shift $(($OPTIND - 1))
if [ -n "$1" ] && [ -r "$1" ]; then     # 变量存在且文件可读
    imgPath="$1"
else
    exit 1
fi
# ========================= init =========================


# ========================= blur =========================
convert "$imgPath" -blur 0x$blurNum "$outPath"
# echo "=> `basename $BASH_SOURCE`处理完成: $outPath"
echo "$outPath"
# ========================= blur =========================