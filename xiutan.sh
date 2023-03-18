#!/bin/bash

#定义运行路径
path=/root/xiutan/

#清理jg.txt的内容
> ${path}jg.txt
#清理mail.txt的内容
> ${path}mail.txt
#清理mail_format.txt的内容
> ${path}mail_format.txt
#清理modify.txt的内容
> ${path}modify.txt


#创建sc函数
sc(){
#初始化cg为0
cg=0
#创建for循环，循环三次
for l in $(seq 3)
#循环的代码块开始
do
	#使用ping检测目标存活性，每次循环ping3次，三次循环9次，每次ping间隔为1秒，超过1秒为超时，ip为传入函数的值
	ping -c 3 -i 0.3 -W 1 $1 |grep ttl &>/dev/null
	#条件判断，如果上一条命令执行成功，也就是3次都ping通，那么就执行条件判断内语句，否则跳过
	if [ $? == 0 ]
	#条件判断代码块
	then
		#cg变量在上一条命令执行成功时+1
		let cg++
	fi
	#条件判断代码块结束
done
#循环的代码块结束

#条件判断，如果cg变量大于了0，不包括0，那么执行代码块语句
if [ $cg -gt 0 ]
#条件判断代码块开始
then
	#在上面循环内，只要ping成功一次那么cg就会+1，也就是说只要ping通一次就代表存活，这里就会输出空字符，形成空行
	echo
else
	#cg如果是0那就代表本次执行函数一次都没ping通，会把传入函数的值再通过标准输出传出去
	grep -w $1 ${path}ip.txt
fi
#条件判断代码块结束

}
#函数代码块结束

#for循环调用ip.txt的第二列，以空格为区分，有多少行就会执行多少次，每次循环就是每行的值
for i in $(awk '{print $2}' ${path}ip.txt)
#循环代码块开始
do
	#调用函数传参数，传入当前行的IP地址给SC函数，也就是把i变量交给sc函数处理，sc函数会返回一个值，ping9次有一次通就会返回空行给jg.txt文件，一次不通返回IP地址/i变量本身给jg.txt
	sc $i >> ${path}jg.txt
done
#循环代码块结束

#去除空行生成新文件
cat ${path}jg.txt |grep -Ev "(^$)" > ${path}mail.txt

#格式化输出生成新文件
${path}format.sh > ${path}mail_format.txt

#检测今天和昨天的内容有什么不同

#每天检测完毕后把jintian.txt内容备份到zuotian.txt等下做比较
cat ${path}jintian.txt > ${path}zuotian.txt
#过滤mail_format.txt的第二行ip地址存为新文件jintian.txt，会覆盖掉旧内容
awk '{print $2}' ${path}mail_format.txt |egrep "[0-9]|\." > ${path}jintian.txt
#输出介绍追加到modify.txt
awk 'BEGIN{print "数字行号，a新增 >，c修改 <修改前内容---修改后内容>，d删除 <，下方无内容则无修改"}' >> ${path}modify.txt
#比较两个文件有什么不同，追加到modify.txt
diff ${path}zuotian.txt ${path}jintian.txt >> ${path}modify.txt

#检测文件是否有内容，会有0（有内容）或者非0（没有内容）的返回值
grep -E [1-9] ${path}mail_format.txt &>/dev/null
#如果返回值为0，代表文件有内容，则执行代码块的内容，非0则跳过
if [ $? == 0 ]
then
	cat ${path}mail_format.txt ${path}modify.txt | mailx -s "oreo 掉线设备" 735136490@qq.com
fi
