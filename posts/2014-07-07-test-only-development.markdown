---
title: '"Test-Only Development" with the Z3 Theorem Prover'
tags: z3, theorem provers, testing
---

In this post I'll introduce a style of programming which may be totally unfamiliar and perhaps a bit magical to many readers. What if you could write a unit test for a problem and have your compiler automatically return a correct implementation? Call it "test only" instead of "test first." I'm going to translate the problem itself into a specification language and use Microsoft Research's [Z3 theorem prover](http://rise4fun.com/z3) to find a solution. I won't write any implementation code at all!

## A Simple Problem

Here's the problem I'll use as an example, which is [problem #4 from Project Euler](https://projecteuler.net/problem=4):

> A palindromic number reads the same both ways. The largest palindrome made from the product of two 2-digit numbers is 9009 = 91 × 99.

Find the largest palindrome made from the product of two 3-digit numbers.

The usual approach is to use brute force. Here's a C# example, which I suspect is similar to what many people do:

```cs
(from    factor1 in Enumerable.Range(100, 899)
 from    factor2 in Enumerable.Range(100, 899)
 let     product = factor1 * factor2
 where   IsPalindrome(product) // defined elsewhere
 orderby product descending
 select  new { Factor1 = factor1, Factor2 = factor2, Product = product}).First()
```

This is not a terrible solution. It runs pretty quickly and returns the correct solution, and we can see opportunities for making it more efficient. I suspect most people would declare the problem finished and move on.

However, the LINQ syntax may obscure the fact that this is still a brute force solution. Any time we have to think about how to instruct a computer to find the answer to the problem instead of the characteristics of the problem itself, we add cognitive overhead and increase the chances of making a mistake.

Also, what is that `IsPalindrome(product)` hiding? Most people implement this by converting the number to a string, and comparing it with the reversed value. But it turns out that the mathematical properties of a palindromic number are critical to finding an efficient solution.

Indeed, you can solve this problem fairly quickly with pencil and paper so long as you don't do `IsPalindrome` this way! (It would probably double the length of this post to explain how, so I'll skip that. If there's demand in comments I can explain, otherwise just read on.)

## Solving with Pure Specification

For my purely declarative solution, I'm going to use the language [SMT-LIB](http://smt-lib.org/). As a pure specification language, it doesn't allow me to define an implementation at all! Instead, I'll use it to express the constraints of the problem, and then use MSR's Z3 solver to find a solution. SMT-LIB uses Lisp-like S-expressions, so, yes Virginia, there will be parentheses, but don't let that scare you off. It's always worthwhile to learn languages which make you think about problems differently, and I think you'll find SMT-LIB really delivers!

Since this language will seem unusual to many readers, let's walk through the problem step by step.

First, we need to declare some of the variables used in the problem. I use "variable" here in the mathematical, rather than software, sense: A placeholder for an unknown, but not something to which I'll be assigning varying values. So here are three variables roughly equivalent to the corresponding C# vars above:

```commonlisp
(declare-const product Int)
(declare-const factor1 Int)
(declare-const factor2 Int)
```

In an S-expression, the first item inside the parentheses is the function, and the remaining items are arguments. So `declare-const` is the function here and the remaining items are the variable name and its "sort" (type).

Next, the problem says that `product` must be the, ahem, product of the two factors:

```commonlisp
(assert (= (* factor1 factor2) product))
```

"`assert`" sounds like a unit test, doesn't it? Indeed, many people coming to a theorem prover from a software development background will find that programming them is much more similar to writing tests than writing code. The line above just says that `factor1 * factor2 = product`. But it's an assertion, not an assignment; we haven't specified values for any of these variables.

The problem statement says that both factors are three digit numbers:

```commonlisp
(assert (and (>= factor1 100) (<= factor1 999)))
(assert (and (>= factor2 100) (<= factor2 999)))
```

Mathematically, what does it mean for a number to be a palindrome? In this case, the largest product of 3 digit numbers is going to be a six digit number of the form **abccba**, so product = 100000**a** + 10000**b** + 1000**c** + 100**c** + 10**b** + **a**. As I noted above, expressing the relationship this way is key to finding a non-brute-force solution using algebra. But you don't need to know that in order to use Z3, because Z3 knows algebra! All you need to know is that you should express relationships mathematically instead of using string manipulation.

```commonlisp
(declare-const a Int)
(declare-const b Int)
(declare-const c Int)
(assert (= product (+ (* 100000 a) (* 10000 b) (* 1000 c) (* 100 c) (* 10 b) a)))
```

I implied above that **a**, **b**, and **c** are single-digit numbers, so we need to be specific about that. Also, **a** can't be 0 or we won't have a 6 digit number.

```commonlisp
(assert (and (>= a 1) (<= a 9)))
(assert (and (>= b 0) (<= b 9)))
(assert (and (>= c 0) (<= c 9)))
```

These 4 assertions about a, b, and c are enough to determine that product is a palindrome. We're not quite done yet, but let's see how we're doing so far. `(check-sat)` asks Z3 if there is a solution to the problem we've posed, and `(get-model)` displays that solution. Here's the entire script so far:

```commonlisp
(declare-const product Int)
(declare-const factor1 Int)
(declare-const factor2 Int)

(assert (and (>= factor1 100) (< factor1 1000)))
(assert (and (>= factor2 100) (< factor2 1000)))
(assert (= (* factor1 factor2) product))

(declare-const a Int)
(declare-const b Int)
(declare-const c Int)

(assert (and (>= a 1) (<= a 9)))
(assert (and (>= b 0) (<= b 9)))
(assert (and (>= c 0) (<= c 9)))
(assert (= product (+ (* 100000 a) (* 10000 b) (* 1000 c) (* 100 c) (* 10 b) a)))

(check-sat)
(get-model)
```

When you run this through Z3 ([try it yourself!](http://rise4fun.com/z3)), the solver responds:

```commonlisp
sat

(model
  (define-fun c () Int
    1)
  (define-fun b () Int
    0)
  (define-fun a () Int
    1)
  (define-fun product () Int
    101101)
  (define-fun factor2 () Int
    143)
  (define-fun factor1 () Int
    707)
)
```

That's pretty good! `sat`, here, means that Z3 found a solution (it would have displayed `unsat` if it hadn't). Eliding some of the syntax, the solution it found was 143 * 707 = 101101. Not bad for zero implementation code, but also not the answer to the Project Euler problem, which asks for the largest product.

## Optimization

"Optimization," in Z3 parlance, refers to finding the "best" proof for the theorem, not doing it as quickly as possible. But how do we tell Z3 to find the largest product?

Z3 has a function called `maximize`, but it's a bit limited. If I try adding `(maximize product)`, Z3 complains:

> Z3(15, 10): ERROR: Objective function '(* factor1 factor2)' is not supported

After some fiddling, however, it seems (maximize (+ factor1 factor2)) works, sort of. Adding this to the script above causes Z3 to return:

```commonlisp
(+ factor1 factor2) |-> [1282:oo]

unknown --...
```

Which is to say, Z3 could not find the maximal value. ("oo" just means ∞, and `unknown` means it could neither prove nor disprove the theorem.) Guessing that a might be bigger than 1, I can change its range to 8..9 and Z3 arrives at a single solution:

```commonlisp
(+ factor1 factor2) |-> 1906

sat

(model
  (define-fun b () Int
    0)
  (define-fun c () Int
    6)
  (define-fun factor1 () Int
    913)
  (define-fun factor2 () Int
    993)
  (define-fun a () Int
    9)
  (define-fun product () Int
    906609)
)
```


The final script is:

```commonlisp
(declare-const product Int)
(declare-const factor1 Int)
(declare-const factor2 Int)

(assert (and (>= factor1 100) (< factor1 1000)))
(assert (and (>= factor2 100) (< factor2 1000)))
(assert (= (* factor1 factor2) product))

(declare-const a Int)
(declare-const b Int)
(declare-const c Int)

(assert (and (>= a 8 ) (<= a 9)))
(assert (and (>= b 0) (<= b 9)))
(assert (and (>= c 0) (<= c 9)))
(assert (= product (+ (* 100000 a) (* 10000 b) (* 1000 c) (* 100 c) (* 10 b) a)))

(maximize (+ factor1 factor2))

(check-sat)
(get-model)
```

This bothers me just a little, since I had to lie ever so slightly about my objective, even though I did end up with the right answer.

That's just a limitation of Z3, and it may be fixed some day; Z3 is under active development, and [the optimization features are not even in the unstable or master branches](http://rise4fun.com/Z3/tutorial/optimization). But think about what has been achieved here: We've solved a problem with nothing but statements about the properties of the correct answer, and without any "implementation" code whatsoever. Also, using this technique forced me to think deeply about what the problem actually meant.
Can This Be Real?

At this point, you may have questions about doing software development in this way. Sure, it works fine for this trivial problem, but can you solve real-world problems this way? Is it fast? Are there any other tools with similar features? What are the downsides of working in this way? You may find the answers to these questions as surprising as the code above. Stay tuned!
