# based on code by bakpakin in spork's rawterm.c

(defn via-winapi
  []
  #
  (def coord (ffi/struct :s16 :s16))
  (def small-rect (ffi/struct :s16 :s16 :s16 :s16))
  (def csbi (ffi/struct coord coord :u16 small-rect coord))
  #
  (def i (ffi/native nil))
  #
  (def gsh (ffi/lookup i "GetStdHandle"))
  (def gsh-sig (ffi/signature :default :ptr :u32))
  #
  (def gsh-res
    # ((DWORD)-11) - signed cast to unsigned...
    (ffi/call gsh gsh-sig (- (math/abs (* 2 math/int32-min)) 11)))
  # XXX: INVALID_HANDLE_VALUE -1?
  (unless (= -1 gsh-res)
    (def gcsbi (ffi/lookup i "GetConsoleScreenBufferInfo"))
    (def gcsbi-sig (ffi/signature :default :bool :ptr :ptr))
    #
    (def buf (buffer/new-filled (ffi/size csbi) 0))
    #
    (def gcsbi-res
      (ffi/call gcsbi gcsbi-sig gsh-res buf))
    (when gcsbi-res
      (def [_ _ _ [left top right bottom] _]
        (ffi/read csbi buf))
      # =>
      #[[120 9001] [0 59] 7 [0 14 88 59] [120 49]]
      (def rows (- bottom top))
      (def cols (- right left))
      #
      [rows cols])))

(defn via-ioctl
  [ioctl-const]
  # ioctl_tty(2) - TIOCGWINSZ
  (def winsize (ffi/struct :ushort :ushort :ushort :ushort))
  #
  (def i (ffi/native nil))
  #
  (def ioctl (ffi/lookup i "ioctl"))
  (def sig (ffi/signature :default :int :int :ulong :ptr))
  #
  (def buf (ffi/write winsize [0 0 0 0]))
  #
  (def ioctl-res
    (ffi/call ioctl sig 0 ioctl-const buf))
  # =>
  #0
  (unless (= -1 ioctl-res)
    (def [rows cols _ _]
      (ffi/read winsize buf))
    #
    [rows cols]))

(defn via-shell
  [os]
  (def cmd
    (if (= :windows os)
      ["powershell" "-command" "&{(get-host).ui.rawui.WindowSize;}"]
      ["stty" "size"]))
  (def [left right]
    (with [f (file/temp)]
      (os/execute cmd :p {:out f})
      (file/seek f :set 0)
      (def out (file/read f :all))
      (->> (string/trim out)
           (string/split "\n")
           last
           string/trim
           (peg/match ~(sequence (number :d+) :s+ (number :d+))))))
  (if (= :windows os)
    [right left]
    [left right]))

(defn rows-and-cols
  []
  (def os (os/which))
  (def arch (os/arch))

  (cond
    # some from: https://github.com/olekukonko/ts
    (def tiocgwinsz
      (get {:dragonfly 0x40087468
            :freebsd 0x40087468
            :linux 0x5413
            :macos 0x40087468
            :netbsd 0x40087468
            :openbsd 0x40087468} os))
    (if (= :x64 arch)
      (via-ioctl tiocgwinsz)
      (via-shell os))
    #
    (or (= :windows os)
        (= :mingw os))
    (if (= :x64 arch)
      (via-winapi)
      (via-shell os))
    #
    (get {:bsd true
          :cygwin true
          # XXX: file/temp doesn't work for :mingw atm?
          #:mingw true
          :posix true} os)
    (via-shell os)
    #
    (= :web os)
    (errorf "emscripten unsupported")
    #
    (errorf "Unsupported os: %s" os)))

(defn rows
  []
  (get (rows-and-cols) 0))

(defn cols
  []
  (get (rows-and-cols) 1))

