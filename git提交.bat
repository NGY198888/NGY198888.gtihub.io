@echo off
echo "-------请输入本次更新描述----------------"
set /p msg=
git add .
git commit -m "提交修改 %msg%"
git pull
git push  origin source
echo "--------提交完成--------------"
pause