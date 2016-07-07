---
title: Abstractions
tags: mathematics, computer science
---

When we talk about abstraction in programming, we often mean one of two different
things:

* Removing relatively unimportant details from a real-world concept, to simplify
  working with it. For example, we can talk about a "file" without understanding 
  how the bytes are written to a physical disk.
* Abstractions defined by laws. Instead of removing details from a real-world idea,
  we look for real-world ideas which happen to conform to a set of laws. For 
  example, the addition operation over integers is a 
  [group](http://mathworld.wolfram.com/Group.html).

At first glance, these definitions don't seem all that different. But the 
implications diverge widely.

The "removing relatively unimportant details from a real-world concept" 
definition implies Joel Spolsky's 
["law" of leaky abstractions](http://www.joelonsoftware.com/articles/LeakyAbstractions.html)

> **All non-trivial abstractions, to some degree, are leaky.**

Whereas, 
[as Edsger Dijkstra notes](https://www.cs.utexas.edu/~EWD/transcriptions/EWD03xx/EWD340.html) 
the latter definition is just the opposite:

> "… the purpose of abstracting is not to be vague, but to create a new 
> semantic level in which one can be absolutely precise."
