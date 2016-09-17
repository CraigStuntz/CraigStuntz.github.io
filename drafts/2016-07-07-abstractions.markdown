---
title: Abstractions
tags: mathematics, computer science
---

When we talk about abstraction in programming, we often mean one of two different
things:

* Removing relatively unimportant details from a real-world concept, to simplify
  working with it. For example, we can talk about a "file" without understanding 
  how the bytes are written to a physical disk.
* Abstractions defined by laws. Instead of removing details from a real-world 
  idea, we look for real-world ideas which happen to conform to a set of 
  laws. For example, the addition operation over integers is a 
  [group](http://mathworld.wolfram.com/Group.html).

For clarity, I'll call the first a "generalization" and the second a 
[mathematical structure](http://abstractmath.org/MM/MMMathStructure.htm).

At first glance, these definitions don't seem all that different. Both, for 
example, allow us to write code against the abstraction such that it works with 
multiple instances of that abstraction. We can write programs which deal with 
["files" on disk, modems, and keyboards](https://en.wikipedia.org/wiki/Everything_is_a_file).
And we can write mathematical proofs which apply to any group, not just 
addition over integers. 

But the implications of these definitions diverge widely.

The "generalization" definition implies Joel Spolsky's 
["law" of leaky abstractions](http://www.joelonsoftware.com/articles/LeakyAbstractions.html)

> **All non-trivial abstractions, to some degree, are leaky.**

Whereas, 
[as Edsger W. Dijkstra notes](https://www.cs.utexas.edu/~EWD/transcriptions/EWD03xx/EWD340.html) 
the "mathematical structure" definition is just the opposite:

> "… the purpose of abstracting is not to be vague, but to create a new 
> semantic level in which one can be absolutely precise."

## Abstractions Are Not Analogies

In software design we often use analogies: 
"[the asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html)," 
"[trampolines](https://en.wikipedia.org/wiki/Trampoline_(computing)),"

Analogies "leak," to use Joel's term, almost by definition. If they didn't,
they would be indistinguishable, not analogous.

## Is Deduplication Abstraction?

Maybe

[duplication is far cheaper than the wrong abstraction](http://www.sandimetz.com/blog/2016/1/20/the-wrong-abstraction)
–Sandi Metz

Given the discussion above, the notion of "the wrong abstraction" is curious indeed.
