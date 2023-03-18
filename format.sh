#!/bin/bash
awk 'BEGIN{print "区域\t\t\tIP地址\t\t设备类型\t详细信息"}' /root/xiutan/mail.txt
awk '/监控设备/{print $1"\t\t"$2"\t"$3"\t\t"$4}' /root/xiutan/mail.txt
awk '/多媒体报警柱/{print $1"\t"$2"\t"$3"\t"$4}' /root/xiutan/mail.txt
awk '/wifi嗅探/{print $1"\t"$2"\t"$3"\t"$4}' /root/xiutan/mail.txt
awk '!/(监控设备|多媒体报警柱|wifi嗅探)/{print $1"\t"$2"\t"$3"\t\t"$4}' /root/xiutan/mail.txt
