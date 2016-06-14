---
title: Designing for Problems Too Big to Test
---

In this post, I will show an example of where using unit testing as a design
methodology does not work, and how to produce a design for correct code anyway.
There is no single design methodology which works for all problems, so it’s
useful to have a variety of tools at your disposal.

This post is my contribution to the [2015 F# Advent Calendar](https://sergeytihon.wordpress.com/2015/10/25/f-advent-calendar-in-english-2015/).

I’m implementing a compiler for a tiny language without use of external libraries for things like parsing and code generation. The idea is to produce a minimal example of a purely functional compiler. This is an ongoing project, and some parts are further along than others, but you can see the source code as I work, and it does produce working EXEs today.

Designing a compiler is harder than many problems in programming, because they do something difficult: A compiler must be able to accept any string and either produce an equivalent program or explain clearly to a human being why this is string is not a valid program. And there are a lot of possible strings!

Designing a compiler is also easier than many problems in programming, because there exist formal methods for solving many of the harder sub-problems in the design. You can think of "formal methods," here, as recipes for a solution, but very special recipes which guarantee that you’ll touch all possible cases in the problem space.

### Design Methodologies
Over the years, programmers have used a number of different methodologies when approaching program design. These include:

* **The Big Ball of Mud.** Arguably the most common methodology, this involves just poking at the problem until things seem to work for the most common case, maybe.
* **Big Design Up Front.** In this methodology, a full specification for the implementation of the system is developed before coding begins. Many people consider this obsolete or, at best, wildly inefficient.
* **Test Driven Design.** I’m going to distinguish this from test driven development, because tests are useful both as a methodology for program design and for implementing a program design. In practice, people tend to combine these. As a design methodology, the general idea is that you start with either high or low level simple cases, and continue working until a design evolves. Some people divide this into sub-schools of test driven design.
Despite its ubiquity, few defend the big ball of mud as a design practice. Big design up front is widely ridiculed. That leaves TDD as the most prevalent design methodology that people are willing to publicly defend. Unfortunately, testing, while useful, is fundamentally limited.

> "…program testing can be a very effective way to show the presence of bugs, but is hopelessly inadequate for showing their absence." Edsger Dijkstra

In cases where "the happy path" is far more prevalent than "edge cases," this
might not seem to be a show-stopping limitation, and test driven design works OK in many cases.

### There Are No Edge Cases In Programming Languages
As noted above, a compiler must be able to accept any string and either produce an equivalent program or explain clearly to a human being why this is string is not a valid program. A compiler designer cannot predict the valid programs people may write, nor the errors they may create.

For example, let’s consider [Duff’s Device](https://en.wikipedia.org/wiki/Duff%27s_device). It’s safe to presume that Brian Kernighan and Dennis Ritchie did not have this in mind when they designed the C programming language. For the uninitiated, Duff’s Device nests a while loop inside of a switch statement:

```
send(to, from, count)
register short *to, *from;
register count;
{
    register n = (count + 7) / 8;
    switch (count % 8 ) {
    case 0: do { *to = *from++;
    case 7:      *to = *from++;
    case 6:      *to = *from++;
    case 5:      *to = *from++;
    case 4:      *to = *from++;
    case 3:      *to = *from++;
    case 2:      *to = *from++;
    case 1:      *to = *from++;
            } while (--n > 0);
    }
}
```

This is unreadable to the point that it borders on obfuscation, but is legal C, per the specification, and does perform a useful optimization on a particular case. I bring it up because, as a language implementer, I think it drives home the point that there is no possibility of creating (anywhere near) all of the possible unit tests for all of the possible ways someone might choose to use your language.

### Different Tasks, Different Design Methodologies
In many programming tasks, the number of "happy path" cases are similar to the number of edge and error cases. At least within the same order of magnitude. In these cases it’s probably possible to exhaustively test the system, even if people don’t usually bother to do so.

For other tasks, however, the number of "edge cases" is uncountably large. I gave a programming language example above, but there are others, such as designing an API for a cloud service. In these cases, we need a design methodology which gives us some assurance that our design will work with cases that we did not and could not possibly produce tests for, because real-world use cases will vastly outnumber our test cases.

### Formal Methods
The solution to this problem is to break the problem space into a countable number of conditions. This is only effective if those countable conditions represent all possible states in the problem space. For example, for a programming language, we divide the task of compilation into small phases such as lexing, parsing, etc., and within each phase we use a formalism which guarantees that we cover the entire possible range of conditions within that phase.

This will make more sense if I give an example.

### Lexing and Regular Expressions
In many compilers, the first phase of compilation is lexing, where the string representing the program source code is split into tokens. The token list will be passed to the parser, which attempts to match them up with the grammar of the programming language. As a practical example, consider the following expression from a Lisp-like language, which increments the number 1, resulting in the value 2.

```lisp
(inc 1)
```

Lexing divides this source code into a stream of tokens, like this:

```
LeftParenthesis
Identifier "inc"
LiteralInt 1
RightParenthesis
```

These tokens will be consumed by the parser to produce and abstract syntax tree, type checked, optimized, etc., but let’s just look at lexing for now.

Substrings of the input source code are mapped to tokens using regular expressions. Not
[the PCRE type with zillions of features](http://www.regular-expressions.info/quickstart.html)
you might be familiar with, but [a far simpler version](https://en.wikipedia.org/wiki/Lexical_grammar)
with only a few rules. The lexical grammar for this language looks something like this:

```
leftParenthesis  = '('
rightParenthesis = ')'
letter           = 'A' | 'B' | 'C' | …
digit            = '0' | '1' | '2' | …
number           = ('+'digit|'-'digit|digit) digit*
alphanumeric     = letter | number
// …
```

You don’t use `System.Text.RegularExpressions.Regex` for this; it’s slow, and has features you won’t need.

How can we guarantee that we can tokenize any possible string? We don’t need to; as long as we explicitly handle the case of strings we can’t tokenize, we’re covered. I do this by having an extra token type for unrecognized characters. These are eventually mapped into errors the user sees.

How can we guarantee that we can tokenize any string representing a valid program without seeing an unrecognizable character? Because the parser is designed around a formalism (a context free grammar) which maps lexemes to abstract syntax trees, and the only valid programs are those which can be constructed from repeated applications of the production rules in the parser’s grammar. We have changed the scope of the problem from "any possible string" to "any possible sequence of lexemes."

Right away we have a big win in the number of test cases. Any "character" in a
string could be one of 2^16 UTF-16 code points, but the number of possible
lexemes is considerably smaller. A real language would have [maybe 10 times more](https://github.com/whitequark/parser/blob/master/lib/parser/lexer.rl),
but that’s still better than testing an input of any possible Unicode code point:

``` fsharp
type Lexeme =
    | LeftParenthesis
    | RightParenthesis
    | Identifier    of string
    | LiteralInt    of int
    | LiteralString of string
    | Unrecognized  of char
```

We can test the lexer in isolation with a much smaller number of test cases.

The example I gave was a very simple expression, but real-world programs obviously contain more complicated expressions. Also, real-world code is often invalid and must be rejected by the compiler. Some coding errors cannot be detected until further on in the compilation pipeline, but there are possible errors at the lexing stage. For example, in my language, identifiers must begin with a letter, so the expression

```
(| 1)
```

…maps to:

```
LeftParenthesis
Unrecognized '|'
LiteralInt 1
RightParenthesis
```

Importantly, we should be able to examine any character of a real-world string, and map it into one of these types. The `Unrecognized` type serves as a kind of fall through for characters which do not fit into the types in the union.

F#’s exhaustiveness checking ensures that we cannot forget to handle a particular case even if we add additional lexemes to the language specification later. As a simple example, consider this pretty print function which takes a list of lexemes and produces a string similar to the originally parsed source code:

```
let private prettyPrintLexeme = function
| LeftParenthesis          -> "("
| RightParenthesis         -> ")"
| Identifier    identifier -> identifier
| LiteralInt    num        -> num.ToString()
| LiteralString str        -> sprintf "\"%s"\" str
| Unrecognized  ch         -> ch.ToString()

let prettyPrint =
    List.map prettyPrintLexeme
    >> String.concat " "
```

If we were to, after the fact, add an additional type of lexeme, but forgot to
modify the `prettyPrint` function, we would receive a compiler warning since the
function would no longer be exhaustive.

### The Rest of the Pipeline
What about parsing, type checking, and the rest of the compilation pipeline? Formalisms exist for those, as well.

| Compilation phase	| Formalism |
|-------------------|-----------|
| Parsing	          | Context free grammar |
| Optimization	    | Algebra |
| Type checking	    | Logical inference rules |
| Code generation	  | Denotational semantics |

### Isn’t This Just Big Design Up Front?
The idea of basing your implementation design around in an exhaustive specification might sound like a big design up front, but there is an important difference. The formalisms used in implementing a compiler are "off the shelf." Nobody has to sit down and create them, because they have been refined over decades of compiler implementations. You simply need to know that they exist.

If "formal methods" sounds too snobby for your taste, you can simply call this "programming with proven recipes."

And of this downside of this methodology is that it becomes big design up front in those cases when there is not an off the shelf formalism available for your use. That’s OK! The important thing is to know when these formalisms exist in how to use them, when necessary.

The [full source code for this post](https://github.com/craigstuntz/TinyLanguage) is available.
