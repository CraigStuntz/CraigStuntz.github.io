---
title: '"Static vs. Dynamic" Is the Wrong Question for Working Programmers'
tags: programming languages
---

It's common to ask, _"Is there evidence that programmers write safer code
or are more productive when using a static or a dynamic language?"_ It's
also common to write really terrible blog post answers to this question. I'm
not going to link to examples, but let's just say that general comparisons of
"mainstream dynamic language A" with "mainstream static language B"
don't give a lot of insight into the broader question.

Programmers who say they prefer static or dynamic languages are [often 
interested in specific language features](https://www.ics.uci.edu/~lopes/teaching/inf212W12/readings/rdl04meijer.pdf)
rather than static or dynamic type systems, *per se.*

Yet [reasonable people do want to know the answer](http://rundis.github.io/blog/2016/type_confused.html).
Can we shed more light on the topic?

## Science Cannot Give Us a Definitive answer – Yet!

Well-designed, peer reviewed research on human interaction with
programming languages is [uncommon](https://jyx.jyu.fi/dspace/handle/123456789/47698).
Static typing is [better studied than most other PL features](https://www.quorumlanguage.com/evidence/evidence.pdf)
but
[tends to examine very specific claims with fairly small effects](http://danluu.com/empirical-pl/).
Good studies which do exist at all, narrow as their findings might be, are
[generally not reproduced by anyone](2016-06-17-Andreas-Stefik-on-PL-Human-Factors.html).
There is [an effort to fix this](http://www.cs.cmu.edu/~NatProg/programminglanguageusability/),
but for now any argument claiming a "scientific" answer to this question
is suspect.

## There Aren't Two Distinct Buckets of Languages Named Static and Dynamic

To be honest, I don't think this question is answerable. In part this is
because, increasingly, I think **the notion of a strict distinction between
static and dynamic languages is less than helpful**. It's somewhat more
useful to talk about what sort of features the language's type system has.

> In general, we should strive for strong typing, and adopt static typing 
> whenever possible.
> –[Luca Cardelli and Peter Wegner](http://web.cse.ohio-state.edu/~soundarajan.1/courses/788/cardelli85understanding.pdf)

From the point of view of the working programmer, calling a language 
"statically typed" confuses a number of different and important
ways that both languages and tooling can vary.

Why? Ask yourself these questions:

### What Is a Statically Typed Language?

Is Elm a statically typed language? Is Java a statically typed language?

* [Elm's type system acts as a coach](http://elm-lang.org/blog/compilers-as-assistants)
  to help the programmer complete her work, but doesn't really affect
  performance.
* Java's type system is a [verbose](http://openjdk.java.net/jeps/286)
  impediment to code readers and writers, but
  [improves performance](http://cr.openjdk.java.net/~jrose/values/values-0.html)
  by, for example, supporting many different primitive numeric types.

Elm's type system is substantially more powerful than Java's, and eliminates
entire classes of bugs which plague Java applications such as dereferencing
null pointers and inexhaustive `switch` blocks. 

If both languages are called "statically typed" and yet the two languages'
type systems do such different things, then how much value is there in
lumping them into the same specific bucket?

Indeed, even the [word "type" itself is used in multiple, not entirely
compatible senses](https://www.cl.cam.ac.uk/~srk31/research/papers/kell14in-author-version.pdf) in computer science.

Tomas Petricek [argues](http://tomasp.net/blog/2015/against-types/):

> Rather than seeking the elusive definition of what is a type (which does
> not exist), I believe that we should look for innovative ways to think
> about and work with types that do not require an exact formal definition.

### What Is a Dynamic Language?

Is Erlang a statically typed language? Many would say no, but what if I run
[Dialyzer](http://erlang.org/doc/man/dialyzer.html) first? Sure, I'm not
getting the runtime performance benefits static typing can bring, but
if types are inferred statically at build time and can fail the build, then
I'm getting at least some help from static typing. So in this case the
distinction between statically and dynamically typed has more to do with the
tooling I might be using than the language itself. That's interesting!

You can even [infer static types from unit tests instead of code itself](https://github.com/frenchy64/ambrosebs.com/blob/gh-pages/talks/dynamic%20inference%20boston%20pi%202016.pdf)!

### Whatever "Static" and "Dynamic" Are, Production Languages Often Have Both

C# has `dynamic`. Racket has [Typed Racket](https://docs.racket-lang.org/ts-guide/).
Java has reflection. Clojure has `core.typed`.

Statically typed languages typically check certain types of errors at compile
time and other types of errors at runtime.<sup>1</sup> Which types of errors 
are checked when varies by programming language. For example, Idris can 
statically prove that a program does not divide by zero, whereas C# cannot. 

Manuel Chakravarty wrote a much more detailed (and technically rigorous) 
[examination of this idea](http://justtesting.org/post/148297302871/static-versus-dynamic).

### Well, OK, But Surely There Must Be a _Formal_ Distinction, Right?

Less so than you might think.

> Terms like "dynamically typed" are arguably misnomers and should probably
> be replaced by "dynamically checked," but the usage is standard.<br/>
> – Benjamin C. Pierce, _Types and Programming Languages_<sup>2</sup>

> Thus we see that the canonical untyped language, **Λ** [the untyped
> lambda calculus], which by dint of
> terminology stands in opposition to typed languages, turns out to be but a
> typed language after all. Rather than eliminating types, an untyped
> language consolidates an infinite collection of types into a single
> recursive type. Doing so renders static type checking trivial, at the cost
> of incurring dynamic overhead to coerce values to and from the recursive
> type.<br/>
> - Robert Harper, _Practical Foundations for Programming Languages_<sup>3</sup>

One can consider a "dynamic language" as a language which has
fewer statically checked types (namely, one) than a "static language."

## What Does Static Typing Really Do?

Given some programming language, you can imagine "static typing" as a
feature (or, more properly, a family of features) the language designer
could add to an otherwise untyped or dynamic language which **might** deliver
one or more of the following benefits:

* Proof that certain kinds of dynamic errors are impossible<sup>4</sup>
* Automatic and machine verified documentation
* Improved runtime performance
* Better tooling support

It **might** also have one or more of the following drawbacks

* Increased verbosity or [reduced expressiveness](http://tratt.net/laurie/blog/entries/another_non_argument_in_type_systems.html)
* Rejection of otherwise correct programs<sup>5</sup>
* Slower programmer iteration (possibly lengthy compile/run cycles)
* A need for the developer to learn "static typing" language feature (through
  she still must understand types to some degree regardless)

However, every single one of these benefits and drawbacks could also come
from adding a different feature (distinct from "static typing") to the
language.

For example, "proof that certain kinds of dynamic errors are impossible"
could come via model checking or [formal verification](https://www.microsoft.com/en-us/research/project/vcc-a-verifier-for-concurrent-c/). 
"Increased verbosity" is hardly limited to "static languages"; most "dynamic languages"
are more verbose than SML or Haskell.

Instead of asking, "Should the whole world use a 'statically typed' language?"
we could ask "In which cases would it make sense to write formal proofs of
(at least some parts of) our programs?"

## If "Static vs. Dynamic" Is the Wrong Question, Then What Is the Right Question?

If you're a working programmer, then the right question is:

> **How can my languages and tooling help me be a better programmer?**

Follow-up questions might be:

*  If I care about verification of correctness properties above and beyond
   what I can do with simple tests, what are my choices, in terms of language
   features and tooling?
*  What are the properties which are difficult or impossible to verify?
*  Do the features and tooling of the language steer you towards great
   solutions to problems, provide you little guidance, or get in your way?
   Does the answer vary depending on which kind of problem?
*  What compromises does the language I'm using now make?
*  Can I use tools to fill in some of the shortcomings?
*  How do other languages and systems address my pain points?
*  Given some correct program I want to be the output of my process, how
   do I arrive at that program? Do I start by writing a specification
   (possibly in the form of types), or
   by writing tests, or by writing code, or a mix of these?

These are difficult questions, because you can't really answer them without
experience with diverse languages, programming communities,
and ecosystems. Zealots need not apply, but be kind to excited newbies!

Importantly, programming is still in its infancy. We are still discovering
new methods of designing code. We must keep an open mind, because programmers
50 years from now will laugh at whatever we choose. Today, you can design
your code using top-down, bottom-up, test-first,
[type-driven](https://www.manning.com/books/type-driven-development-with-idris),
or a multitude
of other techniques. The design methodologies of the next decade probably
haven't been invented yet.

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr"><a href="https://twitter.com/raichoo">@raichoo</a> <a href="https://twitter.com/kamatsu8">@kamatsu8</a> let&#39;s have some imagination about where languages and tools might go if we let go of how current tools trade things off</p>&mdash; Edwin Brady (@edwinbrady) <a href="https://twitter.com/edwinbrady/status/743865720912609280">June 17, 2016</a></blockquote>

### Comments on this post elsewhere
* [lobste.rs](https://lobste.rs/s/nukuek/static_vs_dynamic_is_wrong_question)

##### Notes

<sup>1</sup> Harper, Robert, [_Practical Foundations for Programming Languages_](http://www.cs.cmu.edu/~rwh/pfpl.html), 2nd Edition, §6.3

<sup>2</sup> Pierce, Benjamin C. [_Types and Programming Languages_](https://www.cis.upenn.edu/~bcpierce/tapl/), p. 2

<sup>3</sup> Harper, §21.4

<sup>4</sup> Harper, §6

<sup>5</sup> Rémy, Didier, [_Type systems for programming languages_](http://gallium.inria.fr/~remy/mpri/cours1.pdf), p. 29
