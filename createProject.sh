#!/bin/bash

#if [ -z "$1" ];then
# echo "please input parameter"
#exit
#else

    echo $1
# Repository_name = "$1"
    echo $Repository_name
# mkdir $1
#  cd $1
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

#fi

exit 0
