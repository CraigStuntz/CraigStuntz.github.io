---
title: "On Learning Compilers and Creating Programming Languages"
tags: compilers, computer science, programming languages, plt
---

When I first started learning about compilers, there was something important which I didn't understand: Designing a programming language and writing a compiler are two almost entirely different skills. There is obviously some overlap between them, but less than you might think at first!

I think it's important to know this because they are both very challenging problems! It's easier to learn these skills if you take them one at a time. Your first solution to a hard problem is likely to be... well, not as good as your tenth! However, it's pretty common for developers to build out a toy language as they write their first compiler, which means they are making mistakes and learning stuff on two hard problems at once. Worse, those two problems are correlated: A mistake on one will make your life harder on the other. Also, as we will see, although compilers are challenging at first they're essentially a solved problem, whereas PL design is, let's say, an area of ongoing research.

I think it's easier to learn to write a compiler first, and then (if you want) learn to design programming languages. It will be harder to learn to design a good programming language if you don't have experience with compiler design challenges (amongst other things), so if you want to learn both skills I recommend doing it in that order: Compiler, then PLs. Compiler construction iis useful to nearly all software engineers, even (especially?) those who will not build compilers as part of their daytime job. Knowing the challenges of PL design is also useful, but I think in a more abstract way.

## Challenges in Compiler Design

When I say that compiler design is a "solved problem," I don't mean that there will never be any more innovation in the space. Instead I mean that there are published solutions to all of these problems, and you can just look them up and use them/learn from them. Also, compiler design is mostly a technical problem. While there are human factors to consider, as there are in every area of software engineering ("Which error messages would be most helpful in a given situation, and how can I be sure I'm producing those?"), many of the problems that you will be solving will be strictly technical ("When a user attempts to compile a large file, does that work or does the compiler become very slow/run out of memory?").

Specific design decisions you will have to make include:

* **Error handling** ("When I encounter code which is incomplete or erroneous, I would like to present the user with a helpful message for each error in the program instead of immediately dying with an unhelpful message at the first error.")
* **Syntax challenges** ("When you encounter a `-`, is it unary negation or a minus sign?")
* **Semantics challenges** ("Can I correctly resolve function overloads per the PL specification for each invocation?")
* **Typing challenges** ("Does the compiler determine type correctness via type inference, type checking, or 'both'?")

Some of the things which make one compiler better than another are quite measureable, such as speed. Others, such as the clarity of error messages, are a bit more challenging to measure, but nevertheless can be compared.

## Challenges in Programming Language Design

When I say that PL design is a largely unsolved problem, I mean two things.

First, although there are published solutions for some of these problems (such as [K Framework](https://kframework.org/) or [PLT Redex](https://redex.racket-lang.org/)), they are not necessarily used by every designer. It is very common for PL designers to simply not use them. This is less true with compiler implementers, who tend to use off-the-shelf patterns if not libraries. Sometimes the PL designer will carefully construct a formal calculus of the language using a different system, whereas other designers will just "wing it." Using an "informal" design process can lead to disastrous omissions in the PL design, such as [the Shellshock bugs](https://en.wikipedia.org/wiki/Shellshock_(software_bug)). However, "informally designed" languages such as bash and PHP have been incredibly successful by many measures. I am not here to throw shade at them. I am just saying that PL design is complicated in terms of producing a language which is secure, usable, and popular. Using a formal model such as K Framework or PLT Redex might make your language more secure, but it won't by itself make it any more or less popular. There is no formal solution for popularity that I can imagine.

Second, it's not clear what makes one programming language more usable than another (although there have been [some studies](https://quorumlanguage.com/evidence.html)). It's not entirely clear what "usable" even means here, as many of the criteria seem contradictory. ("Is the programming language easy for beginners to use, and does it restrict the production of invalid programs?") There is still a ton of room for innovation and discovery in this design space.

Specific design decisions you will have to make include:

* **Syntax challenges** ("How do I want my PL to look? What identifiers/symbols should it use?") Folks who are new to PL design often spend a lot of time thinking about such matters, but I'll just say that there are considerably more challenges to come!
* **Semantics challenges** ("When a function is both overloaded and has default arguments, which version should a given call to that function having a given list of arguments invoke?")
* **Typing questions** (Should you use gradual typing? Refinement types, dependent types, etc.?)
* **Error handling** ("It would be good to design my language such that error recovery is easier for implementers")

There are standard formal solutions for some of this. Syntax questions can be answered, for example, using a formal grammar, such as [EBNF](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form).

One of the more popular languages that I know of had a Java-like syntax imposed on the designer by management in the late stages of its design. This sounds like a recipe for disaster. Yet it became quite popular anyway. PL design seems to be roughly an equal mix of understanding formalisms, fine art, and good luck. This is not so dissimilar from other areas of computer programming; it just seems to be a more extreme case of this bifurcation of skills.

## So What Do You Recommend?

I would recommend that you start your first compiler with a "toy" language. Toy languages are on purpose simple; they often have few types (as few as one), and features that are trickier to implement are either omitted entirely or are introduced a little bit at a time. They are intended to get you up and going with a working compiler quickly.

Here are some toy languages you can use. This list isn't intended to be comprehensive, or even selective; rather, I just want to give you the sense that there are a lot of languages to choose from. Pick any one of them (or any other pre-designed toy language) and I guarantee you'll be more successful in your first compiler implementation than if you just make something up as you go along!

| Language | Family |
| -------- | ------ |
| [Kaleidoscope](https://releases.llvm.org/9.0.0/docs/tutorial/LangImpl01.html) | ALGOL |
| [Lox](https://craftinginterpreters.com/the-lox-language.html) | ALGOL |
| [Decaf](https://anoopsarkar.github.io/compilers-class/decafspec.html) | ALGOL |
| [Imp](https://fsl.cs.illinois.edu/assets/CS422-Spring-2020-02a-IMP-BigStep-SmallStep.pdf) | ALGOL |
| [MAL [Make a Lisp]](https://github.com/kanaka/mal) | Lisp |
| [Stacker](https://beautifulracket.com/stacker/intro.html) | FORTH |

Jeremy Siek's _Essentials of Compilation_ describes a series of Lisps which grow progressively more full-featured as the book goes on

Andrej Bauer and Matija Pretnar's _The PL Zoo_ is "a collection of miniature programming languages which demonstrates various concepts and techniques used in programming language design and implementation." There are a variety of different styles of languages represented there, as well as implementations in OCaml.

Some of these languages will seem quite simple! They might not have features which you want, such as generic variance or monads or whatever. This is on purpose! If you want to add those features after you've implemented the languages, please do try and do so. But it's a good idea to get through the simple stuff first.

### Some books you can follow if you want to read formal instructions while building your first compiler:

No one book is right for everyone. Here are a few I've liked. 

| Book | Authors | Compilers implemented in... |
| ---- | ------- | --------------------------- |
| [_Crafting Interpreters_](https://craftinginterpreters.com/) | Robert Nystrom | Java |
| [_Essentials of Compilation_](https://wphomes.soic.indiana.edu/jsiek/) | Jeremy Siek | Racket |
| [_Modern Compiler Implementation in ML_](https://www.cs.princeton.edu/~appel/modern/ml/) | Andrew W. Appel | ML |
| [_Programming Languages: Application and Interpretation_](https://www.plai.org/) | Shriram Krishnamurthi | Racket |
| [_Programming Language Concepts_](https://www.itu.dk/~sestoft/plc/) | Peter Sestoft | F# |

People tend to recommend [the Dragon Book](https://suif.stanford.edu/dragonbook/), especially people who have not read it. I have read it, and I do not recommend it when implementing your first compiler because I want you to succeed and enjoy the journey. The Dragon Book is a much better read if you already know everything that is in it. I don't think it's a terrible book, but it should not be the first book you read on the topic.

### Language design books/resources? 

This is hard. It's not my personal interest, so I haven't read as much in this area. There is a mistake which I have seen developers make over and over again, which is related to the "I will invent a toy language while I build my first compiler" mistake, namely, to invent a programming language and then expect the world to beat a path to your door to use it. There is a difference between getting your programming language to compile toy examples and producing something which will easily and efficiently handle any case that a programmer's mind can produce. 

When you write a programming language you need to specify it in such a way that every program that someone might write (even, say, [Duff's device](https://en.wikipedia.org/wiki/Duff%27s_device)) produces sensible results. If you don't then you are building a door to the Shellshock bugs. This is hard! And to produce a language which not only handles arbitrary input in a way which doesn't tend to surprise the user as well as being aesthetically interesting and unique enough for people to even be interested in checking out borders on mysticism to me.

There's a big leap in difficulty between easier books which show you the basics of certain paradigms, such as

* _Programming Languages: Application and Interpretation_ (linked above)
* [_Programming Language Pragmatics_](https://www.cs.rochester.edu/~scott/pragmatics/)

...and more difficult reading which explains the formalities of PLT such as:

* Benjamin Pierce's [_Types and Programming Languages_](https://www.cis.upenn.edu/~bcpierce/tapl/) (totally worth the effort, though) 
* [_Semantics Engineering with PLT Redex_](https://redex.racket-lang.org/sewpr-toc.html)

...which teach you the plumbing about how programming languages work at a semantic level.

One recent paper which is a good bridge between these worlds is [Programming Language Semantics: It’s Easy As 1,2,3](https://www.cs.nott.ac.uk/~pszgmh/123.pdf), by Graham Hutton. I wouldn't call it a basic read, but it does exist in between the two worlds described above.

Perhaps this all seems like too much, when you just want to make a DSL for your text adventure game? Check out [Creating Languages in Racket](https://queue.acm.org/detail.cfm?id=2068896), by Matthew Flatt.

## Conclusion

I realize that the discussion above got into some fairly technical material, but please don't let that put you off. I'm confident that if you follow one of the books or tutorials I listed you can produce a working compiler. You will learn a ton in the process and it will benefit all of the software you write, even if it doesn't (apparently!) involve the creation of a programming language. Have fun!