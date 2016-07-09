GTMTOOLS 
 Q	 ; No routine entry
 ;
 ;; -------------------------
 ;;  *** Global Utilities ***
 ;; -------------------------
 ;;
 ;; --- Dump a global ---
GDUMP
 N $ET S $ET="G ERR"
 ;
 N GBL
 S GBL=$ZCMD
 ;W GBL,!
 D Dump(GBL)
 Q
 ;
Dump(GBL) ;;Private - Dumps a global to stdout
 ;ZWR @GBL
 D OUTPUT^%G(GBL,"%GO")
 Q
 ;
 ;; --- Find a string in a global ---
GFIND
 N $ET S $ET="G ERR"
 ;
 N GBL,STRING
 S GBL=$P($ZCMD," ",1)
 S STRING=$P($ZCMD," ",2)
 D GblFind(GBL,STRING)
 Q
 ;
GblFind(GBL,STRING) ;;Private - Searches a global for occurences of a string
 N CNT,CNTNODES,IGNCASE,TERM
 S (CNTNODES,CNT,IGNCASE,TERM)=0
 D OUTPUT^%G(GBL,"X","SEARCH^%GFIND")
 Q
 ;
 ;; -------------------------
 ;;  *** Date Utilities ***
 ;; -------------------------
 ;;
 ;; --- Return a formatted date and/or time.
ZDATE
 N $ET S $ET="G ERR"
 N DATE,ZCMD
 S DATE=$P($ZCMD," ",1) 
 S FMT=$P($ZCMD," ",2) 
 D ZDate(DATE,FMT)
 Q
 ;
ZDate(DATE,FMT)
 I DATE["^" S DATE=@DATE
 W $ZD(DATE,FMT)
 Q
 ;
ERR ;Generic error handler
 N $ET S $ET="H"
 W $P($ZS," ",2,$L($ZS," ")),!
 Q

