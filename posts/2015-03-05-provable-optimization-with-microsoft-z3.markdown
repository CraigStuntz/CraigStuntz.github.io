---
title: Provable Optimization with Microsoft Z3
tags: z3, theorem provers
---

A few months ago, some coworkers sent around a Ruby challenge. It appears simple, but we can sometimes learn a lot from simple problems.

> Write a Ruby program that determines the smallest three digit number such that when said number is divided by the sum of its digits the answer is 20.

In case that's not clear, let's pick a number, say, 123. The sum of the digits of 123 is 6, and 123/6 = 20.5, so 123 is not a solution. What is?

Here's some Ruby code I wrote to solve it:

```ruby
def digitSum(num, base = 10)
    num.to_s(base).split(//).inject {|z, x| z + x.to_i(base)}
end

def solution
    (100..999).step(20).reject {|n| n / digitSum(n) != 20 }.first
end

puts solution
```

Problem solved, right?

Well, no. For starters, it doesn't even execute. There's a really subtle type error in this code. You probably have to be fairly good with Ruby to figure out why without actually running it. Even when fixed, the cognitive overhead for understanding the code to even a simple problem is very high! It doesn't look like the problem specification at all.

Does this version, when the bug is fixed, actually produce a correct answer to the problem? Does it even produce an incorrect solution? It's not quite clear.

So maybe my solution isn't so good. But one of my colleagues had an interesting solution:

```ruby
def the_solution
    180
end
```

Well, that looks really, really efficient, and it typechecks. But is it the correct answer? Will you know, six months down the road, what question it's even trying to answer? Tests would help, but the word "smallest" in the problem turns out to be tricky to test well. Do you want methods like this in code you maintain?

## The Best of Both Worlds

Is there a solution which is as efficient as just returning 180 but which also proves that 180 is, in fact, the correct solution to the problem? 
Let's encode the specification for the problem in [a pure specification language, SMT-LIB](/posts/2014-07-07-test-only-development.html):

```commonlisp
(define-fun matches-problem ((n Int)) Bool
  (and
    (>= n 100)
    (< n 1000)                   ; three digits
    (= 20.0 (/ n (digit-sum n)))))
```

Z3/SMT-LIB doesn't ship with a `digit-sum` function, so I had to write that. You can find that code in the full solution, below.

That's most of the problem, but not quite all. We also have to show that this is the smallest solution. So let's also `assert` that there exists a "smallest" solution, which means that any other solution is larger:

```commonlisp
(declare-const num Int)

(assert
  (and
    (matches-problem num) ; "num" is a solution
    (forall ((other Int))
        (implies (matches-problem other) (>= other num))) ; any "other" solution is larger
  ))
```

Now let's ask Z3 if this specification even makes sense, and if it could be reduced into something more efficient:

```commonlisp
(check-sat)
(get-model)
```

And Z3 replies...

```commonlisp
sat
(model
  (define-fun num () Int
    180)
)
```

A round of applause for the theorem prover, please! The full solution is at the 
bottom of this post. You can 
[try it yourself online](https://microsoft.github.io/z3guide/playground/Freeform%20Editing) 
without installing anything.

One interesting point here: The output language is SMT-LIB, just like the input language. The "compile" transforms a provably consistent and more obviously correct specification into an more efficient representation of the answer in the same language as the input. This is especially useful for problems which do not have a single answer. Z3 can return a function matching a specificationas easily as it can return an integer.

What does it mean when I ask "if this specification even makes sense?" Well, let's say I don't like the number 180. I can exclude it with an additional `assert`:

```commonlisp
(assert (> num 180))
```

This time, when I check-sat, Z3 replies `unsat`, meaning the model is not satisfiable, which means there's definitely no solution. So 180 is not only the smallest solution to the original problem, it turns out to be the unique solution.

Formal methods can show that your problem specifications are consistent and that your implementation is correct, and they can also guarantee that "extreme" optimizations are correct. This turns out to be [really useful in real-world problems](http://research.microsoft.com/en-us/um/people/lamport/tla/formal-methods-amazon.pdf).

## Appendix: Full Solution
```commonlisp
; Write a Ruby program that determines the smallest three digit number 
; such that when said number is divided by the sum of its digits 
; the answer is 20.
(define-fun hundreds  ((n Int)) Int (div n 100))
(define-fun tens      ((n Int)) Int (div (- n (* 100 (hundreds n))) 10))
(define-fun ones      ((n Int)) Int (mod n 10))
(define-fun digit-sum ((n Int)) Int (+ (hundreds n) (tens n) (ones n)))
(define-fun matches-problem ((n Int)) Bool
  (and 
    (>= n 100) 
    (< n 1000)                   ; three digits
    (= 20.0 (/ n (digit-sum n)))))
(declare-const num Int)
(assert 
  (and 
    (matches-problem num)
    (forall ((other Int)) (implies (matches-problem other) (>= other num))) ; no smaller answer
  ))
(check-sat)
(get-model)
```