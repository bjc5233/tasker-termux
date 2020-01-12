#!/bin/bash
# 说明
#   获取图片主色
# 参考
#   https://imagemagick.org/script/command-line-options.php
# 参数
#   [-f format] imgPath
#       format  - 输出颜色格式, 0表示分段10进制[255,255,255]; 2表示组合10进制[FFFFFF]; 3表示16进制[FFFFFF]
#       imgPath - 原始图片地址
# external
#   date       2019-09-10 16:03:08
#   face       ●︿●
#   weather    Shanghai Cloudy 28℃
# 备注
#   bash /sdcard/software_me/tasker/termux/imgDominantColor.sh /sdcard/software_me/壁纸/2017-08-07.jpg
#   bash         /mnt/c/path/tasker/termux/scripts/imgDominantColor.sh /mnt/c/path/tasker/termux/scripts/1.jpg
# ========================= init =========================
format=0
while getopts ":f:" opt; do
  case $opt in
    f) format=$OPTARG ;;
    ?) echo "USAGE<`basename $BASH_SOURCE`>: [-f format] imgPath"
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
# ========================= init =========================


#========================= process =========================
toHex(){
    hexValue=`echo "obase=16;${1}"|bc`
    hexValue2=`echo ${#hexValue}`
    if [ $hexValue2 -lt 2 ]
    then
        hexValue="0${hexValue}"
    fi
    echo $hexValue
}


rgbColor=`convert $imgPath -scale 1x1 -format %[pixel:u] info:-`
rgbColor=${rgbColor#*srgb(}
rgbColor=${rgbColor%%)*}
if [ $format -eq 0 ]; then
    echo "$rgbColor"
    exit 0
fi

rgbColorArray=(${rgbColor//,/ })
rgbColorHex0=`toHex ${rgbColorArray[0]}`
rgbColorHex1=`toHex ${rgbColorArray[1]}`
rgbColorHex2=`toHex ${rgbColorArray[2]}`
rgbColorHex="${rgbColorHex0}${rgbColorHex1}${rgbColorHex2}"
if [ $format -eq 1 ]; then
    # 16进制格式 ddddff
    echo "$rgbColorHex"
elif [ $format -eq 2 ]; then
    # 原FFFFFF->-1; 原000000->-16777216
    # 目前已知nova配置文件中颜色字段[folder_window_config]使用该方式
    rgbColor2=`echo "ibase=16;$rgbColorHex-FFFFFF-1"|bc`
    echo "$rgbColor2"
fi
#========================= process =========================