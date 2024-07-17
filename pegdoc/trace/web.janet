(import ./http)
(import ../margaret/margaret/meg :as m)
(import ./render :as r)
(import ./generate :as tg)

########################################################################

(def event-links
  ``
  <pre>
  <a href="first.html">first event</a>
  </pre>
  <pre>
  <a href="last.html">last event</a>
  </pre>
  <pre>
  <a href="all.html">all events</a>
  </pre>
  ``)

# https://developer.mozilla.org/en-US/docs/Web/HTML/Element/form
# https://developer.mozilla.org/en-US/docs/Web/HTML/Element/textarea
# https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/submit
(def new-trace-form-template
  ``
  <pre><u>generate a new trace</u></pre>
  <pre>
  <form action="/check"
        method="post"><textarea name="call"
                                rows="5"
                                cols="72">%s</textarea>
  <input type="submit" value="generate"/>
  </pre>
  </form>
  ``) # above, <form ...><textarea ... done to get specific spacing

(def sample-trace-form-template
  ``
  <pre><u>generate a sample trace</u></pre>
  <pre>
  <form action="/check"
        method="post"><input type="text"
                             name="random"
                             value="%s"/>
  <input type="submit" value="generate"/>
  </pre>
  </form>
  ``)

(var default-call
  ``
  (meg/match ~(sequence "b" (capture "a") (argument 0))
             "cba"
             1
             "!")
  ``)

(defn start-handler
  [request]
  # :route lacks the ?hi=ho parts, while :path has them
  (def route (get request :route))
  (when (string/has-suffix? ".html" route)
    (def filename (string/slice route 1))
    (when (os/stat filename)
      (def content (slurp filename))
      (break {:headers {"Content-type" "text/html"}
              :status 200
              :body content})))
  #
  (def body
    (string (when (os/stat "first.html")
              (string ``
                      <pre><u>events from previous trace</u></pre>
                      ``
                      event-links
                      "<hr>"))
            (string/format new-trace-form-template default-call)
            "<hr>"
            (string/format sample-trace-form-template "filter text")
            ))
  #
  {:headers {"Content-type" "text/html"}
   :status 200
   :body body})

########################################################################

(defn render-results
  [peg text start & args]
  # XXX: this could take some time in some cases...
  (def [r-success? results]
    (protect (r/render peg text start ;args)))
  (when (not r-success?)
    (break {:headers {"Content-type" "text/html"}
            :status 200
            :body (string "There was a problem when rendering:\n\n"
                          results)}))
  #
  {:headers {"Content-type" "text/html"}
   :status 200
   :body (string ``
                 <pre><u>generated trace for events</u></pre>
                 ``
                 event-links)})

(defn handle-call
  [key-vals]
  (def call-str (get key-vals "call"))
  (def [call-success? call] (protect (parse call-str)))
  (when (not call-success?)
    (break {:headers {"Content-type" "text/html"}
            :status 200
            :body (string "<pre>"
                          "There was a problem.\n"
                          "Failed to extract arguments from call:\n"
                          "\n"
                          "call: " call-str "\n"
                          "</pre>")}))
  #
  (def callable-name (string (get call 0)))
  (when (and (not= "peg/match" callable-name)
             (not= "meg/match" callable-name))
    (break {:headers {"Content-type" "text/html"}
            :status 200
            :body (string "<pre>"
                          "There was a problem.\n"
                          "Call was not to peg/match or meg/match:\n"
                          "\n"
                          "call was to: " callable-name
                          "\n"
                          "</pre>")}))
  #
  (def peg-form (get call 1))
  (def [peg-form-sucess? peg]
    (protect (eval-string (string/format "%n" peg-form))))
  (when (not peg-form-sucess?)
    (break {:headers {"Content-type" "text/html"}
            :status 200
            :body (string "<pre>"
                          "There was a problem.\n"
                          "The peg argument was not correct, got:\n"
                          "\n"
                          "peg: " (string/format "%m" peg-form) "\n"
                          "</pre>")}))
  #
  (def [peg-success? result] (protect (m/analyze peg)))
  (def text (get call 2 ""))
  (def start (get call 3 0))
  (def args
    (if (>= (length call) 5)
      (array/slice call 4)
      @[]))
  (when (not (and peg-success?
                  text (string? text)
                  start (number? start)
                  args (array? args)))
    (break {:headers {"Content-type" "text/html"}
            :status 200
            :body (string "<pre>"
                          "There was a problem.\n"
                          "Some argument was not correct, got:\n"
                          "\n"
                          "peg: " (string/format "%m" peg) "\n"
                          "text: " `"` (string/format "%s" text) `"` "\n"
                          "start: " (string/format "%d" start) "\n"
                          "args: " (string/format "%n" args) "\n"
                          "</pre>")}))
  #
  (render-results peg text start ;args))

########################################################################

(defn handle-random
  [key-vals]
  (def pattern (get key-vals "random"))
  (def choice-path (tg/scan-with-random pattern))
  (when (not (os/stat choice-path))
    (break {:headers {"Content-type" "text/html"}
            :status 200
            :body (string "<pre>"
                          "There was a problem.\n"
                          "\n"
                          "Chose a non-existent file: %s" choice-path
                          "</pre>")}))
  #
  (def [success? result]
    (protect (tg/gen-files (slurp choice-path) true)))
  (when (not success?)
    (break {:headers {"Content-type" "text/html"}
            :status 200
            :body (string "<pre>"
                          "There was a problem.\n"
                          "\n"
                          result
                          "</pre>")}))
  #
  {:headers {"Content-type" "text/html"}
   :status 200
   :body (string ``
                 <pre><u>generated trace for events</u></pre>
                 ``
                 event-links)})

########################################################################

(defn handle-error
  [request]
  {:headers {"Content-type" "text/html"}
   :status 200
   :body (string "<pre>"
                 "Unexpected submission\n"
                 (string/format "%n" request)
                 "</pre>")})

########################################################################

(defn check-handler
  [request]
  (def key-vals
    (->> (get request :buffer)
         (peg/match http/query-string-grammar)
         first))
  (cond
    (has-key? key-vals "call")
    (handle-call key-vals)
    #
    (has-key? key-vals "random")
    (handle-random key-vals)
    #
    (handle-error request)))

########################################################################

(def routes
  {"/check" check-handler
   :default start-handler})

(defn router-handler
  [request]
  (def handler (http/router routes))
  (handler request))

(defn serve
  [&opt content dir host port]
  (default content default-call)
  (default dir "pdoc-trace")
  # https://superuser.com/a/949522
  (default host "127.0.0.1")
  # choose some unused port
  (default port 0)
  #
  (set default-call content)
  #
  (when (not (os/stat dir))
    (printf "Trying to create directory: %s" dir)
    (os/mkdir dir))
  (assert (= :directory (os/stat dir :mode))
          (string/format "Failed to create / locate dir: %s" dir))
  #
  (printf "Changing working directory to: %s" dir)
  (os/cd dir)
  # replicating bits of net/server and http/server to access actual
  # host and port information
  (def s (net/listen host port))
  (def [actual-host actual-port] (net/localname s))
  (printf "Trying to start server at http://%s:%d" actual-host actual-port)
  (defn handler
    [conn]
    (http/server-handler conn router-handler))
  (ev/go (fn [] (net/accept-loop s handler))))

