# Comprehensions
# --------------

# * Array Comprehensions
# * Range Comprehensions
# * Object Comprehensions
# * Implicit Destructuring Assignment
# * Comprehensions with Nonstandard Step

# TODO: refactor comprehension tests

test "Basic array comprehensions.", ->

  nums    = (n * n for n in [1, 2, 3] when n & 1)
  results = (n * 2 for n in nums)

  ok results.join(',') is '2,18'


test "Basic object comprehensions.", ->

  obj   = {one: 1, two: 2, three: 3}
  names = (prop + '!' for prop of obj)
  odds  = (prop + '!' for prop, value of obj when value & 1)

  ok names.join(' ') is "one! two! three!"
  ok odds.join(' ')  is "one! three!"


test "Basic range comprehensions.", ->

  nums = (i * 3 for i in [1..3])

  negs = (x for x in [-20..-5*2])
  negs = negs[0..2]

  result = nums.concat(negs).join(', ')

  ok result is '3, 6, 9, -20, -19, -18'


test "With range comprehensions, you can loop in steps.", ->

  results = (x for x in [0...15] by 5)
  ok results.join(' ') is '0 5 10'

  results = (x for x in [0..100] by 10)
  ok results.join(' ') is '0 10 20 30 40 50 60 70 80 90 100'


test "And can loop downwards, with a negative step.", ->

  results = (x for x in [5..1])

  ok results.join(' ') is '5 4 3 2 1'
  ok results.join(' ') is [(10-5)..(-2+3)].join(' ')

  results = (x for x in [10..1])
  ok results.join(' ') is [10..1].join(' ')

  results = (x for x in [10...0] by -2)
  ok results.join(' ') is [10, 8, 6, 4, 2].join(' ')


test "Range comprehension gymnastics.", ->

  eq "#{i for i in [5..1]}", '5,4,3,2,1'
  eq "#{i for i in [5..-5] by -5}", '5,0,-5'

  a = 6
  b = 0
  c = -2

  eq "#{i for i in [a..b]}", '6,5,4,3,2,1,0'
  eq "#{i for i in [a..b] by c}", '6,4,2,0'


test "Multiline array comprehension with filter.", ->

  evens = for num in [1, 2, 3, 4, 5, 6] when not (num & 1)
             num *= -1
             num -= 2
             num * -1
  eq evens + '', '4,6,8'


  test "The in operator still works, standalone.", ->

    ok 2 of evens


test "all isn't reserved.", ->

  all = 1


test "Ensure that the closure wrapper preserves local variables.", ->

  obj = {}

  for method in ['one', 'two', 'three'] then do (method) ->
    obj[method] = ->
      "I'm " + method

  ok obj.one()   is "I'm one"
  ok obj.two()   is "I'm two"
  ok obj.three() is "I'm three"


test "Index values at the end of a loop.", ->

  i = 0
  for i in [1..3]
    -> 'func'
    break if false
  ok i is 4


test "Ensure that local variables are closed over for range comprehensions.", ->

  funcs = for i in [1..3]
    do (i) ->
      -> -i

  eq (func() for func in funcs).join(' '), '-1 -2 -3'
  ok i is 4


test "Even when referenced in the filter.", ->

  list = ['one', 'two', 'three']

  methods = for num, i in list when num isnt 'two' and i isnt 1
    do (num, i) ->
      -> num + ' ' + i

  ok methods.length is 2
  ok methods[0]() is 'one 0'
  ok methods[1]() is 'three 2'


test "Even a convoluted one.", ->

  funcs = []

  for i in [1..3]
    do (i) ->
      x = i * 2
      ((z)->
        funcs.push -> z + ' ' + i
      )(x)

  ok (func() for func in funcs).join(', ') is '2 1, 4 2, 6 3'

  funcs = []

  results = for i in [1..3]
    do (i) ->
      z = (x * 3 for x in [1..i])
      ((a, b, c) -> [a, b, c].join(' ')).apply this, z

  ok results.join(', ') is '3  , 3 6 , 3 6 9'


test "Naked ranges are expanded into arrays.", ->

  array = [0..10]
  ok(num % 2 is 0 for num in array by 2)


test "Nested shared scopes.", ->

  foo = ->
    for i in [0..7]
      do (i) ->
        for j in [0..7]
          do (j) ->
            -> i + j

  eq foo()[3][4](), 7


test "Scoped loop pattern matching.", ->

  a = [[0], [1]]
  funcs = []

  for [v] in a
    do (v) ->
      funcs.push -> v

  eq funcs[0](), 0
  eq funcs[1](), 1


test "Nested comprehensions.", ->

  multiLiner =
    for x in [3..5]
      for y in [3..5]
        [x, y]

  singleLiner =
    (([x, y] for y in [3..5]) for x in [3..5])

  ok multiLiner.length is singleLiner.length
  ok 5 is multiLiner[2][2][1]
  ok 5 is singleLiner[2][2][1]


test "Comprehensions within parentheses.", ->

  result = null
  store = (obj) -> result = obj
  store (x * 2 for x in [3, 2, 1])

  ok result.join(' ') is '6 4 2'


test "Closure-wrapped comprehensions that refer to the 'arguments' object.", ->

  expr = ->
    result = (item * item for item in arguments)

  ok expr(2, 4, 8).join(' ') is '4 16 64'


test "Fast object comprehensions over all properties, including prototypal ones.", ->

  class Cat
    constructor: -> @name = 'Whiskers'
    breed: 'tabby'
    hair:  'cream'

  whiskers = new Cat
  own = (value for own key, value of whiskers)
  all = (value for key, value of whiskers)

  ok own.join(' ') is 'Whiskers'
  ok all.sort().join(' ') is 'Whiskers cream tabby'


test "Optimized range comprehensions.", ->

  exxes = ('x' for [0...10])
  ok exxes.join(' ') is 'x x x x x x x x x x'


test "Comprehensions safely redeclare parameters if they're not present in closest scope.", ->

  rule = (x) -> x

  learn = ->
    rule for rule in [1, 2, 3]

  ok learn().join(' ') is '1 2 3'

  ok rule(101) is 101

  f = -> [-> ok no, 'should cache source']
  ok yes for k of [f] = f()


test "Lenient on pure statements not trying to reach out of the closure", ->

  val = for i in [1]
    for j in [] then break
    i
  ok val[0] is i


test "Comprehensions only wrap their last line in a closure, allowing other lines
  to have pure expressions in them.", ->

  func = -> for i in [1]
    break if i is 2
    j for j in [1]

  ok func()[0][0] is 1

  i = 6
  odds = while i--
    continue unless i & 1
    i

  ok odds.join(', ') is '5, 3, 1'


test "Issue #897: Ensure that plucked function variables aren't leaked.", ->

  facets = {}
  list = ['one', 'two']

  (->
    for entity in list
      facets[entity] = -> entity
  )()

  eq typeof entity, 'undefined'
  eq facets['two'](), 'two'


test "Issue #905. Soaks as the for loop subject.", ->

  a = {b: {c: [1, 2, 3]}}
  for d in a.b?.c
    e = d

  eq e, 3


test "Issue #948. Capturing loop variables.", ->

  funcs = []
  list  = ->
    [1, 2, 3]

  for y in list()
    do (y) ->
      z = y
      funcs.push -> "y is #{y} and z is #{z}"

  eq funcs[1](), "y is 2 and z is 2"


test "Cancel the comprehension if there's a jump inside the loop.", ->

  result = try
    for i in [0...10]
      continue if i < 5
    i

  eq result, 10


test "Comprehensions over break.", ->

  arrayEq (break for [1..10]), []


test "Comprehensions over continue.", ->

  arrayEq (continue for [1..10]), []


test "Comprehensions over function literals.", ->

  a = 0
  for f in [-> a = 1]
    do (f) ->
      do f

  eq a, 1


test "Comprehensions that mention arguments.", ->

  list = [arguments: 10]
  args = for f in list
    do (f) ->
      f.arguments
  eq args[0], 10


test "expression conversion under explicit returns", ->
  nonce = {}
  fn = ->
    return (nonce for x in [1,2,3])
  arrayEq [nonce,nonce,nonce], fn()
  fn = ->
    return [nonce for x in [1,2,3]][0]
  arrayEq [nonce,nonce,nonce], fn()
  fn = ->
    return [(nonce for x in [1..3])][0]
  arrayEq [nonce,nonce,nonce], fn()


test "implicit destructuring assignment in object of objects", ->
  a={}; b={}; c={}
  obj = {
    a: { d: a },
    b: { d: b }
    c: { d: c }
  }
  result = ([y,z] for y, { d: z } of obj)
  arrayEq [['a',a],['b',b],['c',c]], result


test "implicit destructuring assignment in array of objects", ->
  a={}; b={}; c={}; d={}; e={}; f={}
  arr = [
    { a: a, b: { c: b } },
    { a: c, b: { c: d } },
    { a: e, b: { c: f } }
  ]
  result = ([y,z] for { a: y, b: { c: z } } in arr)
  arrayEq [[a,b],[c,d],[e,f]], result


test "implicit destructuring assignment in array of arrays", ->
  a={}; b={}; c={}; d={}; e={}; f={}
  arr = [[a, [b]], [c, [d]], [e, [f]]]
  result = ([y,z] for [y, [z]] in arr)
  arrayEq [[a,b],[c,d],[e,f]], result

test "issue #1124: don't assign a variable in two scopes", ->
  lista = [1, 2, 3, 4, 5]
  listb = (_i + 1 for _i in lista)
  arrayEq [2, 3, 4, 5, 6], listb

test "#1326: `by` value is uncached", ->
  a = [0,1,2]
  fi = gi = hi = 0
  f = -> ++fi
  g = -> ++gi
  h = -> ++hi

  forCompile = []
  rangeCompileSimple = []

  #exercises For.compile
  for v,i in a by f() then forCompile.push i

  #exercises Range.compileSimple
  rangeCompileSimple = (i for i in [0..2] by g())

  arrayEq a, forCompile
  arrayEq a, rangeCompileSimple
  #exercises Range.compile
  eq "#{i for i in [0..2] by h()}", '0,1,2'

test "#1669: break/continue should skip the result only for that branch", ->
  ns = for n in [0..99]
    if n > 9
      break
    else if n & 1
      continue
    else
      n
  eq "#{ns}", '0,2,4,6,8'

  # `else undefined` is implied.
  ns = for n in [1..9]
    if n % 2
      continue unless n % 5
      n
  eq "#{ns}", "1,,3,,,7,,9"

  # Ditto.
  ns = for n in [1..9]
    switch
      when n % 2
        continue unless n % 5
        n
  eq "#{ns}", "1,,3,,,7,,9"
