local treesitter = require("pantry.jumps.treesitter")

local M = {}

local js = "[(function_declaration) (function_expression) (arrow_function) (method_definition) (class_declaration)"
  .. " (if_statement) (for_statement) (for_in_statement) (while_statement) (switch_statement) (try_statement)"
  .. " (object) (array)] @context"

local built_in = {
  lua = "[(function_declaration) (function_definition) (if_statement) (for_statement) (while_statement)"
    .. " (repeat_statement) (do_statement) (table_constructor)] @context",
  python = "[(class_definition) (function_definition) (if_statement) (elif_clause) (else_clause) (for_statement)"
    .. " (while_statement) (with_statement) (try_statement) (except_clause) (match_statement) (case_clause)] @context",
  javascript = js,
  typescript = js,
  tsx = js,
  go = "[(function_declaration) (method_declaration) (func_literal) (type_declaration) (if_statement)"
    .. " (for_statement) (expression_switch_statement) (type_switch_statement) (select_statement)"
    .. " (composite_literal)] @context",
  rust = "[(function_item) (impl_item) (trait_item) (struct_item) (enum_item) (mod_item) (if_expression)"
    .. " (match_expression) (match_arm) (for_expression) (while_expression) (loop_expression)"
    .. " (closure_expression)] @context",
  swift = "[(class_declaration) (protocol_declaration) (function_declaration) (if_statement) (guard_statement)"
    .. " (for_statement) (while_statement) (switch_statement) (switch_entry) (do_statement) (lambda_literal)] @context",
  bash = "[(function_definition) (if_statement) (for_statement) (c_style_for_statement) (while_statement)"
    .. " (case_statement) (case_item)] @context",
  json = "[(object) (pair)] @context",
  yaml = "[(block_mapping_pair) (block_sequence_item)] @context",
  toml = "[(table) (table_array_element) (inline_table) (array) (pair)] @context",
  markdown = "(section) @context",
}

local context_query = function(lang)
  return vim.treesitter.query.get(lang, "context")
    or built_in[lang] and vim.treesitter.query.parse(lang, built_in[lang])
end

M.ranges = function(buf)
  return vim.tbl_map(function(node)
    local first, _, last, last_col = node:range()
    return { first = first + 1, last = last_col == 0 and last or last + 1 }
  end, treesitter.captures(buf, context_query, "context"))
end

return M
