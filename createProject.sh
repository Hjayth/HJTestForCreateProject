#!/bin/bash

if [ -z "$1" ];then
echo "you should use this shell like this - ""create.sh [your project name]" " please input parameter"
exit
else

    echo $1
    #clone 远程基项目
    git clone  git@github.com:Hjayth/HJTestForCreateProject.git $1
        if [ $?  -eq 0 ]
        then
            cd $1
#运行配置脚本
            echo " this is the test for $1:" $1
            ./configure $1
            echo "configure your project...."
        else
            echo "your remote repository is not available"
            exit 1
        fi

fi

exit 0
