---
title: A Math Primer for Gentry’s Fully Homomorphic Encryption
tags: math, homomorphic encrption, cryptography, Craig Gentry
---

A couple of weeks ago, I wrote [What Is Homomorphic Encryption, and Why Should I Care?](2010-03-18-what-is-homomorphic-encryption.html) In that post, I promised to share my C# implementation of the algorithm from Craig Gentry’s CACM article. Before I can do that, though, I need to explain some of the math involved.

Perhaps surprisingly, it’s actually very simple. (I say "surprisingly" because much of the math and technical papers on encryption is decidedly not simple, including that of [Gentry’s first fully homomorphic scheme](http://crypto.stanford.edu/craig/), which was based on [ideal lattices](https://en.wikipedia.org/wiki/Ideal_lattice).)

This scheme created by Marten van Dijk, Craig Gentry, Shai Halevi and Vinod Vaikuntanathan, however, uses basic arithmetic operations like division, with a few uncommon, but easy to understand, variations.

The nature of homomorphic encryption also dictates a programming style which will seem unfamiliar to users of most high-level languages, but very familiar to anyone who has ever taken a digital circuits class.

## Integer Division

What is the integer quotient of 10 / 6? Most people would probably say "1, remainder 4." But the exact answer, in the domain of real numbers, is 1.666666 (repeating), which is closer to 2 than the previous answer of 1\. So another way we could answer this question is "2, remainder -2." This quotient is closer to the exact answer, and, correspondingly, has a smaller remainder.

So which answer is correct? Arguably, both of them. As long as the following rule holds:

> `dividend = divisor * quotient + remainder` (the division rule)

…then we have a valid answer.

Which method should you use? _It depends on why you’re doing the division._ If you’re computing how many cupcakes each child can have at a birthday party, then you’d better use the answer with the positive remainder. If you’re computing how many panels of fencing you need to surround your yard, then you’d better use the answer with the negative remainder.

In fact, there are at least [five different, valid algorithms](hhttps://www.microsoft.com/en-us/research/publication/division-and-modulus-for-computer-scientists/ "Division and Modulus for Computer Scientists") for selecting a quotient and remainder for a given integer division problem.

The homomorphic encryption scheme used in the van Dijk, et. al. paper and in Gentry’s CACM article uses "R-division":

1.  Compute the real quotient **Q<sub>R</sub>**.
2.  Compute the integer quotient **Q<sub>Z</sub>** by rounding **Q<sub>R</sub>** to the closest integer.
3.  Compute the remainder **R = Dividend - Divisor * Q<sub>Z</sub>**

This is probably different than the method you learned in elementary school, but both are valid. Importantly, it’s probably different than what the integer division and remainder operators in your favorite programming language do.

## Modular Arithmetic

If you’ve ever seen a 12 hour, analog clock, then you’ve worked with modular arithmetic. The time of 10:00 today is the same position on the clock as 10:00 p.m/22:00\. Another way to say this is:

```
10 ≡ 22 mod 12
```

This reads: "10 is congruent to 22 modulo 12." In other words, we just ignore the "extra" 12 hours in the measurement of 22:00, because it’s the same clock dial position as 22:00, only with a circle around the dial.

Naturally, we can perform arithmetic operations like addition and subtraction and compare the congruence of the result. I can say "10:00 + 5 hours means that the hour hand will point to 3 on the clock," or:

```
10 + 5 ≡ 3 mod 12
```

## Modulo 2 Arithmetic and Binary Operations

You can use any number as the modulus. When we make analog clocks, we use 12\. A modulus which is particularly interesting in computer programming is 2\. Arithmetic operations mod 2 correspond to binary operations, e.g.:

```
0 + 0 ≡ 0 mod 2  
0 + 1 ≡ 1 mod 2  
1 + 0 ≡ 1 mod 2  
1 + 1 ≡ 0 mod 2
```

From this example, you can see that addition modulo 2 is the same as the binary operation `XOR`. It turns out that subtraction is exactly the same thing (for mod 2 only!):

```
0 - 0 ≡ 0 mod 2  
0 - 1 ≡ 1 mod 2  
1 - 0 ≡ 1 mod 2  
1 - 1 ≡ 0 mod 2
```

Multiplication modulo 2, on the other hand, corresponds to the binary operation `AND`:

```
0 * 0 ≡ 0 mod 2  
0 * 1 ≡ 0 mod 2  
1 * 0 ≡ 0 mod 2  
1 * 1 ≡ 1 mod 2
```

## Mod in Programming

This is all very simple. However, a word of caution is in order here for anyone who has used a high-level programming language. Most languages have an operator like `mod` (in Delphi) or `%` (in C#, which is commonly pronounced "mod"). However, this operator is not strictly modular congruence. It is more like a remainder, although, as we’ve seen, different people and different programming languages might choose to compute a remainder in different (but hopefully valid) ways.

Remainders and congruence are often the same. In fact, the congruence relationship and the integer division remainder for the examples above are _all_ the same. For example:

```
10 ≡ 22 mod 12  
22 / 12 = 1 R 10
```

However, it’s easy to show examples where this is not true:

```
22 ≡ 34              mod 12       (1)
34 / 12 = 2 R 10                  (2)
-22 ≡ 2              mod 12       (3)
-22 / 12 = -1 R -10               (4)
```

Probably (1) is not the most common choice; 10 would be a more common answer, as with (2). (1) is nevertheless correct as a statement of congruence. Now compare (3) with (4). The most common way to compute a modulus is to pick the smallest positive number. But the most common way to perform integer division is so-called "T-division", where you select the quotient closest to zero and then calculate the remainder, resulting in a negative remainder when either the dividend or the divisor is negative.

## Programs as Digital Circuits

A homomorphic encryption scheme, in addition to the usual `Encrypt` and `Decrypt` and `KeyGen` functions, has an `Evaluate` function which performs operations on the ciphertext, resulting in the ciphertext of the result of the function.

Obviously, this necessitates a different style of programming than that afforded by the typical programming language. In particular, code like this:

```cs
bool a = b ? c : d
```

…(where `a`, `b`, `c`, and `d` are all `bool`s) is impossible, because the value of `b` is encrypted, so the program cannot know what to assign to `a`. If, however, we can perform binary operations on the ciphertext of `b`, then we can rewrite the statement above as:

```cs
bool a = (b & c) | ((!b) & d)
```

…or its homomorphic encryption equivalent:

```cs
CypherText a = (b h_and c) h_or (h_not(b) h_and d)
```

…where the `h_*` operators are the homomorphic equivalents of the usual Boolean operations and `a`, `b`, `c`, and `d` are now of type `CypherText`.

Note that the version with the ternary operator and the version with the `AND` and `OR` operators are not strictly the same, although their results are; the ternary operator is lazy, whereas the `AND` and `OR` version uses complete evaluation. This is necessary when the values are encrypted. It also means that the function may be inefficient.

Intuitively, it’s easy to see that any [referentially transparent](https://en.wikipedia.org/wiki/Referential_transparency_%28computer_science%29) function can be reduced to such operations; this is what compilers and operating systems do under the hood anyway. I’m not going to go into any detail on how this is done; get an introduction to digital circuits book if you are interested in the particulars.

Gentry’s article notes that other changes in programming style are necessary when performing operations within a homomorphic encryption scheme. For example, the size of the output of a function must be set in advance. Even if the plaintext is variable-length, the ciphertext must be of a known length, which corresponds to the number of "wires" in the circuit. The plaintext, therefore, would have "whitespace" at the end or be truncated, depending upon its size.

## Minimizing Boolean Functions

In [my first post on homomorphic encryption](2010-03-18-what-is-homomorphic-encryption.html), I mentioned that Gentry’s encryption schemes can be considered fully homomorphic because they support two homomorphic operations, corresponding to Boolean `AND` and `XOR`. I’d like to go into a little bit more detail as to why that is true.

Many combinations of Boolean operations are equivalent. Perhaps the most famous are [De Morgan’s laws](https://en.wikipedia.org/wiki/De_Morgan%27s_laws). There are [a variety of techniques for converting one function using Boolean operations into an equivalent function with different operations](https://babbage.cs.qc.cuny.edu/courses/Minimize/ "Minimizing Boolean Functions"). This is often done in order to produce a [simpler](https://www.allaboutcircuits.com/textbook/digital/chpt-7/boolean-rules-for-simplification/ "Boolean rules for simplification") or more efficient function, but can also be done in order to use a specific type of Boolean gate.

It is possible to use [combinations of `NAND` or `NOR` gates, for example, to produce circuits which perform a Boolean AND, OR, NOT, etc.](http://hyperphysics.phy-astr.gsu.edu/hbase/electronic/nand.html#c4) Hence, a cryptosystem which supported a homomorphic `NAND` operation could be considered "fully homomorphic."

Similarly, having both `AND` and `XOR` gates available allows you to produce the same outputs as all other Boolean gates, as, for example, `NOT p` is the same as `p XOR 1` and we can see by De Morgan’s laws that with `NOT` and `AND` we can implement `OR`.

Therefore, we can see that a cryptosystem can be considered fully homomorphic if it supports enough homomorphic operations to perform any logical Boolean operation. In particular, a cryptosystem which supports any of the following homomorphic operations would qualify:

*   Just `NAND`
*   Just `NOR`
*   Both `XOR` and `AND`
