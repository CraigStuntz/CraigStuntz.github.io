---
title: "A Very Gentle Introduction to Type Checking, Chapter 1.1: "
series: A Very Gentle Introduction to Type Checking
chapter: "1.1"
chapterName: The Untyped Lambda Calculus (and Friends!)
tags: compilers, type checking
---

<div class="toc">
* Introduction: Type checkin'
* 1: The Untyped Lambda Calculus
  * 1.1: What Even Is The Untyped Lambda Calculus (Etc.)?
</div>

Today we will be learning about the untyped lambda calculus (and friends!). As
the name suggests, building a type checker for the untyped lambda calculus would
be rather useless, as there is only one type in the language and therefore any 
syntactically valid program would type check: there are no type errors, only 
syntax errors. Instead we will use this language to learn about
**normalization by evaluation**, which will be used when we build a type checker for
the simply typed lambda calculus (part 2) and *necessary* when we build a
type checker for Tartlet (part 3).

This will be a long post because there are a lot of concepts 
introduced here! Feel free to skip the sections on any concepts you are already
comfortable with! Heck, skip the whole thing if you'd rather just dive into the
code. 

My plan is that in each section of this series I'm going to give enough 
information that a programmer can understand a section of David's 
tutorial. My goal for this post is to get you through the title and the first 
few paragraphs.

## The Plan for Learning

A type checker needs to look an expression and find its type and then evaluate 
whether that type is compatible (equivalent) with the type it expecting in a 
certain situation. For example, if a function's argument is typed `Int` then it
must look at the expression given for the argument at the point where that function is invoked 
and determine if the type of that expression is equivalent to `Int`. Because this
expression could be a literal `Int`, a variable of type `Int`, the result of another
function which returns an `Int`, or some supertype of `Int` allowed by the programming language, this is
more complicated in practice than it might seem and it will be easier if we can 
first **normalize** (simplify) the expression.

Some of the concepts we will discuss in this section are both rather difficult 
to mentally evaluate and not necessary to understand when building a type 
checker. (I'm looking at you, Church numerals.) One possible approach is to skim these sections, don't 
spend too much time trying to wrap your head around them, and just accept that the
expected values we will use in unit tests are correct. I hope to give you enough 
information to distinguish between correct and incorrect outcomes even if you 
don't mentally evaluate the Church numerals we will program in the untyped lambda
calculus, which is rather challenging. This is a valid way to learn as building 
a type checker
depends on understanding normalization but does not depend on understanding 
Church numerals.

Another thing that you could do is spend time deeply understanding each section 
before moving on. That's a valid choice if you have the time! The best part is 
that it's *your* choice; either way should work fine insofar as getting you to
the part where we actually build a type checker, which will come in the next 
section.

In this post we will start learning about normalizing expressions by evaluation,
which is a really, really important concept that you must understand in order to
complete the tutorial. David teaches this by building a normailzation system for
the untyped lambda calculus, and uses adding two Church encoded numbers together
as an example. It's less important that you understand every detail of this, but
you should at least grasp the broad outlines of what we're going to do. 

## The Annotated "Checking Dependent Types with Normalization by Evaluation"

Throughout this series, I will quote from David's tutorial, which I will put 
in a yellow box, like this:

<div class="highlight">
**Checking Dependent Types with Normalization by Evaluation**

To implement dependent types, we need to be able to determine when two types 
are the same. In simple type systems, this process is a fairly straightforward 
structural equality check, but as the expressive power of a type system 
increases, this equality check becomes more difficult. 
</div>

<figure class="inlineRight">

```swift
implicit enum Type: Equatable {
  case int
  case boolean
  case list(Type)
}

let t1 = Type.int
let t2 = Type.int
assert(t1 == t2)

let t3 = Type.list(t1)
let t4 = Type.list(t2)
assert(t3 == t4)
```
<figcaption>Structural equality; different instances are equal when they contain 
the same values</figcaption>
</figure>

As noted earlier, if the only types your programming language contained were 
`Int` and `Boolean` then this would indeed be very easy. `Int == Int` and 
`Int != Boolean` and we're finished. However, even in the case of the "simple" 
language we'll be type checking we want to handle functions, recursion, type
annotations, etc., which requires a bit more care.

A "fairly straightforward structural equality check" means that we might need to 
do a comparison just slightly more complicated than `Int == Int` (for example, 
we might need to check equality on a sum type, which in Swift is known as 
[an `enum` with associated values](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/enumerations/#Associated-Values)), but we can still do this quite easily. In 
Swift you just add `: Equatable` to the `enum` definition and the compiler will
generate the necessary code for you to allow an `==` comparsion.

However, more complicated type systems (e.g., Swift includes subtyping and 
[convertibles](http://www.lithium3141.com/blog/2014/12/14/learning-swift-convertibles/)) 
will require an analysis which is a bit more 
complicated than just a simple structural equality check. This can be fairly 
subtle. 

## What Are Dependent Types?

It will be important to understand what dependent types are when we start 
building a type checker for Tartlet, which is the third and final part of the
tutorial. Fell free to skip this section and come back to it before you start
part 3.

<div class="highlight">
In particular, when types can contain programs, we need to be able to run 
these programs and check whether their outputs are the same. 
</div>

"...when types can contain programs" refers to dependent types. This is sort of
starting at the end; there will be a lot of material to cover before we get to 
a dependently typed language. But it's worth knowing what dependent types are.

Depending upon your point of view, dependent types are:

* The sort of types used by languages such as [Idris](https://www.idris-lang.org/), 
  [Agda](https://agda.readthedocs.io/en/latest/index.html), and [Lean](https://lean-lang.org/).
* A type system where types can include a value. The classic example is that 
  a list of length 0 is a different type than a list of length 1 --- the length
  of the list is a value and is part of the type.
* A programming language where there is no hard line between types and regular
  values; new types can be computed in the same way that new values can.
* A Turing complete type system, where arbitrary computations can be performed
  in the types, instead of just in the normal expressions.

All of these statements are correct.

The sort of type checker you had in mind to implement might not require checking 
dependent types; if you're going to write a type checker for Swift or Java, you
won't need them. (You will, however, need to deal with subtyping, which can be 
challenging.) The general technique of bidirectional type checking will 
still be useful even if dependent types aren't included in the programming 
language you're checking.

Speaking of which...

## What Is Bidirectional Type Checking?

Understanding bidirectional typechecking is whole point of the tutorial! 
However, we won't actually work on a bidirectional type checker until part 2.

<div class="highlight">
Normalization by evaluation is one way of performing this sameness check, 
while bidirectional type checking guides the invocation of the checks.
</div>

In the bad old days of statically typed programming languages, it was common to 
have languages where all types were checked, and none were inferred. (Think early 
versions of Java or C#.) This became painful and redundant, and programmers 
wondered if there was a better way. In fact there *was* a better way, as the 
programming language ML demonstrated in, um, 1973. It just took the rest of the
world a while to catch up. 

In many cases it is possible to **infer** types instead of checking them. This
can be taken to an extreme: In some programming languages such as Haskell or ML
there is not a strict requirement to ever declare a type. However, most 
programmers have found that not ever using any type annotations makes 
programming errors very difficult to diagnose, and so they will typically use a
style guide that requires use of type annotations on function declarations and
other places. Other programming languages, such as Swift and the current version
of C#, allow type inference in some places but *require* it on named function 
declarations. 

Bidirectional type checking combines type checking and type synthesis 
(inference) in a principled way. Sometimes, given an expression we can 
synthesize/infer its type. Other times we know what type we are expecting and 
need to confirm (check) that the expression has an equivalent type. 
Bidirectional type checking tells us whether we should be using type synthesis 
or type checking in any given context.

For example, if we enounter a variable at a use site (in other words, after it 
is declared), we can synthesize the type by looking up
the variable in the context, or list of variables in scope. In other cases, we
must check the type against some existing type, for example if there is a 
function call in code then we must check that we are in fact calling a reference
of a function type (and not, say, an integer). Bidirectional type checking makes 
it clear whether we should use synthesis or checking in any situation we might 
encounter in code. By doing so, it is a guideline for how to write
a type checker which is sufficiently powerful to implement most features needed
by contemporary programming languages, including some with advanced type
systems.

## What Is Normalization?

Understanding normalization is the goal of part 1. First I will explain it 
conceptually; later we will write some code and see how it works in practice. 

We are going to learn how to take an expression and 
convert it to a "simpler" form, called the **normal form**, in a process called 
**normalization**. The reason we need to do this is we have to decide if the type 
of an expression is equivalent to the type that we are expecting. This is easier
if the expression is in the simplest possible form.

### A Very Simple Example

That's a little abstract, so let's look at an example from Swift:

```swift
let zero: Int = 0;

func increment(n: Int) -> Int {
    return n + 1
}

let one = increment(n: zero)
```

So far, so good, but of course we could have written `one` as:

```swift
let one: Int = 1 // because increment(n: zero) == 1
```

You might prefer one version of the *source code,* but in fact both versions are
the same *value* in the end. We call the second version, with the literal `1`, the 
**normalized** version because it is "less complicated" than the version with 
the function call to `increment`. We will formalize the definition of "less 
complicated" in the near future.

### What Is the Point of Normalization?

When writing a type checker it is easier to look at simpler forms, and in this
example the literal value `1` is simpler than the result of a function call. 

When you are type checking a call to some function, you need to decide if it's 
legal to call that function with a given argument value. With the untyped lambda 
calculus, which we will meet below, the answer is clearly "yes" because there 
is only one type, so there is no need to type check at all. So why will we be 
dealing with the untyped lambda calculus in a type checking tutorial at all? 
Well, peeking ahead a little, we will want to look two types (say, the 
argument type required by a function and the type of the expression we're 
attempting to pass as that argument) and decide if they're "equivalent." We will 
do this by normalizing an expression
first and then doing an equivalence comparison on it, so first we must learn to
normalize!

### A Slightly More Complicated Example

When calling `increment` we want to pass a value, which we store in the variable `zero`
and pass as the `n` argument. `zero` is a variable of type `Int` and in fact contains an 
instance of type `Int`, so the type check should be successful. 

Should this type check?

```swift
let three = increment(n: increment(n: increment(n: zero)))
```

If you've been programming for a while I think you'll agree that the answer is
"yes," but it's not quite so simple for the type checker to answer. In this case
we must know that we are allowed to pass a function call, with all required 
arguments, in a place that requires a value with the same type as the function 
call's result. The type checker must also check the entire stack of function 
calls in order to make sure everything is correct. Even in this simple example
that's not a trivial task, and we will be considering far more complicated cases
before the end of this series.

Happily, as with most things in compiler design, there are "recipes" you can 
follow to solve such problems reliably!

### Ok, But What Is 'Normalization By Evaluation'

Evaluation means just what you think it does, if you've studied compilers or 
have used a language with an `eval` function. We will interpret the syntax of 
the code and by doing so reduce it to a "simpler" form. For example, references
to a variable will be substituted with the value of that variable.

If you evaluate the expression above, you get a normalized form, which is:

```swift
let three: Int = 3
```

We normally think of such evaluations as happening at runtime, but this is not
strictly correct. There is no reason the example given can't be evaluated at 
compile time and in fact in most languages the optimizer will do exactly that 
for such simple arithmetic. We can also perform such evaluation *before* 
optimization when needed.

It will be much easier to do type compatibility checks when all of our code is
in normalized form!

I'm not going to discuss this much more for now because we will cover it in 
great detail in the near future, but I just want to put into your mind the idea
that evaluating an expression will result in it eventually becoming normalized,
because that is in fact true.[^NbE]

We can't always evaluate a function at compile time like this; some function 
results depend on values which are unknown until runtime. But we can do it often
enough to be helpful, and in particular we can do it when type checking dependent types.

## What Even Is the Untyped Lambda Calculus?

<div class="highlight">
*1 Evaluating Untyped λ-Calculus*

Let’s start with an evaluator for the untyped λ-calculus. 
</div>

In order to demonstrate normalization by evaluation, we will begin with 
something called "the untyped lambda calculus."
Don't be put off by the Greek letters or a mention of "calculus"; we will not be 
computing integrals here! It's worth knowing just a little bit about the untyped
lambda calculus so that you recognize what is going on in the examples which we
will use, but if you find yourself puzzling out individual derivations, just 
know that it's not really necessary to understand the type checker which we are
building. 

You can look at the untyped lambda calculus as a very tiny programming language, or you 
can look at it as an alternate model of computation. Both are correct views. There is only one data 
type, which is an anonymous function taking a single argument and returning a
single value. The type of this argument and returned value are, naturally, 
anonymous functions taking a single argument and returning a single value. 
*There are no other types.*

Sometimes people say that programming languages would be easier to learn if they
had a simple core with fewer features. That might be right in some cases, but
the untyped lambda calculus shows that there is a bottom bound to this idea. 
There is basically *one* feature in the whole language, and it's quite difficult
to write any meaningful programs in. However, it's quite simple to write an 
expression evaluator for it due to its simplicity, and as that is what we are 
aiming to do it is a good choice for our purposes. Still, this section is a bit
complicated if it's your first exposure to the untyped lambda calculus![^lambda]

### The Simplest Value In the Untyped Lambda Calculus

Let's consider the simplest possible value in the untyped lambda caculus, the 
identity function. It just returns the value of its argument. Values in the 
untyped lambda calculus start with the Greek lower-case lambda, `λ`, then they
have an arugment name, by convention a single lower-case character, and then a 
dot (`.`), followed by the body of the function. So the identity function looks 
like this:

```
λx.x
```

Think: "An anonymous function that when called with some value `x` returns that value `x`.
(In Swift it would look like `{ x in x }`; in JavaScript it would look like 
`x => x`).

It's hard to even consider this in terms of other programming languages, which 
have, you know, integers, and booleans and stuff, because the untyped lambda 
calculus very much does not have types for integers and booleans and stuff. 
However, you can use these functions to perform computations which are the same 
as in languages which *do* have those features.[^TuringComplete]

<div class="highlight">
Writing an evaluator requires the following steps:

* Identify the values that are to be the result of evaluation
* Figure out which expressions become values immediately, and which require 
  computation
* Implement structs for the values, and use procedures for computation

In this case, for the untyped λ-calculus, the only values available are 
closures, and computation occurs when a closure is applied to another value.
</div>

Writing an evaluator means we will be interpreting the untyped lambda calculus. 
If you're into compilers this should be familiar territory. We will be starting 
with the code we are evaluating in the untyped lambda calculus "already parsed" 
into an abstract syntax tree (AST); that is, the input to our evaluator will be 
AST expressions instead of strings. But we require additional types 
to hold values as we evaluate that AST. 

You may have encountered the term 
[**closure**](https://en.wikipedia.org/wiki/Closure_(computer_programming)) before,
but it's a combination of a function and an environment which may include both
bound variables (arguments to the function) and free variables (variables which
are defined externally to the function's body).

"when a closure is applied to another value" means when the closure is invoked 
using another value as an argument.

## What Even Is a Natural Number?

If you want to do something more complicated in your program in the untyped 
lambda calculus, like add two numbers together, then you have to stop and think
about how you're going to represent numbers in a programming language which 
doesn't have them.

The type of number that we're going to use is a **natural number**, and by this 
we mean a number which is in the set $\{0, 1, 2, ..., \infty \}$.[^natural] However, we 
are going to have to think about how to represent these using anonymous 
functions!

Swift doesn't have a type like this. It has `UInt64`, but there are obviously
values too large to store in a `UInt64`. It turns out that this really matters,
because the type of `increment` above is actually a bit more complicated than "Int".
It actually means "an `Int` or perhaps it might throw an exception due to a numeric
overflow."

```bash
➜ swift repl  
Welcome to Apple Swift version 5.10 (swiftlang-5.10.0.13 clang-1500.3.9.4).
Type :help for assistance.
  1> func increment(n: Int) -> Int { return n + 1 }
  2> increment(n: Int.max)
Execution interrupted. Enter code to recover and continue.
Enter LLDB commands to investigate (type :help for assistance.)
  3>  
```

You might think I'm being overly picky here, but a type checker must understand
every possible case for the types in use. Does this mean that Swift is unsound?
Not really, this notion of "or may throw a numeric overflow exception" is built
into the language, and makes the language design and implementation somewhat 
more difficult. Real languages have complicated types! Again, we will be 
starting with a simpler language.

## What Even Is a Church Numeral?

You do not need to understand Church numerals to complete the tutorial. 

The type checker must solve a problem which is very similar to the optimizer: Is
it safe to replace one expression with a different expression, in every possible 
case? As we have seen with `increment` above, this can be a pertty subtle question,
with edge cases which are not obvious from looking at source code. 

How can we 
be sure that saying that a number is "a natural number" means that it can be 
used *anywhere* a program expects a natural number to be used? Also, how can we
represent natural numbers in a language which has functions as its sole data 
type?

It would help if instead of considering, well, $\infty$ cases, we could cut that
list down a bit. And for the type of natural numbers, we can in fact cut it down
to only two cases:

* `zero`
* `add1 n`  
   
`add1` means "given some value `n` which is certainly a natural number, the next 
largest value, $n + 1$."[^Succ]

So (in Swift) we can literally have a data type like:

```swift
indirect enum Nat {
    case zero
    case add1(Nat)
}
```

And now Swift has a "natural numbers" data type! You can store any natural number in 
this type, although you may eventually run out of memory.

### Church Numerals In the Untyped Lambda Calculus

But we're not here to learn Swift right now, and we aren't even trying to 
produce a tutorial for the untyped lambda calculus. Instead we just need enough
exposure to it to know if our evaluator is working correctly.

We can represent the natural numbers in the untyped lambda calculus as follows:[^whythesefunctions]

```
zero = λf.λx.x
add1 = λn.λf.λx.f (n f x)
```

This implies that, for example, `one` (a function representhing the natural 
number `1`) is:

```
one = add1 zero 
    = λf.λx.f x
```

We will see the full derivation below. 

There are more examples; hopefully you can start to see a pattern here:

```
zero  = λf.λx.x
one   = λf.λx.f x
two   = λf.λx.f(f x)
three = λf.λx.f(f(f x))
four  = λf.λx.f(f(f(f x)))
five  = λf.λx.f(f(f(f(f x))))
```

Here is the worked out version of `add1 zero`. (Don't worry if you can't follow 
this derivation; we have computers to do this for us):

```
one = add1 zero                                   because 1 = 1 + 0
    = (λn.λf.λx.f (n f x)) (λf.λx.x)              substitute defintions of add1 and zero
    = λf.λx.f λf.λx.x f x                         substitute λf.λx.x for argument n
    = λf.λx.f λf.f x                              because (λx.x) f = f
    = λf.λx.f x                                   because (λf.f) x = x
```

This way of storing natural numbers is sometimes called a 
"[Church numeral](https://en.wikipedia.org/wiki/Church_encoding#Church_numerals)."
And this simplification of `add1 zero` into `λf.λx.f x` is exactly the sort of 
evaluation we will be performing as part of "normalization by evaluation." 
Clearly it's a pain to do this by hand, so we will be writing an expression 
evaluator to do it for us!

The way to think about Church numerals as expressed in the functions above is 
that when invoked they run a function, call it `f`, as many times as the 
numeral. So `zero`, above, *never evaluates* `f` and so runs it *zero* times. 
But `one` must evaluates `f` *once* when invoked. And so on for larger numbers. 

Another handy function is `plus`:

```
plus = λj.λk.λf.λx.(j f) (k f x)
```

And in particular, we will be evaluating this specific expression in the 
tutorial:

```
plus two three = five
```

That is to say:

```
plus (λf.λx.f(f x)) (λf.λx.f(f(f x))) = λf.λx.f(f(f(f(f x))))
```

I am not going to try to derive this by hand and I don't think there's much to 
be gained by doing so unless you intend to study the untyped lambda calculus, 
which isn't really the point of what we are doing here. Our goal is to build a
type checker, and this is just a step along the way. If we can take the 
expression `plus two three` and evaluate it and get `λf.λx.f(f(f(f(f x))))` from
our evaluator then we know that it is working and produces an expression in normal
(simplest) form.

### Why, Why, Why for the Love of Church, Why?

Of course, representing a number like `1000` would seem to be a little bit 
involved given such an encoding, but on the positive side we have made such 
values much easier to type check: There are only two cases! (`zero` and `add1`.)

What the point of all this is? Why not just 
use better known data types from better known languages? We could do that, but
the implementation would be far more complicated, as "real" programming 
languages tend to have many more special cases and exceptions in their 
semantics (for example, numeric exceptions, implicit conversions, function 
overloading, etc.). The languages and data types used in this tutorial are 
explicitly designed to be (extremely!) minimal and easy to reason about. For example, with a 
Church encoded natural number, if you can prove a statement about only two 
cases, `zero` and `add1(n)` where `n` is any natural number, then you have 
proven the statement about *every* natural number, all $\infty$ of them!

## Abstract Syntax Trees

We will not be doing any parsing in this series. This makes some things easier
and some things more complicated. On the plus side, there's no need to write a
parser! On the less convenient side, when we want to deal with source code in
our programs we must write it in a "pre-parsed" state, which is an abstract 
syntax tree (AST). 

For example, in the untyped lambda calculus we might write the identity function
as:

```
λx.x
```

However this line of code written as an abstract syntax tree in Swift would be:

```swift
Expr.lambda("x", .variable("x"))
```

...which is somewhat more challenging to mentally parse. Because of this I will
usually put the "unparsed" (literal source code version) in comments near the 
"parsed" (AST) version, like this:

```swift
//  id = λx.x
let id = Expr.lambda("x", .variable("x"))
```


[^NbE]: This is somewhat complicated to prove; see for example 
        [Normalization by Evaluation with Typed Abstract Syntax](https://tidsskrift.dk/brics/article/view/20473)
        for more information.

[^lambda]: One might fairly ask why David picked the untyped lambda calculus as 
           an example. Nothing in the tutorial depends on its use; it's just a 
           simple example here. The untyped lambda calculus is important in 
           theoretical computer science and so one can presume that folks coming 
           to the tutorial from a TCS background will be familiar with it 
           already. This is perhaps less true when people approach the tutorial 
           from a "practitioner"/commercial programmer background. However, the 
           untyped lambda calculus does have at least one thing going for it, 
           which is that it's very simple to evaluate. We will be doing that 
           very soon!

[^TuringComplete]: It turns out that the untyped lambda calculus is 
                   [Turing complete](https://www.youtube.com/watch?v=RPQD7-AOjMI), 
                   and can compute literally anything that any other programming 
                   language can express. However, we won't be making use of this 
                   fact in this series. 

[^natural]: Mathematicians, somewhat inconveniently, 
            [use two different definitions of "natural numbers,"](https://mathworld.wolfram.com/NaturalNumber.html) namely $\{0, 1, 2, ..., \infty \}$
            and $\{1, 2, 3, ..., \infty \}$. We (and, indeed, nearly all 
            computer scientists) will use only the former.

[^Succ]: It's more common to call `add1` by the name `succ`, for "successor,"
         but David uses `add1`, so I will follow his lead),

[^whythesefunctions]: Unless you are going to study the untyped lambda calculus 
                      _per se,_ it's not worth looking too deeply into why we 
                      are using these specific functions. For our purposes, it's 
                      enough to know that they will work for the specific 
                      example we will be evaulating with the evaluator that we 
                      are going to build.