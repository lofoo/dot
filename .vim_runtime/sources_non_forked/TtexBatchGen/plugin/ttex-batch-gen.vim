function! TtexBatchGen()
  set nomore
  set nowrapscan
  normal gg
  let v:errmsg = "0"
  let s:order  =  1 
  normal qyq
  e index_template.html
  normal ggVG"ty
  bd

  let s:sendname = ""
  let s:sendaddress = ""
  let s:sendphone = ""
  let s:recivename = ""
  let s:reciveaddress = ""
  let s:recivephone = ""

  normal G?订单状态:.*已付款{
  while v:errmsg == "0"

  normal /订单编号:[^\s]\+
  exec "normal f:l\<C-v>g_\"1y"
  normal /收货人姓名:
  exec "normal f:l\<C-v>g_\"2y"
  normal /收货地址 :[^\s]\+
  exec "normal f:l\<C-v>g_\"3y"
  normal /联系手机:[^\s]\+
  exec "normal f:l\<C-v>g_\"4y"
  normal /宝贝标题 :[^\s]\+
  exec "normal f:l\<C-v>g_\"5y"
  

  exec 'e ' . s:order . '.html'
  normal "tp

  set wrapscan
  exec "normal /send-order\">/e\<CR>f<i\<C-r>=@1\<CR>\<Esc>"
  exec "normal /recive-name\">/e\<CR>a\<C-r>=@2\<CR>\<Esc>"
  exec "normal /recive-address\">/e\<CR>a\<C-r>=@3\<CR>\<Esc>"
  exec "normal /recive-phone\">/e\<CR>a\<C-r>=@4\<CR>\<Esc>"
  exec "normal /send-address\">/e\<CR>a\<C-r>=@5\<CR>\<Esc>"
  set nowrapscan
  w
  bd


  normal q1q
  normal q2q
  normal q3q
  normal q4q
  normal q5q

  let v:errmsg = "0"
  let s:order = s:order + 1
  normal {?订单状态:.*已付款{

  endwhile

  set more
  set wrapscan
endfunction


function! CsvConvert()

    set nomore
    set nowrapscan
  let v:errmsg = "0"
  let s:order  =  0 

  exec "normal ggo\<Esc>gg0\<C-v>$"
  s/"//g
  s/,/\r/g
  normal $"ad
  exec "normal \<S-v>)kkkdgg"

  normal /^"gg
  normal n

   while v:errmsg == "0"
       let s:order = s:order + 1

  s/^"/ :/g
  s/,"/, :/g
  s/"$/"\r/g
  normal k
  s/"//g
  s/,/\r/g

  normal }
       normal n
  endwhile

  normal gg

   for  cycle_value  in  range(s:order)
           exec "normal )0\<C-v>}k\"ap}"
	 endfor

   %s/皂台/台皂/g

   let s:order = 0
   let v:errmsg = "0"
  normal gg/宝贝标题 :.\+gg
  normal n

   while v:errmsg == "0"
       let s:order = s:order + 1
       
       s/[:，].\{-}皂\zs.\{-}\ze\(，\|$\)//g
       normal j/宝贝标题 :.\+

   endwhile
   w
endfunction


function! TtexSearchUnEqual()

normal gg/\(宝贝种类.*\([2-9]\)\n\(.*\n\)\{3}.*:\(\2\)\@!.*\)\|\(修改后的收货地址:.\+\)\|\(留言:.\+\)

set more
set nowrapscan
endfunction


function! TtexReplaceOnInTotal()
    %s/\(宝贝标题 :.*\)\@<= //g
    %s/\(宝贝标题 :.*\)\@<=买二送一//g
    %s/\(宝贝标题 :.*\)\@<=【天天特价】//g
    %s/\(宝贝标题[^，]*\)\(\n宝贝种类.*1\n\(.*\n\)\{3}.*:\([2-9]\).*\)/\1X\4\2/g
    w
endfunction


function! TtexGenOrder(StartOrder,StartNum,OrderCount) "StartOrder - ex:198 StartNum记得要加 引号

    set nomore
    set nowrapscan
    let CurOrderCount = a:StartOrder
   g!/\(订单编号\)\|\(买家会员名\)/d
   g/订单编号/exec "normal O---\<C-r>=CurOrderCount\<CR>---\<Esc>jjo---\<C-r>=CurOrderCount\<CR>---\<CR>" | let CurOrderCount = CurOrderCount - 1
    normal gg2O

   exec "normal Go\<Esc>o---order---\<Esc>"
   let s:orderstart = a:StartNum
   exec "normal o\<C-r>=s:orderstart\<CR>\<Esc>"
   normal dd
   exec  'normal ' . expand(a:OrderCount+1) . 'p' 

   exec "normal g_hhh\<C-v>GI   \<Esc>"
   exec "normal w\<C-v>eG:I -1\<CR>"
   exec "normal gvgelohx"

   let v:errmsg = "0"
    for i in range(a:StartOrder,a:StartOrder - a:OrderCount ,-1)
        exec "normal gg/---order---\<CR>jdd"

        if v:errmsg != "0"
            break
        endif

        exec "normal gg/---" . i . "---\<CR>"
        exec "normal jp0i快递单号:\<Esc>"
        exec "normal jddkkkp"

    endfor

    set more
    set  wrapscan
endfunction


function  TradeSend(company_code,StartOrder,OrderCount)
  normal q1q
  normal q2q

		
    for i in range(a:StartOrder,a:StartOrder - a:OrderCount +1 ,-1)
        exec "normal gg/---order---\<CR>jdd"
        exec "normal gg/---" . i . "---\<CR>"
				normal /订单编号:[^\s]\+
				exec "normal f:l\<C-v>g_\"2y"
				normal /快递单号:[^\s]\+
				exec "normal f:l\<C-v>g_\"1y"

				let s:s1=@1
				let s:s2=@2
			let cmd = '! bash post.sh ' . a:company_code . ' ' . s:s1 . ' ' . s:s2
		 silent	exec cmd
			 "exec cmd
				normal q1q
				normal q2q
    endfor

endfunction


"notice 注意要搜索 '皂台
"notice 注意要搜索 '会员名重复
"notice 注意要搜索 '邮政小包(其他快递)
"notice 注意要搜索 '修改后的地址,自己进行备注
"notice 注意要搜索 '后来已经付款的,一定要注意
