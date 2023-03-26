(declare-project
  :name "pegdoc"
  :url "https://github.com/sogaiu/janet-pegdoc"
  :repo "git+https://github.com/sogaiu/janet-pegdoc.git")

(declare-source
  :source @["pegdoc"])

(declare-binscript
  :main "pdoc"
  :is-janet true)

