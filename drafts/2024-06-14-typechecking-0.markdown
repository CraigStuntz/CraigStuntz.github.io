---
title: "A Very Gentle Introduction to Type Checking, Introudction"
series: A Very Gentle Introduction to Type Checking
chapter: "Introduction"
chapterName: Introduction
tags: compilers, type checking
---

<div class="toc">
* Introduction: Type checkin'
</div>

Compiler tutorials often start and end with parsing, and while parsing is very 
interesting, I think, there is more to writing a compiler than parsing syntax! 
In this series I'll be explaining how to type check (and infer types from) code.
Writing a compiler is a challenging problem, but there are recipes that you can
follow, and if you follow these recipes, then anyone with a bit of programming 
skill and some dedication can do it. Writing a typechecker is proving theorems 
about code, which *sounds* challanging, but again, *you can do it* by following a
recipe. 

A tutorial should be:

* Approachable, as in readable by someone without a CS degree.
* Thorough, as in covering at least the basics of most of what you want a type
  checker to do.
* Concise. There's a place for books like 
  [Types and Programming Languages](https://www.cis.upenn.edu/~bcpierce/tapl/), 
  but someone who just wants to write a type checker to learn about compilers 
  should not have to read and understand a college course to do so.
* Modern, because type checking has changed in the last 20 years and we don't 
  want to leave out contemporary techniques.

The best introduction to type checking, by the above criteria, that I know is called 
[Checking Dependent Types with Normalization by Evaluation: A Tutorial](https://davidchristiansen.dk/tutorials/nbe/),
by David Thrane Christiansen. However, it assumes a certain amout of knowledge
(for example: what even is the 'untyped lambda calculus' and what does 
'normalizing' it mean?), 
and I wanted to write an introduction "for newbies." So I will be following his
tutorial, but I will be adding a lot of explanations along the way. 

### But, Craig, You Annoy Me 🙄

Perhaps you find my annotations and additions too verbose. That's fine! Just 
[read David's tutorial](https://davidchristiansen.dk/tutorials/nbe/)! If you 
*can* understand it without further explanation, then that's the most efficient 
way to learn the material. My series is intended for people unfamiliar with some 
of the knowledge that is assumed in David's version.

## Type Equivalence

In order to learn to type check a program, you must learn how to decide whether
or not two types are equivalent, because a program type checks 
successfully when the type it is expecting in some place is "equivalent" to the 
type it actually got in that place.

This sounds really easy, and indeed if the only two types in your type system 
were `Int` and `Boolean` then it would be easy. But types con be 
considerably more complex than this, and in fact when we get to dependent types
we will see that there is *no general answer* to this question. However, we can 
answer the question often enough to make a compiler that works for most of the 
code that someone will want to write, and might time out when they do something 
extremely odd, but won't ever produce incorrect results.

## Meet the Languages

The tutorial will be in three sections. You should complete them *in order.*

|  Section/Language                         |  What You Will Learn                   |
| ----------------------------------------- | ---------------------------------------| 
| 1. Untyped Lambda Calculus                | Normalizing expressions                |
| 2. Simply Typed Lambda Calculus           | Type checking and type inferencing     |
| 3. Tartlet (A Dependently Typed Language) | Equivalence, dependent types           |

Each section we will implement a different language. We will learn how to type 
check the simply typed lambda calculus before Tartlet because it is easier to do 
that than to type check Tartlet, and type checking Tartlet is easier than type 
checking Swift. You 
have to crawl before you can walk, as they say. But the principles we explore 
here should be helpful to you if you go farther, and, as we will see when we get
into dependent typing, there is some real sophistication in this material. 

The langauge Tartlet is a *toy language* which "is very much like the language 
Pie from [the book] [*The Little Typer,*](https://thelittletyper.com/) except it 
has fewer features and simpler rules."

The language Pie will not be used in this tutorial. However, it can be nice to 
have Pie around if you'd like to try out Pie/Tartlet with a more humane syntax.

## Swift

David provides two versions of his tutorial, 
[one written in Racket](https://davidchristiansen.dk/tutorials/nbe/) and the 
other 
[written in Haskell](https://davidchristiansen.dk/tutorials/implementing-types-hs.pdf).
I've translated those two to a third version 
[written in Swift](https://github.com/CraigStuntz/bidi/). Why Swift? It's not
because Swift is especially well-suited to this task. But I wanted to learn 
Swift, and one way which helps me learn is to write some non-trivial, so now 
there's a Swift version.

You should use whichever version works best for you! (I also found 
[a Scala version](https://github.com/heyrutvik/nbe-a-tutorial) I appreciate that 
Swift is not everybody's cup of tea, which is why it's great that there are now 
*four* languages to choose from. If Haskell or Racket works better for you, then 
use that version!

Personally I *do* like both Racket and Haskell more than Swift, but I recognize 
that there is no "one best" language in the world and that different people have
their own preferences! Swift is also more similar to many other "mainstream" 
languages such as C# and Java than Haskell and Racket are.  I am hoping that 
this version will increase the number of people who want to learn from David's 
tutorial. 

I tried to make this series not assume *too much* Swift knowledge. When I 
introduce a feature which is "uniquely Swift," (as in, works differently than
other languages) I will give a little background on that feature. The idea is 
to make the series accessible to people who have general programming experience,
but not so much (or any) in Swift, *per se.*

## Installing Software

If you want to try the Swift code I've written, you need a few dependencies; see
[the README](https://github.com/CraigStuntz/bidi/) for the simple instructions.
My Swift version will work fine in Xcode, if you like that IDE, but Xcode is not
required to work in Swift, and I don't personally use it.

### Installing Racket/Pie

If you want to use the Pie language in Racket, (or if you want to try the code 
in the Racket version of the tutorial) you will first probably want
Dr. Racket if you don't have it already. One way to do this on a Mac is:

```bash
$ brew install --cask racket
```

You can then install Pie using the `raco` package manager for Racket:

```bash
$ raco pkg install pie
```

You can then open Dr. Racket, and type the traditional "Hello World" of Pie:

```lisp
# lang pie
'spinach
```

Then click the "Run" button and Pie will respond:[^the]

```lisp
(the Atom 'spinach)
```

Congratulations! You've now done more Pie programming than 99.9% of your 
colleagues!

### Installing Haskell

If you want to install Haskell, 
[follow the instructions here](https://www.haskell.org/get-started/). This is 
optional; you can use it to follow along with the Haskell version of the 
tutorial if you choose to.

I haven't found a repo with the Haskell source code from 
[the PDF](https://davidchristiansen.dk/tutorials/implementing-types-hs.pdf), but 
you can get the
[Haskell source code to Pie](https://github.com/david-christiansen/pie-hs).

## Other References

This tutorial series is based on Checking Dependent Types with Normalization 
by Evaluation: A Tutorial [(Haskell version)](https://davidchristiansen.dk/tutorials/implementing-types-hs.pdf) 
and [(Racket version)](https://davidchristiansen.dk/tutorials/nbe/), by David 
Thrane Christiansen. I have also been reading the book David wrote with Daniel
P. Friedman, [*The Little Typer*](https://thelittletyper.com/), which covers
much of the same material in a very readable way. 

There is a survey paper, [Bidirectional Typing](https://dl.acm.org/doi/10.1145/3450952),
by Jana Dunfield and Neel Krishnaswami, which was published by ACM Computing 
Surveys in 2021.

[^the]: `the` is a type declaration. The response means that `'spinach` has the 
        type `Atom`. 