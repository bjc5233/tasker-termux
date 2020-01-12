#!/bin/bash
# 说明
#   生成带色卡(调色板)的图片
# 参考
#   https://www.imagemagick.org/Usage/canvas/
#   http://www.fmwconcepts.com/imagemagick/index.php
#   https://imagemagick.org/script/command-line-options.php
#   https://unix.stackexchange.com/questions/407449/create-palette-image-with-multiple-rows-using-imagemagick
#   https://stackoverflow.com/questions/26889358/generate-color-palette-from-image-with-imagemagick
#   https://tuchong.com/1535376/t/21456512/
# 参数
#   [-s palettePosStyle] [-S paletteCentreStyle] [-x paletteCentreXPercent] [-y paletteCentreYPercent] [-n paletteBlockNum] [-r cornerRound] [-p backPadding] [-d drawColorStr] [-D drawColorStrSize] [-o outPath] imgPath
#       palettePosStyle         - 调色板位置; 0图片内部, 1图片上, 2图片下, 3图片左, 4图片右; 默认0
#       paletteCentreStyle      - 调色板排放方向; 0根据图片宽高选择, 1水平排放, 2垂直排放; 默认0
#       paletteCentreXPercent   - 调色板中心点在水平方向位置(百分比); 默认0.5
#       paletteCentreYPercent   - 调色板中心点在垂直方向位置(百分比); 默认0.5
#       paletteBlockNum  - 调色板颜色数量; 默认5
#       cornerRound      - 生成图片的圆角值; 默认0, 常用值40
#       backPadding      - 生成图片的白色边框宽度; 默认0, 常用值30
#       drawColorStr     - 调色板颜色中是否显示颜色代码文字; 0不显示, 1显示; 默认0
#       drawColorStrSize - 调色板颜色代码文字字号; 默认20
#       outPath          - 处理后图片地址
#       imgPath          - 原始图片地址
# external
#   date       2019-12-02 06:57:02
#   face       ^ω^
#   weather    Shanghai Sunny 5℃
# 备注
#   bash /sdcard/software_me/tasker/termux/imgColorPalette.sh /sdcard/software_me/壁纸/2017-08-07.jpg
#   bash         /mnt/c/path/tasker/termux/scripts/imgColorPalette.sh /mnt/c/path/tasker/termux/scripts/1.jpg
#   bash         /mnt/c/path/tasker/termux/scripts/imgColorPalette.sh -s0 -r40 -p30 -d1 /mnt/c/path/tasker/termux/scripts/4.jpg
# ========================= init =========================
palettePosStyle=0
paletteCentreStyle=0
paletteCentreXPercent=0.5
paletteCentreYPercent=0.5
paletteBlockNum=5
cornerRound=0
backPadding=0
drawColorStr=0
drawColorStrSize=20
basePath=`dirname $BASH_SOURCE`
outPathPalette="$basePath/imgColorPaletteColor.png"
outPath="$basePath/imgColorPalette.png"
while getopts ":s:S:x:y:n:r:p:d:D:o:" opt; do
  case $opt in
    s) palettePosStyle=$OPTARG ;;
    S) paletteCentreStyle=$OPTARG ;;
    x) paletteCentreXPercent=$OPTARG ;;
    y) paletteCentreYPercent=$OPTARG ;;
    n) paletteBlockNum=$OPTARG ;;
    r) cornerRound=$OPTARG ;;
    p) backPadding=$OPTARG ;;
    d) drawColorStr=$OPTARG ;;
    D) drawdrawColorStrSize=$OPTARG ;;
    o) outPath=$OPTARG ;;
    ?) echo "USAGE<`basename $BASH_SOURCE`>: [-s palettePosStyle] [-S paletteCentreStyle] [-x paletteCentreXPercent] [-y paletteCentreYPercent] [-n paletteBlockNum] [-r cornerRound] [-p backPadding] [-d drawColorStr] [-D drawdrawColorStrSize] [-o outPath] imgPath"
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
imgResult=(`identify -format "%w %h" $imgPath`)
imgWidth=${imgResult[0]}  imgHeight=${imgResult[1]}
# echo "=> 原始图片地址: $imgPath   宽高: $imgWidth"x"$imgHeight"
# ========================= init =========================



#========================= colors =========================
imgResult=(`identify -format "%w %h" $imgPath`)
imgWidth=${imgResult[0]}  imgHeight=${imgResult[1]}
colorsHex=`convert $imgPath -colorspace LAB -colors $paletteBlockNum -format %c histogram:info:- | sort -n -r | awk -F "[#|srgb]" '{print $2}'`
colorsHexStr=`echo "$colorsHex" | awk '{print "xc:#"$1}'`
#========================= colors =========================


#========================= function =========================
function GenerateColorPalette() {
    if [ $1 -eq 1 ]; then   #palette水平排放
        convert -size "$paletteBlockWidth"x"$paletteBlockHeight" $colorsHexStr +append $outPathPalette
    elif [ $1 -eq 2 ]; then #palette水平排放
        convert -size "$paletteBlockWidth"x"$paletteBlockHeight" $colorsHexStr -append $outPathPalette
    else
        return
    fi
    
    if [ $drawColorStr -eq 0 ]; then
        return
    fi
    annotateStr=''; annotateIndex=0
    if [ $1 -eq 1 ]; then   #文字水平排放
        for colorTemp in $colorsHex; do
            posXTemp=`echo "$annotateIndex*$paletteBlockWidth"|bc`; ((annotateIndex++));
            annotateStr=$annotateStr"-annotate +"$posXTemp"+0 $colorTemp "
        done
    elif [ $1 -eq 2 ]; then #文字垂直排放
        for colorTemp in $colorsHex; do
            posYTemp=`echo "$annotateIndex*$paletteBlockHeight"|bc`; ((annotateIndex++));
            annotateStr=$annotateStr"-annotate +0+"$posYTemp" $colorTemp "
        done
    else
        return
    fi
    convert $outPathPalette -gravity center -fill white -pointsize $drawColorStrSize $annotateStr $outPathPalette
}
#========================= function =========================




#========================= append =========================
if [ $palettePosStyle -eq 0 ]; then    #palette在图片内
    if [ $paletteCentreStyle -eq 0 ]; then    #根据图片宽高自动设置排放方向
        if [ $imgWidth -gt $imgHeight ]; then
            paletteCentreStyle=1   #palette水平排放
        else
            paletteCentreStyle=2   #palette垂直排放
        fi
    fi
    if [ $paletteCentreStyle -eq 1 ]; then #palette水平排放
        paletteBlockWidth=`echo "scale=4;$imgHeight/10"|bc`; paletteBlockHeight=$paletteBlockWidth
        GenerateColorPalette 1
    elif [ $paletteCentreStyle -eq 2 ]; then #palette垂直排放
        paletteBlockWidth=`echo "scale=4;$imgWidth/10"|bc`; paletteBlockHeight=$paletteBlockWidth
        GenerateColorPalette 2
    fi
    imgResult=(`identify -format "%w %h" $outPathPalette`)
    paletteWidth=${imgResult[0]}  paletteHeight=${imgResult[1]}
    palettePosX=`echo "$imgWidth*$paletteCentreXPercent-$paletteWidth/2"|bc`; palettePosY=`echo "$imgHeight*$paletteCentreYPercent-$paletteHeight/2"|bc`
    convert $imgPath -compose over $outPathPalette -geometry +$palettePosX+$palettePosY -composite $outPath
    
elif [ $palettePosStyle -eq 1 ]; then    #palette在图片上
    paletteBlockWidth=`echo "scale=4;$imgWidth/$paletteBlockNum"|bc`; paletteBlockHeight=`echo "scale=4;$imgHeight/8"|bc`
    GenerateColorPalette 1
    convert $outPathPalette $imgPath -append $outPath
elif [ $palettePosStyle -eq 2 ]; then    #palette在图片下
    paletteBlockWidth=`echo "scale=4;$imgWidth/$paletteBlockNum"|bc`; paletteBlockHeight=`echo "scale=4;$imgHeight/8"|bc`
    GenerateColorPalette 1
    convert $imgPath $outPathPalette -append $outPath
elif [ $palettePosStyle -eq 3 ]; then    #palette在图片左
    paletteBlockWidth=`echo "scale=4;$imgWidth/2"|bc`; paletteBlockHeight=`echo "scale=4;$imgHeight/$paletteBlockNum"|bc`
    GenerateColorPalette 2
    convert $outPathPalette $imgPath +append $outPath
elif [ $palettePosStyle -eq 4 ]; then    #palette在图片右
    paletteBlockWidth=`echo "scale=4;$imgWidth/2"|bc`; paletteBlockHeight=`echo "scale=4;$imgHeight/$paletteBlockNum"|bc`
    GenerateColorPalette 2
    convert $imgPath $outPathPalette +append $outPath
fi
#========================= append =========================


#========================= roundCorner =========================
if [ $cornerRound -gt 0 ]; then
    convert $outPath \
            \( +clone -alpha extract -draw "fill black polygon 0,0 0,$cornerRound $cornerRound,0 fill white circle $cornerRound,$cornerRound $cornerRound,0" \
                \( +clone -flip \) -compose Multiply -composite \( +clone -flop \) -compose Multiply -composite \
            \) \
            -alpha off -compose CopyOpacity -composite $outPath
fi
#========================= roundCorner =========================


#========================= padding =========================
if [ $backPadding -gt 0 ]; then
    imgResult=(`identify -format "%w %h" $outPath`)
    imgWidth=${imgResult[0]}  imgHeight=${imgResult[1]}
    backWidth=`echo "$imgWidth+$backPadding*2"|bc`; backHeight=`echo "$imgHeight+$backPadding*2"|bc`
    convert -size "$backWidth"x"$backHeight" xc:"#FFFFFF" -compose over $outPath -geometry +$backPadding+$backPadding -composite $outPath
fi
#========================= padding =========================
