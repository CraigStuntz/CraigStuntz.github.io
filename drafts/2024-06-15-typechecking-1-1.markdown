---
title: "A Very Gentle Introduction to Type Checking, Chapter 1.1: "
series: A Very Gentle Introduction to Type Checking
chapter: "1.1"
chapterName: The Untyped Lambda Calculus (and Friends)
tags: compilers, type checking
---

<div class="toc">
* Introduction: Type checkin'
* 1: The Untyped Lambda Calculus
  * 1.1: What Even Is The Untyped Lambda Calculus (Etc.)?
</div>

My plan is that in each section of this series I'm going to give enough 
information that a competent programmer can understand a section of David's 
tutorial. My goal for this post is to get you through the title and the first 
few paragraphs.

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
<figcaption>Structural equality</figcaption>
</figure>

As noted earlier, if the only types your programming language contained were 
`Int` and `Boolean` then this would indeed be very easy. `Int == Int` and 
`Int != Boolean` and we're finished. 

A "fairly straightforward structural equality check" means that we might need to 
do a comparison just slightly more complicated than `Int == Int` (for example, 
we might need to check equality on a sum type, which in Swift is known as 
[an `enum` with associated values](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/enumerations/#Associated-Values)), but we can still do this quite easily. In 
Swift you just add `: Equatable` to the `enum` definition and the compiler will
generate the necessary code for you. 

However, more complicated type systems (e.g., Swift includes subtyping and 
implicit type conversions) will require an analysis which is a bit more 
complicated than just a simple structural equality check. 

## What Are Dependent Types?

<div class="highlight">
In particular, when types can contain programs, we need to be able to run 
these programs and check whether their outputs are the same. 
</div>

"...when types can contain programs" refers to dependent types. This is sort of
starting at the end; there will be a lot of material to cover before we get to 
a dependently typed language. But it's worth knowing what dependent types are.

Depending upon your point of view, dependent types are:

* The sort of types used by languages such as Idris, Agda, and Lean.
* A type system where types can include a value. The classic example is that 
  a list of length 0 is a different type than a list of length 1.
* A programming language where there is no hard line between types and regular
  values; new types can be computed in the same way that new values can.
* A Turing complete type system, where arbitrary computations can be performed
  in the types, instead of just in the normal expressions.

The sort of type checker you had in mind to implement might not require checking 
dependent types; if you're going to write a type checker for Swift or Java, you
won't need them. (You will, however, need to deal with subtyping, which can be 
challenging.) The general technique of bidirectional type checking will 
still be useful even if dependent types aren't included in the programming 
language you're checking.

Speaking of which...

## What Is Bidirectional Type Checking?

<div class="highlight">
Normalization by evaluation is one way of performing this sameness check, 
while bidirectional type checking guides the invocation of the checks.
</div>

In the bad old days of statically typed programming languages, it was common to 
have languages where all types were checked, none were inferred. (Think early 
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
(inference) in a principled way. By doing so, it is a guideline for how to write
a type checker which is sufficiently powerful to implement most features needed
by contemporary programming languages, including some with very advanced type
systems.

## What Is Normalization?

The first thing we are going to do is to learn how to take an expression and 
convert it to a "simpler" form, called the normal form, in a process called 
**normalization**. The reason we need to do this is we have to decide if the type 
of an expression is equivalent to the type that we are expecting. This is easier
if the expression is in the simplest possible form. We will look at some 
examples in a second, but first let's consider the programming language we will
be type checking in this first section of the tutorial.

### What Is the Point of Normalization?

When you are type checking some function, you might need to decide if it's 
legal to call that function with some argument value. With the untyped lambda 
calculus, which we will meet below, the answer is clearly "yes" because there 
is only one type, so there is no need to type check at all. So why will we be 
dealing with the untyped lambda calculus in a type checking tutorial at all? 
Well, peeking ahead a little, we will want to look at a type and decide if it
is "equivalent" to some other type. We will do this by normalizing an expression
first and then doing an equivalence comparison on it, so first we must learn to
normalize!

### A Very Simple Example

That's a little abstract, so let's look at an example from Swift:

```swift
func add1(n: Int) -> Int {
    return n + 1
}

let zero: Int = 0;

let one = add1(n: zero)
```

When calling `add1` we want to pass a value, which we store in the variable `zero`
for the `n` argument. `zero` is a variable of type `Int` and in fact contains an 
instance of type `Int`, so the type check should be successful. 

### A Slightly More Complicated Example

Should this type check?

```swift
let three = add1(n: add1(n: add1(n: zero)))
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

I'm not going to discuss this much more for now because we will cover it in 
great detail in the near future, but I just want to put into your mind the idea
that evaluating an expression will result in it eventually becoming normalized,
because that is in fact true.

## What Even Is the Untyped Lambda Calculus?

<div class="highlight">
*1 Evaluating Untyped λ-Calculus*

Let’s start with an evaluator for the untyped λ-calculus. 
</div>

Swift's type system is a bit complicated, so rather than use Swift as an example
language, we will begin with something called "the untyped lambda calculus."
Don't be put off by a mention of "calculus"; we will not be computing integrals
here!

You can look at the untyped lambda calculus as a programming language, or you 
can look at it as an alternate model of computation. There is only one data 
type, which is an anonymous function taking a single argument and returning a
single value. The type of this argument and returned value are, naturally, 
anonymous functions taking a single argument and returning a single value. 

(It turns out that the untyped lambda calculus is 
[Turing complete](https://www.youtube.com/watch?v=RPQD7-AOjMI), and can 
compute literally anything that any other programming language can express. 
However, we won't be making use of this fact in this series.)

It's hard to even consider this in terms of other programming languages, which 
have, you know, integers, and booleans and stuff, but maybe think "What if 
Python had only assignments, the `lambda` keyword, function calls, and nothing 
else? We can make life just a 
little bit easier by having variables and top-level functions declared, but 
again, there will not be any other types besides functions taking a single 
argument and returning a single value. 

In Python, `lambda` creates an anonymous function with one argument returning a
result, so `lambda x: x` will return the value of its argument. So we could have:

```bash
$ python3
>>> # In the lambda calculus, we write:
>>> #   identity = λx.x
>>> # In Python, we write:
>>> identity = lambda x: x
>>> # They mean the same thing! Here's another example:
>>> #   another_identity = λx.(λy.y)x
>>> another_identity = lambda x: (lambda y: y)(x)
>>> # And another:
>>> #   not_identity = λx.λy.x
>>> not_identity = lambda x: lambda y: x
>>> # Let's try them out!
>>> # I'm going to pass an integer as a simple demonstration, but the untyped lambda 
>>> # calculus does not have an integer type.
>>> identity(1)
1
>>> another_identity(1)
1
>>> not_identity(1)
<function <lambda>.<locals>.<lambda> at 0x101283c40>
>>> not_identity(1)(2)
1
```

In case it's not obvious from the above, this is real Python code and works (try
it!), and `identity` and `another_identity` are
*equivalent functions*. Although their bodies are different, both return the 
value of whatever argument you pass to 
them. `not_identity` is a different function, and does not return its argument. 
Our goal for this section will be to be write code which is able to tell the 
difference between these functions (and others).

<div class="highlight">
Writing an evaluator requires the following steps:

* Identify the values that are to be the result of evaluation
* Figure out which expressions become values immediately, and which require 
  computation
* Implement structs for the values, and use procedures for computation

In this case, for the untyped λ-calculus, the only values available are 
closures, and computation occurs when a closure is applied to another value.
</div>

That sort of makes sense, but if you want to do something more complicated 
in your program, like add two numbers together, then you have to stop and think
about how you're going to represent numbers in a programming language which 
doesn't have them.

## What Even Is a Natural Number?

The type of number that we're going to use is a natural number, and by this we
mean a number which is in the set $\{0, 1, 2, ..., \infty \}$

Swift doesn't have a type like this. It has `UInt64`, but there are obviously
values too large to store in a `UInt64`. It turns out that this really matters,
because the type of `add1` above is actually a bit more complicated than "Int".
It's actually "an `Int` or perhaps it might throw an exception due to a numeric
overflow."

```bash
➜ swift repl  
Welcome to Apple Swift version 5.10 (swiftlang-5.10.0.13 clang-1500.3.9.4).
Type :help for assistance.
  1> Int.max
$R0: Int = 9223372036854775807
  2> func add1(n: Int) -> Int { return n + 1 }
  3> add1(n: Int.max)
Execution interrupted. Enter code to recover and continue.
Enter LLDB commands to investigate (type :help for assistance.)
  4>  
```

You might think I'm being overly picky here, but a type checker must understand
every possible case for the types in use. (Does this mean that Swift is unsound?
Not really, this notion of "or may throw a numeric overflow exception" is built
into the language, and makes the language design somewhat more difficult. Again,
we will be starting with a simpler language.)

## What Even Is a Church Numeral?

The type checker must solve a problem which is very similar to the optimizer: Is
it safe to replace one expression with a different expression, in every possible 
case? As we have seen with `add1` above, this can be a pertty subtle question,
with edge cases which are not obvious from looking at source code. How can we 
be sure that saying that a number is "a natural number" means that it can be 
used *anywhere* a program expects a natural number to be used? 

It would help if instead of considering, well, $\infty$ cases, we could cut that
list down a bit. And for the type of natural numbers, we can in fact cut it down
to only two cases:

* `zero`
* `succ n` (or `add1(n)` -- calling it `succ` is more common, but David uses 
  `add1`, so I will follow his lead), which means "given some value `n` which is 
  certainly a natural number, the next largest value, $n + 1$."

So we can literally have a data type like:

```swift
indirect enum Nat {
    case zero
    case add1(Nat)
}
```

And now Swift has a "natural numbers" data type! This way of storing natural 
numbers is sometimes called a 
"[Church numeral](https://en.wikipedia.org/wiki/Church_encoding#Church_numerals)."

## Why, Why, Why for the Love of Church, Why?

Of course, representing a number like `1000` would seem to be a little bit 
involved given such an encoding, but on the positive side we have made such 
values much easier to type check: There are only two cases!

What the point of all this is? Why not just 
use better known data types from better known languages? We could do that, but
the implementation would be far more complicated, as "real" programming 
languages tend to have many more special cases and exceptions in their 
semantics (for example, numeric exceptions, implicit conversions, function 
overloading, etc.). The languages and data types used in this tutorial are 
explicitly designed to be minimal and easy to reason about. For example, with a 
Church encoded natural number, if you can prove a statement about only two 
cases, `zero` and `add1(n)` where `n` is any natural number, then you have 
proven the statement about *every* natural number, all $\infty$ of them!

## Abstract Syntax Trees