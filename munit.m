munit(t,build)
 ;;; --------------------------------------------------
 ;;; To Do ---
 ;;;
 ;;; * add local gtmgbldir 
 ;;; * regexp for tests to run (ex, t1*, t1-5, *, etc)
 ;;; * add doc section to output doc section from unit
 ;;;	test routine.
 ;;; * improve reporting
 ;;;
 ;;; --------------------------------------------------
 new tests
 if '$D(%munit) use $P write "No %munit array",!,"Run Rebuild first",! quit
 set:$G(build) er=$$rebuild(%munit("target"))
 ;
 merge tests=%munit("tests")
 ;; Execute a single test
 if $G(t)'="*" do  quit
 .  set er=$$execTest(t)
 .  set %munit("stats",t)=er
 .  u $p write $P($T(^@t),";",1),":"
 .  write ?10,%munit("meta",t,"Description"),":"
 .  write ?75,$S(er=0:"pass",er=2:"skipped",1:"fail"),!
 ;
 ;; Execute all tests
 set seq="" for  set seq=$O(tests(seq)) quit:seq=""  do
 .  set er=$$execTest(tests(seq))
 .  set %munit("stats",tests(seq))=er
 .  u $p write $P($T(^@tests(seq)),";",1),":"
 .  write ?10,%munit("meta",tests(seq),"Description"),":"
 .  write ?75,$S(er=0:"pass",er=2:"skipped",1:"fail"),!
 quit
 ;;
execTest(t)
 ;;;-------------------------------------------
 ;;; Execute a single unit test
 ;;;-------------------------------------------
 new $zt set $zt="goto testErrorH^munit",$zstatus=""
 if $G(%munit("meta",t,"Disable"))="Y" set er=2 quit er	;test is disabled so skip it
 do setup^@t
 set er=$$exec^@t
 do teardown^@t
 quit er
 ;
rebuild(dir)
 ;;;-------------------------------------------
 ;;; Rebuild the unit test directory
 ;;; - Rebuild the .known_tests file
 ;;; - Rebuild the %munit array
 ;;; - zl all tests in the test directory
 ;;;-------------------------------------------
 new er,file,seq,tests
 new $zt set $zt="goto errorH",$zstatus=""
 ;;
 set dir=$G(dir,$G(%munit("target")))
 if dir="" set ER=1,RM="No target" quit ER
 set file=".known_tests"
 set er=$$buildFile(file,dir)	;build the know_tests file
 quit:er er
 h 1
 do init(file,dir)		;build the %munit array
 merge tests=%munit("tests")	;zlink the tests
 set seq="" for  set seq=$O(tests(seq)) quit:seq=""  zl tests(seq)
 quit er
 ;;
 ;;
buildFile(file,dir)
 ;;;-------------------------------------------
 ;;; Creates a file in dir that consists of all
 ;;; of the *.m routines located in dir
 ;;;-------------------------------------------
 new cmd
 set cmd="find "_dir_" -name ""*.m"" >"_dir_"/"_file_" &>/dev/null"
 ;set cmd="find "_dir_"/*.m -type f >"_dir_"/"_file_" &>/dev/null"
 zsy cmd
 quit $zsy
 ;;
init(file,dir)
 ;;;-------------------------------------------
 ;;; Build the %munit array
 ;;;-------------------------------------------
 new io,m,rec,seq
 set io=dir_"/"_file
 open io:(readonly)
 for  use io read rec quit:$zeof  do
 .  set test=$P($P(rec,dir_"/",2),".m",1)
 .  set seq=$P(test,"t",2)
 .  i seq="" quit
 .  set %munit("tests",seq)=test
 .  kill m
 .  do meta(test,.m)
 .  merge %munit("meta",test)=m
 close io
 quit
 ;;
meta(file,meta)
 ;;;-------------------------------------------
 ;;; Reads the META section from a file.
 ;;; Returns contents in meta array.
 ;;;-------------------------------------------
 new done,i,name,value,yaml
 set done=0
 quit:$G(file)="" 
 if $T(META^@file)="" quit
 for i=1:1 quit:done  do
 .  set yaml=$T(META+i^@file)
 .  if $E(yaml,1,3)=";;;" set done=1 quit
 .  set name=$P($P(yaml,":",1),"- ",2)
 .  set value=$P(yaml,":",2)
 .  set value=$E(value,2,$L(value))
 .  set meta(name)=value
 quit
 ;;
clean 
 set $zro=$G(%munit("savzro"))
 kill %munit 
 quit
 ;;
target(dir)
 set %munit("savzro")=$zro
 set %munit("target")=dir
 ;set $zro=dir_"/o("_dir_") "_$zro	;save $zro
 set $zro=dir_" "_$zro
 quit
 ;;
eof
 if $zstatus["IOEOF" do  quit
 .  set $ecode=""
 .  close io
 ;;
 else  use $p write !,"Error with file ",file,":"
 ;;
errorH		; generic error handler
 write !,$zstatus
 close io
 halt
 quit
 ;;
testErrorH	;test error handler
 write !,$zstatus,!
 halt
 quit 1

