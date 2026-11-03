local Helpers = require("tests.helpers")
local child, hooks = Helpers.jumps_child()
local j = Helpers.jumping(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local lua = {
  "local function f(x)",
  "  if x then",
  "    return 1",
  "  end",
  "  local y = 2",
  "  return y",
  "end",
}

T["]r goes to the next return in Lua"] = function()
  j.open("lua", lua)
  j.at(1)
  eq(j.press("]r"), 3)
  eq(j.press("]r"), 6)
end

T["[r goes to the previous return"] = function()
  j.open("lua", lua)
  j.at(7)
  eq(j.press("[r"), 6)
  eq(j.press("[r"), 3)
end

T["a count skips returns"] = function()
  j.open("lua", lua)
  j.at(1)
  eq(j.press("2]r"), 6)
end

T["<C-o> returns to where ]r started"] = function()
  j.open("lua", lua)
  j.at(1)
  j.press("]r")
  eq(j.press("<C-o>"), 1)
end

T["]r finds Python returns"] = function()
  j.open("python", { "def f(x):", "    if x:", "        return 1", "    return 2" })
  j.at(1)
  eq(j.press("]r"), 3)
  eq(j.press("]r"), 4)
end

T["]r finds a Rust tail expression and skips a body that ends in a statement"] = function()
  j.open("rust", {
    "fn noop() {",
    "    let x = 1;",
    "}",
    "fn add(a: i32) -> i32 {",
    "    if a > 0 {",
    "        return a;",
    "    }",
    "    a + 1",
    "}",
  })
  j.at(1)
  eq(j.press("]r"), 6)
  eq(j.press("]r"), 8)
end

T["]r finds Swift returns and single expression bodies but skips closures"] = function()
  j.open("swift", {
    "func area(width: Int) -> Int {",
    "  width * 2",
    "}",
    "func run() {",
    "  let f = { (x: Int) -> Int in x }",
    "  if f(1) > 1 {",
    "    return",
    "  }",
    "}",
  })
  j.at(1)
  eq(j.press("]r"), 2)
  eq(j.press("]r"), 7)
end

T["]r finds Bash returns and a final echo that is not sent to stderr"] = function()
  j.open("bash", {
    "greet() {",
    '  if [ -z "$1" ]; then',
    "    return 1",
    "  fi",
    '  echo "hi $1"',
    "}",
    "warn() {",
    '  echo "bad" >&2',
    "}",
    "log() {",
    "  printf '%s' \"$1\" > out.txt",
    "}",
  })
  j.at(1)
  eq(j.press("]r"), 3)
  eq(j.press("]r"), 5)
  eq(j.press("]r"), 11)
end

T["]r stays put in a buffer without a parser"] = function()
  j.open("text", { "return 1", "return 2" })
  j.at(1)
  eq(j.press("]r"), 1)
end

return T
