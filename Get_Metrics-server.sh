#!/bin/env bash
# 脚本文件名:    Get_Metrics-server.sh
# 脚本功能:      下载metrics-server yaml文件并应用
# 脚本版本:      1.0
# 编写日期:      2019/11/15
# 作者：         杜秋
# 作者邮箱:      duqiu521@sina.cn
# 作者微信公众号: 运维及时雨

mkdir - p  metrics-server-1.8+
cd metrics-server-1.8+

URL=https://raw.githubusercontent.com/kubernetes-sigs/metrics-server/master/deploy/1.8%2B/

for f in aggregated-metrics-reader.yaml auth-delegator.yaml auth-reader.yaml metrics-apiservice.yaml  metrics-server-deployment.yaml  metrics-server-service.yaml resource-reader.yaml
    do
       wget  ${URL}${f}
    done
