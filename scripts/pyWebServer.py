#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 说明
#   启动web服务器
# 参考
#   https://flask.palletsprojects.com/en/1.1.x/
#   https://blog.csdn.net/u014793102/article/details/80372815
# external
#   date       2019-09-07 19:02:50
#   face       (>_<)
#   weather    Shanghai Clear 28℃
# 其他
#   用命令行启动server时，在app.run中配置的参数无效，需要在flask run后增加参数
#   win:    set FLASK_APP=server.py 
#   win:    set FLASK_ENV=development
#   linux:  export FLASK_APP=/sdcard/software_me/tasker/termux/pyWebServer.py
#   linux:  export FLASK_ENV=development
#   flask run -h '0.0.0.0' -p 10000
from flask import Flask, request, send_from_directory
import subprocess
import os
app = Flask(__name__)


#建立路由，通过路由可以执行其覆盖的方法，可以多个路由指向同一个方法。
@app.route('/')
@app.route('/index')
def index():
    return "Hello, World!"
    
#用于检查连通性
@app.route('/ping', methods=['GET'])
def setPCClipFromMobile():
    return "pong"

  
# ahk[httpClient] -> termux -> python[WebServer] -> tasker[remoteCtlPC-setClip] -> ahk[httpServer] -> ahk[设置clip值]
@app.route('/clip', methods=['GET'])
def setPCClipFromMobile():
    return subprocess.call("am broadcast -a net.dinglisch.android.tasker.ACTION_TASK --es task_name 'remoteCtlPC-setClip'", shell=True)
@app.route('/clip', methods=['POST'])
def setMobileClipFromPC():
    return subprocess.call("am broadcast -a net.dinglisch.android.tasker.ACTION_TASK --es task_name 'remoteCtlPC-getClip'", shell=True)



# 下载文件
@app.route('/download', methods=['GET', 'POST'])
def downloadFileSetPath():
    filePath = None
    if request.method=='GET':
        filePath = request.args.get("path")
    elif request.method=='POST':
        filePath = request.form['path']
        
    if (filePath == None) or (filePath == ""):
        return "=> 请配置path参数"
    if not os.path.exists(filePath):
        return "=> 指定的文件不存在: " + filePath
        
    (fileDir, fileName) = os.path.split(filePath)
    return send_from_directory(fileDir, fileName, as_attachment=True, attachment_filename=fileName,)










if __name__=='__main__':
    app.run(host='0.0.0.0', port= 10000, debug=True)