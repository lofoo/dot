let g:postindex = 1
set shortmess=a
set cmdheight=5

function! Genit()
		set nowrapscan

		let v:errmsg = "0"

		normal gg
		normal O-->content
		exec "normal \<Esc>"

		normal gg
		normal "tP

		" Fill PostIndex
		normal gg
		normal /"postindex":/e
   	exec "normal a \<C-R>=g:postindex"
		exec "normal \<Esc>"


		normal gg
		normal /title-->\zs.*
		normal v
		normal //e
		normal "ay

		normal gg
		normal /"title": ""/e
		normal hp

		g/title-->.*/d

		%s/-->noneimage/\"img\":-1,/g

		while v:errmsg == "0"
				normal gg
				normal /-->content
				normal /<img
				if v:errmsg == "0"
						exec "normal \<S-v>s\"img\":\<C-R>=g:postindex,"
						let g:postindex = g:postindex + 1
				endif
		endwhile

		let v:errmsg = "0"

		while v:errmsg == "0" 
				normal /\"img\":

				if v:errmsg == "0"
						normal 5l
						normal a[
						exec "normal \<Esc>"

						normal j
						let linect=getline(".") 

						if linect != ""
								exec "normal \<S-v>"
								normal }
								normal :s/\"img\"://g
								exec "normal \<Esc>"

								normal $
								normal s]


								exec "normal \<S-v>"
								normal ?
								normal J
						else
								normal k
								normal $
								normal s]
						endif

						normal o}

						normal kk
						exec "normal \<S-v>"
						normal {j
						normal :j
						normal :s/<br\/>\zs //ge

						normal i"paragraph": "
						exec "normal \<Esc>"
						normal $a",
						exec "normal \<Esc>"

						normal {
						normal o{

						normal }
				endif
		endwhile

		"Move Content to ContentObject
		normal gg
		normal /-->content
		normal j
		normal VGd

		normal gg
		normal /"content":
		normal p

		%s/.*-->content.*//g

		%s/^}$/},/g
		%s/}\zs,\ze\(\s*\n\)*]//g

endfunction


