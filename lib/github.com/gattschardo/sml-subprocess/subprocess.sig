signature SUBPROCESS =
sig
  val popen:
    string
    -> string list
    -> { stdin: Posix.IO.file_desc
       , stdout: Posix.IO.file_desc
       , stderr: Posix.IO.file_desc
       , pid: Posix.Process.pid
       }

  val run:
    string
    -> string list
    -> string option
    -> {stdout: string, stderr: string, exit_status: Posix.Process.exit_status}

  val show_status: Posix.Process.exit_status -> string
end
