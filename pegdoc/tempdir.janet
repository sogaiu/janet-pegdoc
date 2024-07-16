# https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-gettemppath2w
(defn windows-temp-root
  []
  (os/getenv "TMP"
             (os/getenv "TEMP"
                        (os/getenv "USERPROFILE"
                                   # XXX
                                   (os/getenv "WINDIR")))))


# https://en.cppreference.com/w/cpp/filesystem/temp_directory_path
(defn posix-temp-root
  []
  (os/getenv "TMPDIR"
             (os/getenv "TMP"
                        (os/getenv "TEMP"
                                   (os/getenv "TEMPDIR" "/tmp")))))

(defn temp-root
  []
  (case (os/which)
    # see comment above function definition
    :windows (windows-temp-root)
    # XXX: unsure
    :mingw "/tmp"
    # XXX: unsure, but https://cygwin.com/cygwin-ug-net/setup-env.html
    :cygwin "/tmp"
    # https://ss64.com/mac/syntax-env_vars.html
    :macos (os/getenv "TMPDIR")
    # https://emscripten.org/docs/api_reference/Filesystem-API.html
    :web "/tmp"
    # https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
    :linux "/tmp"
    # https://www.freebsd.org/cgi/man.cgi?query=hier&sektion=7
    :freebsd "/tmp"
    # https://man.openbsd.org/hier.7
    :openbsd "/tmp"
    # https://man.netbsd.org/hier.7
    :netbsd "/tmp"
    # https://leaf.dragonflybsd.org/cgi/web-man?command=hier&section=7
    :dragonfly "/tmp"
    # based on the *bsd info above, following seems reasonable
    :bsd "/tmp"
    # see comment above function definition
    :posix (posix-temp-root)
    (errorf "unrecognized os: %n" (os/which))))

(defn mk-temp-dir
  ``
  Tries to create a new subdirectory of a system-specific temporary
  directory.  Optional argument `template` is used to specify a
  template for the new subdirectory's name.  Each forward slash (`/`)
  in the template is replaced with some hex value (0-9, a-f) to result
  in a candidate name.  The default value of `template` is `//////`.
  Optional argument `tries` is the maximum number of subdirectory
  creation attempts.  The default value of `tries` is 5.  Upon
  success, returns the full path of the newly created subdirectory.
  ``
  [&opt template tries]
  (default template "//////")
  (default tries 5)
  (assert (not (empty? template))
          "template should be a non-empty string")
  (assert (and (nat? tries) (pos? tries))
          (string/format "tries should be a positive integer, not: %d"
                         tries))

  (def tmp-root (temp-root))
  (assert (= :directory (os/stat tmp-root :mode))
          (string/format "failed to find temp root `%s` for os `%s"
                         tmp-root (os/which)))

  (def fs-sep (if (= :windows (os/which)) `\` "/"))
  (def rng (math/rng (os/cryptorand 8)))
  (defn rand-hex [_] (string/format "%x" (math/rng-int rng 16)))
  (var result nil)
  (for i 0 tries
    (def cand-path
      (string tmp-root fs-sep (string/replace-all "/" rand-hex template)))
    (when (os/mkdir cand-path)
      (set result cand-path)
      (break result)))

  (when (not result)
    (errorf "failed to create new temp directory after %d tries" tries))

  result)

(comment

  (peg/match ~(repeat 6 :h)
             (reverse (mk-temp-dir)))
  # =>
  @[]

  (peg/match ~(sequence (thru "hello-")
                        (repeat 3 :h))
             (mk-temp-dir "hello-///"))
  # =>
  @[]

  (do
    (def [success? _] (protect (mk-temp-dir "")))
    (not success?))
  # =>
  true

  )
