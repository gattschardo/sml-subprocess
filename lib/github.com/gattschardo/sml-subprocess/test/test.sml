structure Test =
struct
  fun echo () =
    let
      val {stdout, stderr, exit_status} =
        Subprocess.run "echo" ["echo", "echo ok"] NONE
    in
      if stdout = "echo ok\n" andalso exit_status = Posix.Process.W_EXITED then
        (print stdout; true)
      else
        ( print ("echo fail: " ^ Subprocess.show_status exit_status ^ "\n")
        ; false
        )
    end

  fun cat () =
    let
      val {stdout, stderr, exit_status} =
        Subprocess.run "cat" ["cat"] (SOME "cat ok\n")
    in
      if stdout = "cat ok\n" andalso exit_status = Posix.Process.W_EXITED then
        (print stdout; true)
      else
        ( print ("cat fail: " ^ Subprocess.show_status exit_status ^ "\n")
        ; false
        )
    end

  fun false_ () =
    let
      val {stdout, stderr, exit_status} = Subprocess.run "false" ["false"] NONE
    in
      if exit_status = Posix.Process.W_EXITSTATUS (Word8.fromInt 1) then
        (print "false ok\n"; true)
      else
        ( print ("false fail: " ^ Subprocess.show_status exit_status ^ "\n")
        ; false
        )
    end

  fun errs () =
    let
      val {stdout, stderr, exit_status} =
        Subprocess.run "sh" ["sh", "-c", "echo stderr ok >&2"] NONE
    in
      if stderr = "stderr ok\n" andalso exit_status = Posix.Process.W_EXITED then
        (print stderr; true)
      else
        ( print ("stderr fail: " ^ Subprocess.show_status exit_status ^ "\n")
        ; false
        )
    end

  fun run () =
    echo () andalso cat () andalso false_ () andalso errs ()
end

val () = print "running tests\n"
val () = Posix.Process.exit (Word8.fromInt (if Test.run () then 0 else 1))
