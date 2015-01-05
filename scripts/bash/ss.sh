#source /C/MinGW/msys/1.0/etc/profile
HOME="/c/Users/me"
#cd ~/.config/ssocks
#screen -d -m sslocal
#screen -d -m ping -t 192.168.1.120


#rm -rf /tmp/tmux-*/
#tmux new -s ssocks -d
#tmux send-keys -t ssocks 'cd ~/.config/ssocks' C-m
#tmux send-keys -t ssocks 'sslocal' C-m

# cd ~/.config/ssocks
# sslocal


#while true
#do
#
#uuport=$RANDOM
#pkill -9 ssocks
#curl -4 -G -v "http://ikicks.me/" --data-urlencode "static=cd /root/ssocks&&sed -i \"s/\\\"server_port\\\":.*/\\\"server_port\\\":$uuport,/\" config.json;pkill -9 node  ; screen -d -m ssserver   ; ssserver -c config.json.static"    > /dev/null
#curl -4 -G -v "http://2.ikicks.me/" --data-urlencode "static=cd /root/ssocks&&sed -i \"s/\\\"server_port\\\":.*/\\\"server_port\\\":$uuport,/\" config.json;pkill -9 node; screen -d -m ssserver   ; ssserver -c config.json.static"    > /dev/null
#if [ $? -ne 0 ]; then
#    echo $?
#    echo "ERROR!"
#else
	# cd ~/.config/ssocks/
	cd ~/.config/ssocks/
#	sed -i "s/\"server_port\":.*/\"server_port\":$uuport,/" config.json
	sslocal&
#
	# cd ~/.config/ssocks/dg/
	cd ~/.config/ssocks/dg/
#	sed -i "s/\"server_port\":.*/\"server_port\":$uuport,/" config.json
	sslocal&
	cd ..
#
	# cd ~/.config/ssocks/ec2/
	cd ~/.config/ssocks/ec2/
	sslocal&
	cd ..

	cd ~/.config/ssocks/evm/
	sslocal&
	cd ..
#	sleep 3600
#fi

#done
