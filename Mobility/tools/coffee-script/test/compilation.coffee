# Compilation
# -----------

# helper to assert that a string should fail compilation
cantCompile = (code) ->
  throws -> CoffeeScript.compile code


test "ensure that carriage returns don't break compilation on Windows", ->
  doesNotThrow -> CoffeeScript.compile 'one\r\ntwo', bare: on

test "--bare", ->
  eq -1, CoffeeScript.compile('x = y', bare: on).indexOf 'function'
  ok 'passed' is CoffeeScript.eval '"passed"', bare: on, filename: 'test'

test "multiple generated references", ->
  a = {b: []}
  a.b[true] = -> this == a.b
  c = 0
  d = []
  ok a.b[0<++c<2] d...

test "splat on a line by itself is invalid", ->
  cantCompile "x 'a'\n...\n"

test "Issue 750", ->

  cantCompile 'f(->'

  cantCompile 'a = (break)'

  cantCompile 'a = (return 5 for item in list)'

  cantCompile 'a = (return 5 while condition)'

  cantCompile 'a = for x in y\n  return 5'

test "Issue #986: Unicode identifiers", ->
  λ = 5
  eq λ, 5

test "don't accidentally stringify keywords", ->
  ok (-> this == 'this')() is false

test "#1026", ->
  cantCompile '''
    if a
      b
    else
      c
    else
      d
  '''

test "#1050", ->
  cantCompile "### */ ###"

test "#1106: __proto__ compilation", ->
  object = eq
  @["__proto__"] = true
  ok __proto__
