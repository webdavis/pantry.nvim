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

(property_declaration
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer
