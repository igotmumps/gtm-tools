MZTOOLS;;2016-06-10  1:23 PM

ZAVLDATU(CID,SEQ,DATE)
	D OUT^UTSO(.A,$P(^HIST(CID,SEQ),"|",7))
	S A("ZAVLDATE")=DT
	S $P(A("ZAVLDATE2","`"),1)=DATE
	D IN^UTSO(.A,.TSO)
	S $P(^HIST(CID,SEQ),"|",7)=TSO
	Q
	;
ZCRDMON(ACN)
	D ZGETCRD(ACN,1)
	F  D  H 3
	.  S TIM=""
	.  F  S TIM=$O(^ZCRDQ(TIM)) Q:TIM=""  D
	..  S CMD=$G(^ZCRDQ(TIM))
	..  K ^ZCRDQ(TIM)
	..  I CMD="UPD" D ZGETCRD(ACN)
	..  ;I CMD="ZL" S ZLINK="ZL ""MZTOOLS""" X ZLINK
	..  I CMD="STP" H
	Q
	;
ZGETCRD(ACN,DISP,ARRAY)
	D SYSVAR^SCADRV0() S (ER,TLO)="",%UID=8888
	N ARR,CARDS,CID,DATA,ERR,REC,RET,RETURN,X,SEP
	I $G(ACN)="" W "Customer #: " R ACN
	I '$D(^CIF(ACN)) S ER=1,RM="INVALID ACN" Q RM

	S ERR=$$ZCRDG^ZMRPC150(.RETURN,1,ACN) Q:ERR RM
	N I,J
	S X=$$LV2V^MSG(RETURN,.RET)
	S I=""
	F I=1:1:$l(RET(1),$C(13,10))-1 D
	.  S REC=$P(RET(1),$C(13,10),I)
	.  F J=1:1:$L(REC,$C(9)) D
	..  S DATA=$P(REC,$C(9),J)
	..  S ARR(I,J)=DATA
	;

	S I="" F  S I=$O(^CIF(ACN,114,"MTV",I)) Q:I=""  S CARDS($E(I,$L(I)-3,$L(I)))=I
	
	I '$G(DISP) Q
	;;Display Header
	W $$COL132^%TF
	W $$Clr^%TF
	n i,field,x,y
	f i=1:1 s rec=$p($t(zcrdgscrn+i),";",3) q:$p(rec,"|",1)="-"  d
	.  s field=$p(rec,"|",1)
	.  s x=$p(rec,"|",2)
	.  s y=$p(rec,"|",3)
	.  w $$Cup^%TF(x,y),field
	;
	S $P(SEP,"=",100)=""
	W !,SEP,!
	S SEP=""
	S $P(SEP,"-",100)=""
	N LAST4,CRDNUM,C,F,TBL,row
	S I="" F  S I=$O(ARR(I)) Q:I=""  D
	.  S LAST4=$G(ARR(I,1))
	.  S CRDNUM=$G(CARDS(LAST4))
	.  S CID=$G(ARR(I,5))
	.  K C,F
	.  D GETEXPDT(CRDNUM,.C,.F)
	.  k row
	.  S row(1)=CRDNUM
	.  S row(2)=$G(C)
	.  S row(3)=$G(ARR(I,12)) ;First 6
	.  S row(4)=$G(ARR(I,2)) ;State
	.  S row(5)=$G(ARR(I,4)) ;A
	.  S row(6)=$G(ARR(I,7)) ;Number of Reissues
	.  S row(7)=$G(ARR(I,10)) ;ING Active
	.  S row(8)=$G(ARR(I,11)) ;Active DPANS
	.  S row(9)=$G(ARR(I,14)) ;Card Lock
	.  S row(10)=$G(ARR(I,5)) ;Account #
	.  S row(11)=$G(F)
	.  S row(12)=LAST4
	.  S row(13)=$G(ARR(I,9)) ;MTV Status
	.  S row(14)=$G(ARR(I,3)) ;Blocked
	.  S row(15)=$G(ARR(I,8)) ;Activate Later
	.  S row(16)=$G(ARR(I,15)) ;Mobile Active
	.  S row(17)=$G(ARR(I,13)) ;Display PIN Flag
	.  M TBL($O(TBL(""),-1)+1)=row
	;
	n fac,row
	s fac=0
	s row="" f  s row=$o(TBL(row)) quit:row=""  do
	.  s fac=fac+1
	.  f i=1:1 s rec=$p($t(zcrdgscrn+i),";",3) q:$p(rec,"|",1)="-"  d
	..  s val=$G(TBL(row,i))
	..  s x=$p(rec,"|",2)
	..  s y=$p(rec,"|",3)+2+row+fac
	..  w $$Cup^%TF(x,y),val
	.  W !,SEP,!
	.  s fac=fac+1
	;
	Q
	;
zcrdgscrn
	;;Card #|0|0
	;;Current|18|0
	;;First6|26|0
	;;State|33|0
	;;Actv #|39|0
	;;Reissue|47|0
	;;ING Active|58|0
	;;DPANS|69|0
	;;Card Lock|75|0
	;;Account #|0|1
	;;Future|18|1
	;;Last4|26|1
	;;MTV|33|1
	;;Blocked|39|1
	;;Actv Later|47|1
	;;Mobile|58|1
	;;Show PIN|75|1
	;;-
	;
	Q
GETEXPDT(CRDNUM,CUREXP,FUTEXP)
	N MM,YY,EXP
	F YY=2000:1:2025 D
	.  F MM=1:1:12 D
	..  I $L(MM)<2 S MM="0"_MM
	..  S X=$$ENC^%ENCRYPT($E(YY,3,4)_MM,.EXP)
	..  I EXP=$P(^ZCRDSTAT(CRDNUM),"|",9) S FUTEXP=MM_"/"_YY
	..  I EXP=$P(^ZCRDSTAT(CRDNUM),"|",10) S CUREXP=MM_"/"_YY
	Q
	;
ZCRDUPDEXP(CRDNUM,CUREXP,FUTEXP)
	
	I $G(CRDNUM)="" S ER=1,RM="Missing CRDNUM" Q
	I '$D(^ZCRDSTAT(CRDNUM)) S ER=1,RM="CRDNUM not found" Q
	;
	; Current Expiry Date
	I $G(CUREXP)="" D
	. W "Current Exp Date (YYMM)?: "
	. R CUREXP
	I $G(CUREXP)'="" D
	.  I CUREXP="CLEAR" S $P(^ZCRDSTAT(CRDNUM),"|",10)="" Q
	.  S X=$$ENC^%ENCRYPT(CUREXP,.EXP)
	.  S $P(^ZCRDSTAT(CRDNUM),"|",10)=EXP
	;
	; Future Expiry Date
	I $G(FUTEXP)="" D
	. W "Future Exp Date (YYMM)?: "
	. R FUTEXP
	I $G(FUTEXP)'="" D
	.  I FUTEXP="CLEAR" S $P(^ZCRDSTAT(CRDNUM),"|",9)="" Q
	.  S X=$$ENC^%ENCRYPT(FUTEXP,.EXP)
	.  S $P(^ZCRDSTAT(CRDNUM),"|",9)=EXP
	Q
	;
ZCRDUPD(return,version,CRDNUM,STAT,ACTTRY,UNBLKCNT,INGACTIVE,MOBILE,EXPFURDT,EXPCURDT,EXPARCDT,REISSUE,CUSTSUSP)
	;;MRPC: "ZCRDUPD" - Set a card to a specific configuration
	;;                for TEST use only - not for production
	;; Given:
	;; CRD       I - Card Number
	;; STAT      I - MTV Status
	;; ACTTRY    I - # of failed activation attempts
	;; UNBLKCNT  I - # of unblocks by an SA
	;; INGACTIVE I - ING Active Flag (0;1)
	;; EXPFURDT  I - Future expiration date (YYMM format)
	;; EXPCURDT  I - Current expiration date (YYMM format)
	;; EXPARCDT  I - Archived expiration date (YYMM format)
	;; Note: "" in a date field means don't change the current value
	;;       "CLEAR" in a date field means set it to ""
	;; Returns:
	;;    0 = ok
	;; -------------------------------------------------------------------------
	new ADT,CDT,FDT
	set return=""


	if $G(version)'=1 quit $$ERRMSG^PBSUTL($$^MSG(2951)) ; Must be version 1
	;
	if '$D(^ZCRDSTAT(CRDNUM)) quit $$ERRMSG^PBSUTL("CRDNOTFOUND")
	;
	if $G(EXPFURDT)'="" set FDT=$S(EXPFURDT="CLEAR":"",1:EXPFURDT)
	if $G(EXPCURDT)'="" set CDT=$S(EXPCURDT="CLEAR":"",1:EXPCURDT)
	if $G(EXPARCDT)'="" set ADT=$S(EXPARCDT="CLEAR":"",1:EXPARCDT)
	;
	S CREC=^ZCRDSTAT(CRDNUM)
	I $G(STAT)'="" S $P(CREC,"|",3)=STAT
	I $G(ACTTRY)'="" S $P(CREC,"|",5)=ACTTRY
	I $G(UNBLKCNT)'="" S $P(CREC,"|",6)=UNBLKCNT
	I $G(INGACTIVE)'="" S $P(CREC,"|",7)=INGACTIVE
	I $G(MOBILE)'="" S $P(CREC,"|",23)=MOBILE
	I $G(REISSUE)'="" S $P(CREC,"|",12)=REISSUE
	I $G(CUSTSUSP)'="" S $P(CREC,"|",17)=CUSTSUSP
	;
	I $D(FDT) D
	.  S:FDT'="" st=$$ENC^%ENCRYPT(FDT,.enc)
	.  S $P(CREC,"|",9)=$S(FDT="":"",1:enc)
	;
	I $D(CDT) D
	.  S:CDT'="" st=$$ENC^%ENCRYPT(CDT,.enc)
	.  S $P(CREC,"|",10)=$S(CDT="":"",1:enc)
	;
	I $D(ADT) D
	.  S:ADT'="" st=$$ENC^%ENCRYPT(ADT,.enc)
	.  S $P(CREC,"|",11)=$S(ADT="":"",1:enc)
	;
	S ^ZCRDSTAT(CRDNUM)=CREC
	S return=$$V2LV^MSG("0")
	Q ""
