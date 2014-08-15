munit(dir,build)
 new io,tests,zro
 set $zro=dir_" "_$zro	;save $zro
 do rebuild(dir,build,.tests)
 set seq="" for  set seq=$O(tests(seq)) quit:seq=""  zl tests(seq)
 set seq="" f  s seq=$O(tests(seq)) quit:seq=""  do
 .  u $p write $P($T(^@tests(seq)),";",1),":",$c(9)
 .  set er=$$execTest(tests(seq))
 .  write $S(er=0:"pass",1:"fail"),!
 quit
 ;;
execTest(t)
 ;;;-------------------------------------------
 ;;; Execute a single unit test
 ;;;-------------------------------------------
 quit $$^@t
rebuild(dir,build,tests)
 ;;;-------------------------------------------
 ;;; Rebuild the unit test directory
 ;;;-------------------------------------------
 new file,seq
 new $etrap
 set $ecode="",$etrap="goto error",$zstatus=""
 ;;
 set file=".known_tests"
 set:$G(build,0) er=$$buildFile(file,dir)	;build the know_tests file
 set seq=0
 ;;
 set io=dir_"/"_file
 open io:(readonly)
 for seq=1:1 use io read rec quit:$zeof  set tests(seq)=$P($P(rec,dir_"/",2),".m",1)
 close io
 quit
 ;;
buildFile(file,dir)
 ;;;-------------------------------------------
 ;;; Creates a file in dir that consists of all
 ;;; of the *.m routines located in dir
 ;;;-------------------------------------------
 new cmd
 set cmd="find "_dir_"/*.m -type f >"_dir_"/.known_tests &>/dev/null"
 zsy cmd
 quit $zsy
 ;;
eof
 if $zstatus["IOEOF" do  quit
 .  set $ecode=""
 .  close io
 ;;
 else  use $p write !,"Error with file ",file,":"
 ;;
error
 write !,$zstatus
 close io
 quit
