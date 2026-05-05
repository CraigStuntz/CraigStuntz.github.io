---
title: "You've Been Constraint-Solving All Along"
tags: computer science, patterns, z3
---

There's a pattern which shows up everywhere in programming, often disguised as 
something else. Once you see it, you can't unsee it. I don't _think_ it has a 
single name. But I can give many examples! The pattern is, in an abstract sense:

1. **Generation**: Take an input dataset and apply a function to project it into a different shape
2. **Restriction**: Write another function which restricts the results of that function to only 
those which are "interesting"
3. **Reduction** (optional): Write yet another function which reduces this to a single value,
  say, by summing the results or picking the minimum, or just taking the first 
  result that comes in

The Prolog community called the naïve form of this "generate-and-test" since at least 
the 1980s:

> "Generate-and-test is a common technique in algorithm design and programming. 
> Here is how generate-and-test works for problem solving. One process or 
> routine generates candidate solutions to the problem, and another process or 
> routine tests the candidates, trying to find one or all candidates that 
> actually solve the problem."<br/>
> -- _The Art of Prolog_ by Leon Sterling and Ehud Shapiro (1986)

Formally, this is called the 
[**constraint satisfaction problem**](https://en.wikipedia.org/wiki/Constraint_satisfaction_problem).

## The Abstraction

In case this isn't absolutely clear, let's look at some JavaScript which uses the 
brute force method to solve [problem 9 of Project Euler](https://projecteuler.net/problem=9):

> A Pythagorean triplet is a set of three natural numbers, $a < b < c$, for which
 $$ \begin{align} a^2 + b^2 = c^2 \end{align} $$
> For example, $3^2 + 4^2 = 9 + 16 = 25 = 5^2$.<br/>
> There exists exactly one Pythagorean triplet for which $a + b + c = 1000$.<br/>
> Find the product $abc$.

Ok, we can do this in a one-liner:

```javascript
const result = 
  // Generate numbers [a, b, c] where a + b + c = 1000 and a < b < c
  Array(1000).keys().flatMap(a => Array(1000).keys().filter(b => a < b && b < 1000-a-b).map(b => [a, b, 1000-a-b]))
    // restrict to Pythagorean triples
    .filter(([a,b,c]) => a*a + b*b === c*c) 
    // Reduce to the product
    .map(([a,b,c]) => a*b*c).take(1).toArray()[0];
```

This looks incredibly simple! It's not a "pattern," it's one line of code!

The abstraction really is that simple, and the implementations try to stay close to 
that abstraction as much as possible. However, there can be a surprising amount
of complexity in how the code is executed.

Perhaps you've been programming for a long time and consider all of this to 
be very obvious? Fine, you may not get a lot from this post! However, I do 
remember when I was new to software development and how I might solve a Project 
Euler problem was not obvious to me! One thing that I specifically did not 
understand at that point was that brute force might be the right solution to a
problem _at least in an abstract sense._ Having written a solution in terms of 
brute force we can then optimize our solution if the performance is inadequate.

I will further say that when I hear some of the dialog around agent-based 
programming, specifically the "it might hallucinate!" or the "look how fast I can
blast out garbage!" arguments I hear from both "sides," that I am reminded of 
this pattern. If you don't restrict your solutions, with comprehensive tests or
proofs, then yes, you're going to get errors, whether you generate your possible
solutions with AI or by hand.

## Worked Out Examples 

The same thing keeps coming up, over and over again. Also, the implementations 
of this pattern vary quite a lot, so there is depth behind the seeming 
simplicity. You can implement this pattern in various languages, and they will 
be executed differently!

### MapReduce
[Classic MapReduce](https://en.wikipedia.org/wiki/MapReduce) would seem to be a 
direct mapping of the pattern above, but I will note that it's more of a 
distributed _execution_ paradigm. Running a Project Euler problem on a cluster 
would be a bit silly and probably missing the point of Project Euler. But you can 
certainly see how the "map" (generate + restrict) and "reduce" fit in here.

### SMT-LIB/Z3

Are you ready to get weird? Here is the same Problem 9 from Project 
Euler implemented in SMT-LIB, a pure specification language:

```lisp
; SMT-LIB is pretty basic and doesn't have exponentiation built in
; So we'll define this for legibility
(define-fun square ((num Int)) Int (* num num))

; The "generation" is "all possible assignments to a, b, c"
(declare-const a Int)
(declare-const b Int)
(declare-const c Int)

; We restrict it to "those which satisfy the specification" by just writing it out!
; We are looking for a set of three natural numbers, a < b < c
(assert (and (>= a 0) (< a b) (< b c)))
; for which a^2 + b^2 = c^2
(assert (= (+ (square a) (square b)) (square c)))
; for which a + b + c = 1000
(assert (= (+ a b c) 1000))

; And we want to return the product, since Project Euler needs a single number
(declare-const product Int)
(assert (= product (* a b c)))

; This checks if there's any solution at all
(check-sat)
; This returns the solution
(get-model)
```

If we hand this specification to a solver such as [Z3](/tags/z3.html), it will 
use decision procedures to solve the constraints directly rather than enumerate
with brute force. [Try it!](https://microsoft.github.io/z3guide/playground/Freeform%20Editing/)

It is less the case here that we are "generating" triples of integers and 
restricting them to those for which $a^2 + b^2 = c^2$ and more the case that 
we are generating possible assignments to `a`, `b`, and `c` and restricting them 
to those which _correctly satisfy the specification we have given._

### Prolog 

Similarly, Prolog lets us directly encode the problem from the specification: 

```prolog
answer(Product) :-
    between(0, 998, A),
    % a < b
    between(A, 998, B),
    % a + b + c = 1000
    C is 1000 - A - B,
    B < C,
    % a^2 + b^2 = c^2
    A*A + B*B =:= C*C,
    Product is A * B * C.
```

One way to think about what Prolog is doing here is that we are not so much 
writing a generator and restriction function as we are _binding_ the input 
arguments `A`, `B`, and `C` to the output `Product`.

## Still More Examples

I will spare you the implementation of Project Euler problem 9 in SQL, but this
pattern is applicable to many problems in programming!

For example, when fuzzing, we take a bunch of random inputs, restrict them to 
those which crash or trigger [AddressSanitizer](https://github.com/google/sanitizers/wiki/addresssanitizer),
and then reduce the output by running a [corpus minimization](https://arxiv.org/abs/1905.13055).

When doing agent driven development, we can generate many programs very quickly,
but they might be incorrect! If we have a formal proof of correctness then we 
can reduce the set of candidate programs to those which satisfy the 
specification. Agents turn out to be quite good at finding such programs.
But without a proof, we might end up with something sloppy!

In classic TDD, we start with a system under test which we are modifying
(in effect, generating lots of candidate programs). Our restriction is the test
suite, and we reduce this via a pass/fail verdict -- do the tests pass?

## Measuring Generation and Restriction Efficiency

The last example, TDD, might feel a bit unsatisfactory. One can imagine trying
to solve Project Euler problem 9 via TDD:

```java
  // Arrange -- choose some random inputs as a first trial
  var a = 1;
  var b = 2;
  var c = 3;

  // Act
  var actual = Euler.sumOfSquares(a, b);

  // Assert
  Assert.assertTrue(a < b);
  Assert.assertTrue(b < c);
  Assert.assertEquals(1000, a + b + c); // Fail!
  Assert.assertEquals(c * c, actual);   // Fail!
```

I kid, I kid. Java can do brute force, just like JavaScript, even if TDD purists
might sincerely suggest the above as a good starting point. But nonetheless, 
this example does indicate a difficulty with TDD: Finding meaningful inputs for 
your problem space. 

> "...program testing can be used very effectively to show the presence of bugs 
> but never to show their absence."<br/>
> -- Edsger W. Dijkstra, [On the reliability of programs](https://www.cs.utexas.edu/~EWD/transcriptions/EWD03xx/EWD303.html)

This might be a helpful way to judge implementations of the constraint 
satisfaction problem: How much data does the generation produce, and how 
effective is the restriction step? Can programs written using this pattern go 
wrong?

Let's consider the problem of finding bugs in source code you've produced. We 
generate candidate bugs and then apply some test to figure out which candidates 
are actually defects. (For example, a static analyzer might look for string 
concatenation in SQL statements and then attempt to restrict reporting to those
instances where the data being concatenated is user-controlled.)
Generation can be too sparse to find bugs or so dense it overwhelms you. 
Restriction can let real bugs through or flag false positives. Both axes can fail 
in two directions.

<table style="border: none;">
<tr><td style="border: none;"></td><td style="border: none;"></td><th colspan=3>Restriction</th></tr>
<tr><td style="border: none;"></td><td style="border: none;"></td><th>Not restrictive enough</th><th>"Just right"</th><th>Too restrictive</th></tr>
<tr><th rowspan=4 style="overflow-wrap: break-word;">Generator<br/><span style="font-weight: normal;">(number of cases considered)</span></th><th>Sampled</th><td>TDD</td><td>Property-based testing</td><td>Overfitted unit tests</td></tr>
<tr><th>"Just right"</th><td>Smoke testing</td><td>Correctness proofs</td><td>Rust's borrow checker[^nll]</td></tr>
<tr><th>"A lot"</th><td><code>printf</code> debugging  </td><td>Profile-guided fuzzing</td><td>Static analysis</td></tr>
<tr><th>Too much</th><td>Manually skimming a log file</td><td>Symbolic execution</td><td>Mutation testing</td></tr>
</table>

Lest you consider me too judgy for the table above, I don't mean to suggest that
you should not, for example, use static analysis due to false positives! 
Static analysis is a _fantastic_ way to avoid bugs, even if you must occasionally 
suppress a finding. Still, the _ideal_ static analyzer would have no false positives. 
Indeed, _all_ of the techniques listed above have their place, but I do think 
that the table is honest about their shortcomings.

## Conclusion

These examples show the constraint satisfaction problem hiding in plain sight. 
Every tool above is making the same two decisions any constraint-satisfaction 
approach has to make: how to generate candidates, and how to test them. SMT 
solvers generate via decision procedures and test via assertions. Fuzzers 
generate via mutation and test via sanitizers. Type checkers generate via 
inference and test via unification. Even TDD fits the pattern, with the developer 
playing the role of the generator.

Recognizing this pattern lets you compare tools on the same axes — execution 
model, generation density, and restriction tightness. Pick the one whose 
performance and failure mode you can live with for the problem in front of you.

The most important thing I want you to take away from this post is to look for
constraint solving solutions to programming problems in front of you. When
you see one, don't be put off by questions of efficiency or false positives. 
There are solutions to those! But by recognizing _the abstraction_ you can focus
on the most important part, which is _correct_ generation and restriction.

[^nll]: Especially the 
[pre-NLL borrow checker](https://oneuptime.com/blog/post/2026-01-25-non-lexical-lifetimes-rust/view), 
although safe Rust will always reject valid (but not provably memory-safe) 
programs. To be clear, I think this is a good thing!