@echo off
echo "-------�����뱾�θ�������----------------"
set /p msg=
git add .
git commit -m "�ύ�޸� %msg%"
git pull
git push  origin source
echo "--------�ύ���--------------"
pause