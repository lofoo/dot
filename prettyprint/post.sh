#!/bin/bash

# [ company_code,out_sid,session,tid]

app_secret=
app_key=
company_code=$1
format=json
method=taobao.logistics.online.send
out_sid=$2
session=610100888ded25cf1fcef2b22a7f2e91327917677667d9d1849144340
sign_method=md5
tid=$3
timestamp=`date  +"%Y-%m-%d %H:%M:%S"`
v=2.0


formatstr=${app_secret}app_key${app_key}company_code${company_code}format${format}method${method}out_sid${out_sid}session${session}sign_method${sign_method}tid${tid}timestamp${timestamp}v${v}${app_secret}
#echo $formatstr

md5=`echo -n ${formatstr} | md5sum | tr '[:lower:]' '[:upper:]' | sed 's/ \*-'//g`

curlurl="http://gw.api.taobao.com/router/rest"
curlparm=`echo -n sign\=${md5}\&timestamp\=${timestamp}\&v\=${v}\&app_key\=${app_key}\&sign_method\=${sign_method}\&method\=${method}\&session\=${session}\&format\=${format}\&company_code\=${company_code}\&out_sid\=${out_sid}\&tid\=${tid} | sed 's/ /+/g' | sed 's/:/%3A/g'`

#http://gw.api.taobao.com/router/rest?sign=B7DFEAE94AB09E2D1E1C7CE77DD70983&timestamp=2014-05-16+01%3A23%3A08&v=2.0&app_key=21787525&sign_method=md5&method=taobao.logistics.online.send&session=610100888ded25cf1fcef2b22a7f2e91327917677667d9d1849144340&format=json&company_code=TTKDEX&out_sid=560077304155&tid=653874199823650
curlstr="curl -d ${curlparm} ${curlurl}"
# echo $curlstr
RESPONSE=`$curlstr`
echo $RESPONSE


#echo company_code: $company_code
#echo out_sid: $out_sid
#echo session: $session
#echo tid: $tid


# VERSION=0.1.0
# SUBJECT=some-unique-id
# USAGE="Usage: command -hv args"

# # --- Option processing --------------------------------------------
# if [ $# == 0 ] ; then
#     echo $USAGE
#     exit 1;
# fi

# . ./shflags

# DEFINE_string 'aparam' 'adefault' 'First parameter'
# DEFINE_string 'bparam' 'bdefault' 'Second parameter'

# # parse command line
# FLAGS "$@" || exit 1
# eval set -- "${FLAGS_ARGV}"

# shift $(($OPTIND - 1))

# param1=$1
# param2=$2

# # --- Locks -------------------------------------------------------
# LOCK_FILE=/tmp/${SUBJECT}.lock



