;; extends

((control_transfer_statement) @return.outer
  (#lua-match? @return.outer "^return"))

(function_declaration
  "->"
  body: (function_body
    (statements
      .
      (_) @return.outer
      .)))
