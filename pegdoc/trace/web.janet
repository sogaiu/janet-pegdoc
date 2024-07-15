(import ./http)
(import ../margaret/margaret/meg :as m)
(import ./render :as r)

########################################################################

# https://developer.mozilla.org/en-US/docs/Web/HTML/Element/form
# https://developer.mozilla.org/en-US/docs/Web/HTML/Element/textarea
# https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/submit
(def form-template
  ``
  <pre><u>generate a new trace</u></pre>
  <pre>
  <form action="/check"
        method="post"
        name="call"><textarea name="call" rows="5" cols="72">%s</textarea>
  <input type="submit" value="generate"/>
  </pre>
  </form>
  ``) # above, <form ...><textarea ... done to get specific spacing

(def event-links
  ``
  <pre>
  <a href="first.html">first</a>
  </pre>
  <pre>
  <a href="last.html">last</a>
  </pre>
  <pre>
  <a href="all.html">all</a>
  </pre>
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
  (def default-call
    ``
    (meg/match ~(sequence "b" (capture "a") (argument 0))
               "cba"
               1
               "!")
    ``)
  #
  (def body
    (string (string/format form-template default-call)
            (when (os/stat "first.html")
              (string ``
                      <hr>
                      <pre><u>events from previous trace</u></pre>
                      ``
                      event-links))))
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
  # XXX: could check first part of call, but why?
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
  (if (has-key? key-vals "call")
    (handle-call key-vals)
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
  [&opt dir host port]
  (default dir "pdoc-trace")
  (default host "127.0.0.1")
  (default port 8000)
  #
  (when (not (os/stat dir))
    (printf "Trying to create directory: %s" dir)
    (os/mkdir dir))
  (assert (= :directory (os/stat dir :mode))
          (string/format "Failed to create / locate dir: %s" dir))
  #
  (printf "Changing working directory to: %s" dir)
  (os/cd dir)
  (printf "Trying to start server at http://%s:%d" host port)
  (http/server router-handler host port))
