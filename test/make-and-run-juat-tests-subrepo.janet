(-> ["janet"
     "./juat/janet-usages-as-tests/make-and-run-tests.janet"
     # specify file and/or directory paths relative to project root
     "./pegdoc"
     ]
    (os/execute :p)
    os/exit)

