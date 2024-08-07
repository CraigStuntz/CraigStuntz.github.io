---
title: "A Very Gentle Introduction to Type Checking, Chapter 1.2: "
series: A Very Gentle Introduction to Type Checking
chapter: "1.2"
chapterName: Evaluating the Untyped Lambda Calculus
tags: compilers, type checking
---

<div class="toc">
* Introduction: Type checkin'
* 1: The Untyped Lambda Calculus
  * 1.1: What Even Is the Untyped Lambda Calculus (Etc.)?
  * 1.2: Evaluating the Untyped Lambda Calculus
  * 1.3: Understanding Normalization
* 2: The Simply Typed Lambda Calculus
  * 2.1: What Even Is the Simply Typed Lambda Calculus?
  * 2.2: Bidirectional Type Checking
* 3: Tartlet
</div>

If you've made it this far, congratulations! The last article was a ton of 
concepts; from here on out we'll be writing code, which I suspect will make 
many programmers feel far more comfortable. 

Many people seem surprised when I tell them that I write Swift programs without
Xcode, so a few notes on that. First, you'll need to 
[install the Swift command-line tools and the Apple swift-format utility](https://github.com/CraigStuntz/bidi/).

I use VS Code to edit, with the [Swift extension](https://marketplace.visualstudio.com/items?itemName=sswg.swift-lang).
If you want to use Xcode instead, that should work fine, too!

Then you can:

```bash
$ mkdir bidi
$ cd bidi
$ swift package init --type executable
```

...to get a templated Swift project. However, you probably just want to clone 
[my repository](https://github.com/CraigStuntz/bidi/) instead. From there you
can type `swift run` or `swift test` to do what it says on the tin, and if 
you're using the Swift extension in VS Code then it will generate 
`.vscode/launch.json` and `.vscode/tasks.json` files for you.

<div class="highlight">
**1 Evaluating Untyped λ-Calculus**

Let’s start with an evaluator for the untyped λ-calculus. Writing an evaluator
requires the following steps:

* Identify the values that are to be the result of evaluation
* Figure out which expressions become values immediately, and which require computation
* Implement datatypes for the values and helper functions for computation
In this case, for the untyped λ-calculus, the only values available are closures,
and computation occurs when a closure is applied to another value.
</div>

As I noted earlier, there is one and only one kind of value in the untyped 
lambda calculus, namely an anonymous closure (a function which can capture 
free variables, meaning variables which are not arguments) which takes a single argument and 
returns exactly one result. However, the _syntax_ for the untyped lambda 
calculus also includes things like variables with names, so we must account for that when
interpreting it. 

If we were to write a full evaluator for the untyped lambda calculus, it 
might look something like this:

1. Lex the source code.
1. Parse lexemes into abstract syntax tree (AST).
1. Interpret AST, producing a value.[^list]
1. Output result.

But here we will be doing something a bit simpler, namely only step 3. In order
to do that, we will need to start with a representation of the AST and the 
values.

In the version of the untyped lambda calculus that we will be 
using, there are variable assignments followed by a single expression, which 
may contain subexpressions, as the body of the program. This
final expression will be evaluated to produce the single value of 
output from the program.

So let's write a type for expressions and values.

<div class="highlight">
**1.1 Syntax**

In this section, the following representation of the untyped λ-calculus is used:

```haskell
data Expr
= Var Name
| Lambda Name Expr
| App Expr Expr
deriving Show
```
</div>

Here's the corresponding Swift:

```swift
public indirect enum Expr: Equatable {
  /// Associated value is the variable name
  case variable(Name)
  /// Associated values are the argument name and the lambda's body, respectively
  case lambda(Name, Expr)
  /// Associated values are bunction body and the argument, respectively
  case application(Expr, Expr)

  // more coming soon!
}
```

Some notes on this: 

The `indirect` here is required by the Swift compiler to make a self-referential
`enum`. Since `Expr` includes `Expr` as an 
[associated value](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/enumerations/#Associated-Values), 
`indirect` is required. The reason for this is that Swift must use a less optimal 
representation for the compiled `enum` when its size is not known, so this is an
"opt-in" feature. 

As noted earlier, I've added `: Equatable` to the type definition so that we can
do equality comparisons on values of type `Expr`. We will need to do that in the
unit tests.

Because the associated values in Swift are unnamed (like Haskell), I like to 
include docstrings to keep track of what their meanings are. This is especially
important with `application`, where you have two different `Expr`s, and their
order is reversed from `lambda`! I think ideally I would have put these into the
same order, but I am trying to keep my code as close to David's as possible. 

Swift enum members are conventionally lower case and `var` is a reserved word in
Swift, so I spelled out `variable`. Having done that, it seemed inconsistent to 
use `app`, so I made it `application`. `lambda` is a function definition, 
whereas `application` means you're applying (passing) an argument to the defined 
function.

The Haskell code has `deriving Show`, which essentially means, "generate code to
convert these instances to a string." This isn't necessary in Swift, but 
[the `dump()` function in Swift](https://developer.apple.com/documentation/swift/dump(_:name:indent:maxdepth:maxitems:)) doesn't handle `enum`s so well, so I use 
[a third party package called `swift-custom-dump`](https://swiftpackageregistry.com/pointfreeco/swift-custom-dump)
which produces much nicer-looking output.

<div class="highlight">
This corresponds closely to the typical presentation as a grammar:

```bnf
e ::= x
    | λx.e
    | (e e)
```

with the usual conventions regarding associativity and precedence of lambda
and application, namely that the body of a λ extends as far as possible to the
right and that function application associates to the left. For instance, `λf.f f f`
corresponds to `λf.((f f) f)`, not `((λf.f) f) f` or `λf.(f (f f))`.
</div>

This is not Haskell; it's [BNF](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form).
This grammar means that an expression in the untyped lambda calculus (well, the
version that we'll be using) can any one
of: 

* a reference to a variable
* a definition of a lambda (closure)
* or an application of an argument to a closure (function application)

Not included in this tiny grammar are variable definitions which we will handle separately. 

<div class="highlight">
**1.2 Values and Runtime Environments**

A closure packages an expression that has not yet been evaluated with the run-
time environment in which the expression was created. Here, closures always
represent expressions with a variable that will be instantiated with a value, so
these closures additionally keep track of a name.

```haskell
data Value
  = VClosure (Env Value) Name Expr
    deriving Show
```

Runtime environments provide the values for each variable.
</div>

In Swift, this looks like:

```swift
public enum Value {
  /// The associated values here are the environment, the variable (function argument) name, and the body
  case vclosure(Env, Name, Expr)

  // ...more to come!
}

```

I've made most types `public` here to facilitate exploration using Swift's REPL.
There will be examples of this usage following.

Why use an `enum` for this? There will be other `Value`s coming soon. Why not
make `Value` a `protocol` and `VClosure` an implementation? Mostly because of an
annoying [limitation with Swift's generics](#huge-digression-on-swift-generics-feel-free-to-ignore), 
but also this representation works and keeps fairly close to the Haskell code 
I'm transliterating.

<div class="highlight">
In this implementation, environments are association lists, containing pairs of 
variable names and values. Earlier values override later values in the list, and 
the initial environment is empty. The type of environments is polymorphic over 
the contained values so that it can be used for other value representations 
later.

```haskell
newtype Name = Name String
  deriving (Show, Eq)

newtype Env val = Env [(Name, val)]
  deriving Show

initEnv :: Env val
initEnv = Env [ ]
```

It is possible to map a function over an `Env`, so it is a `Functor`.

```haskell
instance Functor Env where
  fmap f (Env xs) =
    Env (map (λ(x, v) → (x, f v)) xs)
```
</div>

My Swift version is:

```swift
public typealias Name = String
public typealias Env = [Name: Value]
```

A subtle difference here is that David's `Env` is generic over the `value`, 
whereas my `Env` is just an alias to a dictionary with specific values for the  
`Key` and `Value` types. (For technical reasons, having a generic structure like
David's is [hard in Swift](#limitations-on-generic-constraints-in-extensions).)
A Swift dictionary already has a `map` implementation. 

<div class="highlight">
Looking up a value in an environment might fail, so the function that performs
the lookup might return a message instead of a value.

```haskell
newtype Message = Message String
  deriving Show

failure :: String → Either Message a
failure msg = Left (Message msg)

lookupVar :: Env val → Name → Either Message val
lookupVar (Env [ ]) (Name x) =
  failure ("Not found: " ++ x)
lookupVar (Env ((y, v) : env′)) x
  | y == x = Right v
  | otherwise = lookupVar (Env env′) x
```
</div>

In Swift we have 
[the built-in `Result<Success, Failure>` type](https://developer.apple.com/documentation/swift/result)
for such situations, so let's use that:

```swift
public enum Message: Error {
  case notFound(Name)
}

extension [Name: Value] {
  public func lookup(name: Name) -> Result<Value, Message> {
    guard let value = self[name] else {
      return .failure(.notFound(name))
    }
    return .success(value)
  }
}
```

And now we can try it out at the Swift REPL. Note that using a SwiftPM project
with the Swift REPL requires that you start the REPL using:

```bash
$ swift run --repl
```

...and *not* using `swift repl`, a "feature" which has confused me to no end. 
Just pretend `swift repl` doesn't even exist and use `swift run --repl` instead.
Anyway, you can do:

```bash
$ swift run --repl
  1> import Untyped
  2> let env = ["id": Value.vclosure([:], "x", .lambda("x", .variable("x")))] 
  3> env.lookup(name: "id") 
$R0: Result<Untyped.Value, Untyped.Message> = success {
  // ...
  4> env.lookup(name: "blarf")
$R1: Result<Untyped.Value, Untyped.Message> = failure {
  // ...
```

So everything works as expected, including the REPL!

## Huge Digression on Swift Generics; Feel Free to Ignore

Swift generics are nice when they work, but they are somewhat limited in comparison
with generic types in other languages. They are being improved, but they have 
some hard limits you just have to work around.

### Limitations On Use of Protocols as Generic Constraints

The Swift documentation [says](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols/#Protocols-as-Types):

> The most common way to use a protocol as a type is to use a protocol as a 
> generic constraint.

Ok, let's give that a spin! This works fine:

```swift
protocol SomeProtocol {}
struct SomeGeneric<T> {}
struct SomeGenericWithSpecificTypeParameter<T: SomeProtocol> {}
typealias Instance = SomeGeneric<SomeProtocol>
```

This does not compile:

```swift
typealias InstanceWithSpecific = SomeGenericWithSpecificTypeParameter<SomeProtocol>
```

Message:

```
type 'any SomeProtocol' cannot conform to 'SomeProtocol' sourcekitdprotocol-type-non-conformance main.swift(9, 34): only concrete types such as structs, enums and classes can conform to protocols
```

### Limitations on Generic Constraints in Extensions

Let's say you're writing an extension for some existing class (e.g., 
`Array<Element>` and you want to specify some arbitrary generic type parameter 
`T` as part of the specialization of `Element`. Say for example you would like to 
extend Array<(String, T)>. Well.... you can't. Swift just doesn't have that 
feature. See the end of 
[this swift-evolution proposal](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0361-bound-generic-extensions.md#future-directions) (which was implemented), 
discussing "future directions":

<blockquote>
Writing the type parameter list after the extension keyword applies more 
naturally to extensions over structural types. With this syntax, an extension 
over all two-element tuples could be spelled

```swift
extension <T, U> (T, U) { ... }
``` 
</blockquote>

[^list]: A program in the untyped lambda calculus can include multiple values. 
         For example, you might define variables and then use those variable 
         definitions in an expression. The way the evaluator will be structured
         in David's tutorial is to have a list of defintions which will be used
         to evaluate a single expression, producing a single result. 