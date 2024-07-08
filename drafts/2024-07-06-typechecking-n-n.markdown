---
title: "A Very Gentle Introduction to Type Checking, Chapter n"
series: A Very Gentle Introduction to Type Checking
chapter: "n"
chapterName: Misc.
tags: compilers, type checking
---

<div class="toc">
* Introduction: Type checkin'
</div>


## Rules

When we build a parser, we use rules, often specified as 
[EBNF](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form) to 
determine which syntax is valid and which is invalid. Our code should *exactly*
follow these rules. Here is an example bit of EBNF, from Wikipedia:

```ebnf
digit excluding zero = "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
digit                = "0" | digit excluding zero ;
```

I will bet that the EBNF syntax above looked a bit strange when you first 
encountered it, but if you have done any kind of work with compilers at all then
you have probably gotten comfortable with it. (If not, don't worry; that's the
last time you'll see EBNF in this series!)

Similarly, when we build a type checker, we will follow 
[typing judgements](https://www.cs.princeton.edu/courses/archive/spring12/cos320/typing.pdf), 
expressed as [inference rules](https://en.wikipedia.org/wiki/Rule_of_inference).

Inference rules look somewhat alarming when you first see them, but in this 
series I will try to walk you through them *very* gently. A sample inference
rule is below. Right now I don't want you to even try to understand it; I just 
want you to *recognize it.* When you see a rule like this, I want you to think:
"That's a typing inference rule. It tells me something about how the type 
checker should behave." 

$$ \frac{\Gamma \vdash e \Leftarrow t_1}{\Gamma \vdash e \in t_1 \Rightarrow t_1} \quad $$

Don't worry, we will learn what this all means soon enough!

