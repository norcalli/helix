;;; Highlighting for lua

;; Keywords

(if_statement
[
  "if"
  "then"
  "end"
] @keyword.control.conditional)

(elseif_statement
[
  "elseif"
  "then"
  "end"
] @keyword.control.conditional)

(else_statement
[
  "else"
  "end"
] @keyword.control.conditional)

(terra_if_statement
[
  "if"
  "then"
  "end"
] @keyword.control.conditional)

(terra_elseif_statement
[
  "elseif"
  "then"
  "end"
] @keyword.control.conditional)

(terra_else_statement
[
  "else"
  "end"
] @keyword.control.conditional)

(for_statement
[
  "for"
  "do"
  "end"
] @keyword.control.repeat)

(terra_macro_escape
[
  "escape"
  "end"
] @keyword.control.macro)

(terra_macro_quote_block
[
  "quote"
  "end"
] @keyword.control.macro)

(terra_for_statement
[
  "for"
  "do"
  "end"
] @keyword.control.repeat)

(terra_label_statement
[
  "::"
] @operator)

(while_statement
[
  "while"
  "do"
  "end"
] @keyword.control.repeat)

(terra_while_statement
[
  "while"
  "do"
  "end"
] @keyword.control.repeat)

(repeat_statement
[
  "repeat"
  "until"
] @keyword.control.repeat)

(terra_repeat_statement
[
  "repeat"
  "until"
] @keyword.control.repeat)

(do_statement
[
  "do"
  "end"
] @keyword)

(terra_variable_declaration
[
  "var"
] @keyword.storage)

(terra_variable_declaration
  type: (_) @type
)

(terra_parameters
  type: (_) @type
)

(terra_deref
  ["@"]
  @operator
)

(terra_pointer
  ["&"]
  @operator
)

; (terra_function_declaration
;   .
;   (method_index_expression (identifier) (identifier))
;   _
;   (terra_block
;     (identifier) @variable.builtin
;     )
;   (#eq? @variable.builtin "self"))


; (terra_parameters
;   type: (_) @type.builtin
;   (#any-of? @type.builtin "int" "int64" "uint64")
; )

"return" @keyword.control.return

[
 "in"
 "local"
 (break_statement)
 "goto"
] @keyword

(function_declaration
[
  "function"
  "end"
] @keyword.function)

(function_definition
[
  "function"
  "end"
] @keyword.function)

(terra_function_declaration
[
  "terra"
  "end"
] @keyword.function)

(terra_local_function_declaration
[
  "local"
  "terra"
  "end"
] @keyword.function)

(terra_function_definition
[
  "terra"
  "end"
] @keyword.function)

(terra_struct
[
  "struct"
] @keyword.struct)

(terra_struct
[
  "{"
  "}"
] @constructor)

(terra_struct
  name: (identifier) @variable
)

;; Operators

[
 "not"
 "and"
 "or"
] @keyword.operator

[
"="
"~="
"=="
"<="
">="
"<"
">"
"+"
"-"
"%"
"/"
"//"
"*"
"^"
"&"
"@"
"~"
"|"
">>"
"<<"
".."
"#"
 ] @operator

;; Punctuation
["," "." ":" ";"] @punctuation.delimiter

;; Brackets

[
 "("
 ")"
 "["
 "]"
 "{"
 "}"
] @punctuation.bracket

; ;; Constants
[
(false)
(true)
] @constant.builtin.boolean
(nil) @constant.builtin
(vararg_expression) @constant

((identifier) @constant
 (#match? @constant "^[A-Z][A-Z_0-9]*$"))

;; Tables

(field name: (identifier) @variable.other.member)

(dot_index_expression field: (identifier) @variable.other.member)

(table_constructor
[
  "{"
  "}"
] @constructor)

;; Functions

(parameters (identifier) @variable.parameter)
(terra_parameters (identifier) @variable.parameter)

(function_call
  (identifier) @function.builtin
  (#any-of? @function.builtin
    ;; built-in functions in Lua 5.1
    "assert" "collectgarbage" "dofile" "error" "getfenv" "getmetatable" "ipairs"
    "load" "loadfile" "loadstring" "module" "next" "pairs" "pcall" "print"
    "rawequal" "rawget" "rawset" "require" "select" "setfenv" "setmetatable"
    "tonumber" "tostring" "type" "unpack" "xpcall"

    "macro"))

(function_declaration
  name: [
    (identifier) @function
    (dot_index_expression
      field: (identifier) @function)
  ])

(terra_function_declaration
  name: [
    (identifier) @function
    (dot_index_expression
      field: (identifier) @function)
  ])

(function_declaration
  name: (method_index_expression
    method: (identifier) @function.method))

(assignment_statement
  (variable_list .
    name: [
      (identifier) @function
      (dot_index_expression
        field: (identifier) @function)
    ])
  (expression_list .
    value: (function_definition)))

(table_constructor
  (field
    name: (identifier) @function
    value: (function_definition)))

(function_call
  name: [
    (identifier) @function.call
    (dot_index_expression
      field: (identifier) @function.call)
    (method_index_expression
      method: (identifier) @function.method.call)
  ])

; TODO: incorrectly highlights variable N in `N, nop = 42, function() end`
(assignment_statement
    (variable_list
      name: (identifier) @function)
    (expression_list
      value: (function_definition)))

(method_index_expression method: (identifier) @function.method)

;; Nodes
(comment) @comment
(string) @string
(escape_sequence) @constant.character.escape
(number) @constant.numeric.integer
(label_statement) @label
; A bit of a tricky one, this will only match field names
(field . (identifier) @variable.other.member (_))
(hash_bang_line) @comment

;; Property
(dot_index_expression field: (identifier) @variable.other.member)

;; Variables
((identifier) @variable.builtin
 (#eq? @variable.builtin "self"))

(variable_list
  (attribute
    "<" @punctuation.bracket
    (identifier) @attribute
    ">" @punctuation.bracket))

(identifier) @variable

;; Error
(ERROR) @error
