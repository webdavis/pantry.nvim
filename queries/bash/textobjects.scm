;; extends

(command
  name: (command_name) @_name
  (#eq? @_name "return")) @return.outer

(function_definition
  body: (compound_statement
    (command
      name: (command_name) @_name
      (#any-of? @_name "echo" "printf")) @return.outer
    .))

(function_definition
  body: (compound_statement
    (redirected_statement
      body: (command
        name: (command_name) @_name
        (#any-of? @_name "echo" "printf"))
      redirect: (file_redirect) @_redirect
      (#not-lua-match? @_redirect "^>&2$")) @return.outer
    .))
