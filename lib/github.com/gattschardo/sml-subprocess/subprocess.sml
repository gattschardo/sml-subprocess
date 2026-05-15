structure Subprocess :> SUBPROCESS =
struct
  fun popen cmd args =
    let
      val in_pipe = Posix.IO.pipe ()
      val out_pipe = Posix.IO.pipe ()
      val err_pipe = Posix.IO.pipe ()
    in
      case Posix.Process.fork () of
        NONE =>
          (* child *)
          let
            val () = Posix.IO.close (#outfd in_pipe)
            val () = Posix.IO.close (#infd out_pipe)
            val () = Posix.IO.close (#infd err_pipe)
            val () =
              Posix.IO.dup2 {old = #infd in_pipe, new = Posix.FileSys.stdin}
            val () =
              Posix.IO.dup2 {old = #outfd out_pipe, new = Posix.FileSys.stdout}
            val () =
              Posix.IO.dup2 {old = #outfd err_pipe, new = Posix.FileSys.stderr}
            val () = Posix.IO.close (#infd in_pipe)
            val () = Posix.IO.close (#outfd out_pipe)
            val () = Posix.IO.close (#outfd err_pipe)
          in
            Posix.Process.execp (cmd, args)
          end
      | SOME pid =>
          (* parent *)
          let
            val () = Posix.IO.close (#infd in_pipe)
            val () = Posix.IO.close (#outfd out_pipe)
            val () = Posix.IO.close (#outfd err_pipe)
          in
            { stdin = #outfd in_pipe
            , stdout = #infd out_pipe
            , stderr = #infd err_pipe
            , pid = pid
            }
          end
    end

  fun read_all fd =
    let
      val chunk_size = 4096
      fun loop acc =
        let val chunk = Posix.IO.readVec (fd, chunk_size)
        in if Word8Vector.length chunk = 0 then acc else loop (acc @ [chunk])
        end
      val chunks = loop []
    in
      Byte.bytesToString (Word8Vector.concat chunks)
    end
  fun write_all fd s =
    let
      val vec = Word8VectorSlice.full (Byte.stringToBytes s)
      fun loop slice =
        if Word8VectorSlice.length slice = 0 then
          ()
        else
          let val n = Posix.IO.writeVec (fd, slice)
          in loop (Word8VectorSlice.subslice (slice, n, NONE))
          end
    in
      loop vec
    end

  fun run cmd args input =
    let
      val {stdin, stdout, stderr, pid} = popen cmd args
      val () = if isSome input then write_all stdin (valOf input) else ()
      val () = Posix.IO.close stdin
      val out = read_all stdout
      val err = read_all stderr
      val (_, status) = Posix.Process.waitpid (Posix.Process.W_CHILD pid, [])
    in
      {stdout = out, stderr = err, exit_status = status}
    end

  fun show_status pid =
    let
      open Posix.Process
    in
      case pid of
        W_EXITED => "exited"
      | W_EXITSTATUS w => "exit(" ^ (Int.toString (Word8.toInt w)) ^ ")"
      | W_SIGNALED sg => "signal"
      | W_STOPPED sg => "stopped"
    end
end
