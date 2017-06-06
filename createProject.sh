#!/bin/bash

#if [ -z "$1" ];then
# echo "please input parameter"
#exit
#else
    echo $Repository_name
    #clone 远程基项目
    git clone  git@github.com:Hjayth/HJTestForCreateProject.git $1
        if [ $?  -eq 0 ]
        then
            cd $1
#运行配置脚本

            echo "create and configure your project...."
            ./configure $1
            echo "compelete create and configure your project"
        else
            echo "your remote repository is not available"
            exit 1
        fi

#fi

exit 0
