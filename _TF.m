%TF
	Q
Clr()
	u $p:(x=0:y=0:clearscreen)
	Q ""
Eol()
	u $p:(eraseline)
	;W *27,*91,*48,*75
	Q ""
Eos()
	u $p:(clearscreen)
	;W *27,*91,*48,*75
	Q ""
	;
Cup(x,y)
	U $P:(X=x:Y=y)
	Q ""
Hoff()
	W *27,*91,*48,*109
	Q ""
Hon()
	W *27,*91,*49,*109
	Q ""
Len()	Q ""
Wid()	Q ""
Roff()
	W *27,*91,*48,*109
	Q ""
Ron()
	W *27,*91,*55,*109
	Q ""
Uoff()
	W *27,*91,*48,*109
	Q ""
Uon()
	W *27,*91,*52,*109
	Q ""
COL132()
	S val=132
	G col
COL80()
	S val=80
	G col
col
	u $p:(echo:width=val:wrap)
	q ""
