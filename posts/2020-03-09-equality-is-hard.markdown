---
title: Equality Is Hard
tags: mathematics, computer science, plt, equality
---

As the joke goes, there are two hard problems in computer science: cache invalidation and naming things.[^cache] 
But I'd suggest there's a much harder problem, namely, `=`. Did you miss it? The equals sign, `=`, is small,
but I'm going to argue that the use and misuse of equals is at the root of a large number of problems in 
software engineering. 

## How Equality Should Work

I am going to show how equality in programming languages is often broken. But before I can do that, I have 
to talk about how it _should_ work, and it turns out that's not simple! When we talk about how equality 
"should work," we have to say what this means in a certain context, because it turns out there are lots of 
different ways that equality _can_ work, and many of them are valid in different contexts. 

> _The heart and soul of mathematics consists of the fact that the "same" objects can be presented to us in 
> different ways._ <br/>
> -Barry Mazur, [When is one thing equal to some other thing](http://people.math.harvard.edu/~mazur/preprints/when_is_one.pdf)

### Laws

Now I said that we can have different definitions of equality in different contexts, but despite this there
are some things which should always be true. These are the laws of equality.

Equals is a **binary relation**[^BinaryRelation] that is: 

* **Reflexive**, so that `a = a` for all values of `a`.
* **Symmetric**, so that `a = b` implies `b = a` and vice versa. 
* **Transitive**, so that if `a = b` and `b = c` then `a = c`

In the programming world, we need to add a law, because programmers do weird things sometimes:

Equals must be:

* **Consistent**, so that if `a = b` and no field changes on `a` or `b`, `a = b` will still be true if we check
  it later on.

The above seems simple enough, although popular programming languages manage to screw up even those trivial
rules. But there are more concerns about equality which are harder to state quite so concisely.

### Structural Equality

One difference in how programming languages implement equality is structural equality and reference equality. 

**Structural equality** asks if two references are _the same value._ This is the default in F#:

```fsharp
type MyString = { SomeField : string }
let  a = { SomeField = "Some value" }
let  b = { SomeField = "Some value" }
if a = b then // returns true, enters "then" block
```

This is _not_ true in C#; C# uses **reference equality**. Reference equality asks if the two objects being
compared are the same object. In other words, does the variable point at the same area of memory? A 
reference to two different blocks of memory will be unequal even if their contents are identical:

```cs
class MyString {
    private readonly string someField;
    public string SomeField { get; }
    public MyString(string someField) => this.someField = someField;
}
var a = new MyString("Some value");
var b = new MyString("Some value");
if (a == b) { // returns false, does not enter block
```

Other languages let you choose. Scheme, for example, provides `equal?` to check structural equality and
`eq?` to check reference equality. Kotlin provides `==` for structural equailty and `===` for 
reference equality (don't confuse these with JavaScript's `==` and `===` operators which are... something 
else entirely).

When does it make sense to use structural equality in your programs? In the absence of mutation (changing
the values of variables), nearly always! Most programming languages that I'm aware of do structural 
comparisons on value types such as `integers`. Well, except Java, which has confused generations of 
programmers with an `int` value type which does a structural comparison and an `Integer` reference type which, 
well, the best thing you can say is 
[don't use == on Integer](https://stackoverflow.com/questions/1700081/why-is-128-128-false-but-127-127-is-true-when-comparing-integer-wrappers-in-ja). 
Python [has similar issues with `is`](https://stackoverflow.com/questions/306313/is-operator-behaves-unexpectedly-with-integers).

Structural comparison of reference types such as objects makes sense as well. Consider a unit test, where
you want to check that the object returned is equal to the value you expected. In a language with 
structural equality, this is trivial:

```fsharp
[<TestMethod>]
let ``The result of the calculation is the expected value``() = 
    let expected = { SomeField = "Some value"; SomeOtherField = 15; StillAnotherField = true; ... }
    let actual = calculate()
    Assert.AreEqual(expected, actual)
```

When a language does not have structural equality from the outset, developers will try to build it _ad hoc,_
and you end up with [this horror show](https://github.com/nunit/nunit/blob/4e10f475d88fec980f080461a64e6fc4b1e54b2b/src/NUnitFramework/framework/Constraints/NUnitEqualityComparer.cs#L133), which is now 
[permanently part of the NUnit framework](https://github.com/nunit/nunit/issues/1249).

### Reference Equality

But as I hinted above, there are certainly cases where structural equality does not make sense. One example 
is with languages which support mutation of variables, which is most of them.[^Mutation] When you can change the value
of a variable, it probably does not make sense to say that variable is equal to some other variable, _in
general._ Sure, you can say they're (structurally) equal _as of a moment in time,_ such as in last line of a 
unit test, but you can't generally imply that they're the same. This is a kind of subtle point, so let's look 
at an example.

Let's say I have an object which represents a person. In F#, with structural equality, I can write:

```fsharp
type Person = { Name : string; Age : integer; Offspring : Person list }
```

Now I have two friends, Jane and Sue. Both have a son named John, who is 15. They're _different_ people, but
the sons have the same name and age. No problem!

```fsharp
let jane = { Name = "Jane"; Age = 47; Offspring = [ { Name = "John"; Age = 15; Offspring = [] } ] }
let sue  = { Name = "Sue";  Age = 35; Offspring = [ { Name = "John"; Age = 15; Offspring = [] } ] }
```

I could also have written this: 

```fsharp
let john = { Name = "John"; Age = 15; Offspring = [] };
let jane = { Name = "Jane"; Age = 47; Offspring = [ john ] }
let sue  = { Name = "Sue";  Age = 35; Offspring = [ john ] }
```

The behavior of these two blocks is precisely the same. I can't distinguish the two sons, even though I know 
they're different people. That's OK! If I needed to distinguish them, I could add a hash of their DNA or something
to my `Person` type. But if I just need to know their name and age, it doesn't matter if I can distinguish the
two objects or not, because the values are the same, no matter how you slice it.

Imagine Jane's son changes his name to Pat. F# doesn't support mutating the values of variables, so I need
to make a new `Person` instance for John _and Jane:_

```fsharp
let newJane = { Name = "Jane"; Age = 47; Offspring = [ { Name = "Pat"; Age = 15; Offspring = [] } ] }
```

It seems weird to have a new variable, `newJane`, but in practice it doesn't create a problem. The code above
is fine. Now let's try this in C#, a language which is mutable by default:

```cs
var john = new Person("John", 15, null);
var jane = new Person("Jane", 15, new List<Person> { john });
var sue  = new Person("Sue",  15, new List<Person> { john });
```

Well, this code is clearly incorrect: If Jane's son changes his name to "Pat", I can change the reference 
directly:

```cs
jane.Offspring.First().Name = "Pat";
```

But I'll find that Sue's son's name has changed as well! Therefore, even though the two sons had the same values
at the start, before he changed his name, they _were not equal!_  I should have written: 

```cs
var jane = new Person("Jane", 15, new List<Person> { new Person("John", 15, null) });
var sue  = new Person("Sue",  15, new List<Person> { new Person("John", 15, null) });
```

...so that Jane and Sue's offspring were reference _unequal_ to each other. So reference equality is a sensible 
default in a language which supports mutation.

Another case where reference equality makes sense is when you know it's going to give the same result as
structural equality anyway. There is a certain performance overhead for testing structural equality, which 
is reasonable if you _actually need to test structural equality._ But if, for example, you create a large 
number of objects which you know are all different structually, it doesn't make sense to pay the overhead of
testing structural equality when you know that testing reference equality alone would give the same result.

### Equivalent Representations

_In the real numbers,_ 
[.999... (repeating infinitely) equals 1](https://en.wikipedia.org/wiki/0.999...). 
Note that the "real numbers" here are distinct from
the "Real" type in your programming language. Real numbers in math are infinite, and real numbers in your 
programming language are finite. So there is no notion of .999... in your programming language, but that's OK, 
because you can just use 1, which is the same value. 

This is, essentially, a choice that mathematicians made when formulating the real number system. If one 
[adds other objects, such as infinitessimals, to the system](https://betterexplained.com/articles/a-friendly-chat-about-whether-0-999-1/), then .999... and 1 are not equivalent. 

> _However, it is by no means an arbitrary convention, because not adopting it forces one either to invent 
> strange new objects or to abandon some of the familiar rules of arithmetic._ <br/>
> -Timothy Gowers, _Mathematics: A Very Short Introduction_[^Gowers]

Similarly, in the rational numbers, 1/2 and 2/4 represent the same value. 

Do not confuse these equivalances with the "loose" equivalence operator `==` found in JavaScript and PHP.
Unlike those operators, these equivalences follow the laws of equality. It is important to realize that 
equal objects can be represented differently.

In IEEE-754 floats, `-0 = 0`.

### Intensional vs. Extensional Equality

When is some function equal to some other function? Most programming languages will happily do a 
reference `=` comparison, and I suppose that's fine, but what would a structural equality comparison of a 
function even mean? Well, if we could use reflection to look into the implementation of the function, and 
see if it does the same thing? But what is "the same?" Would it have to have the same variable names? Are a 
quicksort and a merge sort "the same function?" 

Cutting to the chase, we say that functions are extensionally equal if they return the same outputs for the 
same inputs (regardless of internal implementation), and intensionally equal if their internal definition is 
the same. Of course, this is context-dependent. There may be a context where I need a constant time function 
and another context where the speed of the function doesn't matter. The important point is I need to have some 
context for equality and use it to compare the two functions.

I don't know of any programming language which even attempts to do anything beyond reference equality for 
functions. But it's easy to come up with examples where it would be useful! (An optimizer which removes
duplicate code, e.g.) You're on your own if you need this, but I have to say that not shipping an equals 
comparison is preferable to shipping one that's broken.

### Equality vs. Assignment

One of the first lessons we learn when becoming a programmer is that there are two different concepts which
we both call "equals." One is assignment, the other is testing equality. In JavaScript, these 
look like:

```JavaScript
const aValue = someFunction(); // Assignment
if (aValue === 3) {            // Test for equality
```

These are fundamentally different. Comparison returns a boolean; assignment, in an
[expression-oriented](https://en.wikipedia.org/wiki/Expression-oriented_programming_language)
language such as Ruby, returns the value assigned. 

So we can write Ruby code like this:

```ruby
a = b = c = 3
```

Which does indeed assign 3 to the variables `a`, `b`, and `c`. Don't try it with a reference type, 
though; it probably won't do what you want![^RubyValue]

In a 
[non-expression-oriented language like C#](https://fsharpforfunandprofit.com/posts/expressions-vs-statements/), 
assignment doesn't return anything. 

In math, we use the equals operator for both assignment and testing equality:

```TeX
if aValue = 3 ... 
where aValue = someFunction()
```

(And `=` is sometimes used for other relations in math, such as 
[congruence](http://mathworld.wolfram.com/Congruence.html). As with all things in math, 
context matters; you have to carefully consider what `=` might mean in a certain paper or book.)

Why does math not require two separate operators whereas programming languages do? You can tell from
context which one is intended, and not _all_ programming languages require different operators. F#, 
for example, uses `=` for both assignment and testing equality. Despite overloading `=`, assignment
and testing equality are _different_ operations.

```fsharp
let aValue = someFunction(); // Assignment
if aValue = 3 then           // Test for equality
```

The choice of syntax is partially due to heritage: F# is based on ML, which is based on math, and 
JavaScript syntax is based on Java -> C -> Algol -> FORTRAN. 

FORTRAN had to compile on [machines](https://en.wikipedia.org/wiki/Fortran#/media/File:IBM_704_mainframe.gif) 
where distinguishing these two cases from code syntax would be genuinely challenging, so it made sense to 
have two different operators. Then C took this "feature" to a high art, allowing code like:

```C
int aValue = someFunction(); // Assignment
if (aValue = 3) {            // Also assignment!
```

This code, for those without previous C experience, overwrites `aValue` with `3` and then, since the 
expression `aValue = 3` is equal to 3, the `if` test returns `TRUE` and execution continues inside
the `if` block.  This is frequently an error, leading many C programmers to reverse the values inside
an `if` block out of habit to avoid making the mistake:

```C
int aValue = someFunction(); // Assignment
if (3 == aValue) {           // Test for equality

// [...]

if (3 = aValue) {            // Syntax error: Cannot assign aValue to 3.
```

## How Equality Should Not Work

I hope I've shown by now that equality is _not_ simple, and that the "correct" implementation of equality can 
vary depending upon context. Despite that, programming languages often get the simple parts wrong! Very 
often, this is caused by the _combination_ of equality with other language features, such as implicit
type conversion. 

### Common Mistake: Equality Isn't Reflexive

Recall that the reflexive law of equals requires all values to be equal to themselves, `a = a`.

In .NET, if you call `Object.ReferenceEquals()` on a value type, the arguments are _separately_ boxed before
the method runs, so it returns false even if you pass _the same instance:_

[From the docs](https://docs.microsoft.com/en-us/dotnet/api/system.object.referenceequals?view=netframework-4.8):

```cs
int int1 = 3;
Console.WriteLine(Object.ReferenceEquals(int1, int1)); // Prints False
```

This means it is not necessarily true that `a = a` in any .NET language, so the reflexive law is broken.

In SQL, `NULL` is not equal to itself, so the expression `NULL = NULL` (or, more probably, `SOME_EXPRESSION = SOME_OTHER_EXPRESSION` when both of them might be `null`) will return false. This leads to messes like:

```sql
WHERE (SOME_EXPRESSION = SOME_OTHER_EXPRESSION)
  OR (SOME_EXPRESSION IS NULL AND SOME_OTHER_EXPRESSION IS NULL)
```

Or, more likely, just a bug where the developer forgot about the special rules for `NULL`. If your DB server's
SQL dialect supports [`IS NOT DISTINCT FROM`](https://modern-sql.com/feature/is-distinct-from) then this does 
what `=` should do. (Or should I say it does `NOT` not do what `=` should do?) Otherwise you'll just have to live 
with SQL like the above. The best fix is to make your columns non-nullable when possible.

This is [also true of IEEE-754 floats](https://stackoverflow.com/a/1573715/7714); the standard states that 
`NaN != NaN`. A different explanation than the one given in the link for this is that "NaN" represents some 
unspecified "non-number" result, not necessarily the _same_ unspecified non-number result as that of a different
calculation, so it's incorrect to compare them. For example, `square_root(-2)` and `infinity/infinity` are both 
`NaN`, but they're clearly not the same! Similar explanations are given for SQL's `NULL` sometimes. 
One problem with this is that it makes the term very overloaded: Is `NaN` and `NULL` an _unknown_ or _imprecise_ 
value or the known _absence_ of a value? 

One way of handling such situations, which do not occur in routine floating point calculations, would be 
a [union type](https://en.wikipedia.org/wiki/Union_type). In F#, one could write:

```fsharp
type MaybeFloat = 
    | Float          of float
    | Imaginary      of real: float * imaginary: float
    | Indeterminate
    | /// ...    
```

... and then you could handle these terms appropriately in calculations which needed them. Use a 
[_signaling_ NaN](https://en.wikipedia.org/wiki/NaN#Signaling_NaN) to throw an exception in calculations which 
you don't expect will have NaNs at all. 

Rust offers the [Eq](https://doc.rust-lang.org/std/cmp/trait.Eq.html) and 
[PartialEq](https://doc.rust-lang.org/std/cmp/trait.PartialEq.html) traits. Not implementing `Eq` is supposed 
to be a signal that `==` is not reflexive, and floating point types in Rust do not implement it. But if you don't 
implement `Eq`, you can still call `==` in your code. Implementing `Eq` allows your object to be used as a key 
in a hash map and possibly results in behavior changes in other places as well.

But there are even more significant problems with `=` and floats. 

### Common Mistake: Equals Is _Too_ Precise

I guess many developers are familiar with the problem of comparing IEEE-754 floating point numbers, which are
the "float" or "double" implementation for most programming languages. `10 * (0.1)` does not equal `1`, because
"0.1" is actually equal to `0.100000001490116119384765625` or `0.1000000000000000055511151231257827021181583404541015625`.
If you're not familar with this issue, you can [go read about it](https://randomascii.wordpress.com/2012/02/25/comparing-floating-point-numbers-2012-edition/), but the point is that it's rarely safe to do an `==` comparison
on a floating point number at all! You have to ask yourself which digits are significant and compare accordingly.

(Worse, the float type backs other types, such as `TDateTime` in 
[some languages](http://docs.embarcadero.com/products/rad_studio/delphiAndcpp2009/HelpUpdate2/EN/html/delphivclwin32/System_TDateTime.html), 
so even in cases where equality comparisons might _make sense,_ they don't necessarily _work._)

The correct method of comparing floating point numbers is to see if they're "close," and [what "close" means
varies depending on context](https://randomascii.wordpress.com/2012/02/25/comparing-floating-point-numbers-2012-edition/).
It's not something you can cram into a `==` operator. If you find yourself doing this a lot (say, once), you
might consider using a different data type, such as a fixed precision decimal number. 

So why do programming languages offer `==` comparisons on a type when they can't support it? Well, because 
they offer `==` on _every_ type, it works on most of them, and they just shrug about the rest and chastize 
programmers for not knowing which language feature they should not use. 

Not every programming language, mind you. Standard ML doesn't offer `=` comparisons on reals. It's a compiler
error if you try!

The [implementation notes](http://sml-family.org/Basis/real.html) state:

> Deciding if `real` should be an equality type, and if so, what should equality mean, was also problematic. 
> IEEE specifies that the sign of zeros be ignored in comparisons, and that equality evaluate to false if either 
> argument is NaN. These constraints are disturbing to the SML programmer. The former implies that `0 = ~0` is true 
> while `r/0 = r/~0`[^SMLUnary] is false. The latter implies such anomalies as `r = r` is false, or that, for a `ref cell rr`, we 
> could have `rr = rr` but not have `!rr = !rr`. We accepted the unsigned comparison of zeros, but felt that the reflexive 
> property of equality, structural equality, and the equivalence of `<>` and `not o =` ought to be preserved. Additional 
> complications led to the decision to not have `real` be an equality type.

By blocking `=` for reals, SML forces the developer to think about what kind of comparison they actually 
need, which is a great feature, I think!

F# offers the `[<NoEquality>]` attribute to mark custom types where `=` should not be used. Pity they didn't mark
the `float` type with it!

### Common Mistake: "Equals" Isn't

PHP has two separate operators, `==` and `===`. The 
[documentation for `==`](https://www.php.net/manual/en/language.operators.comparison.php), which is named 
"Equal," states, "**TRUE** if `$a` is equal to `$b` after type juggling." Unfortunately, this means
that the `==` operator is unreliable:

```php
<?php
  var_dump("608E-4234" == "272E-3063"); // true
?>
```

Although we're comparing _strings_ here, PHP sees that they can be converted to a number, so it does.
The numbers turn out to be very small (the first argument, for example, is 608 * 10<sup>-4234</sup>), 
and, as we've already discussed, comparing floating point numbers is hard. Casting both of these to
a `float(0)` results in rounding them to equal values, so the comparison returns true. 

Note this is different than the behavior of JavaScript, which also has similar (but not the same!)
`==` and `===` operators; JavaScript would see that both sides are strings and return false for 
this comparison.

Fortunately, PHP has the `===` ("Identical") operator, which behaves correctly in this case. I would 
say never use `==`, but `==` 
[does a structural comparison on objects](https://www.php.net/manual/en/language.oop5.object-comparison.php), 
which might be something you want! Instead, I'll say: Use extreme caution with `==`, because it's broken 
on primitive types.

### Common Mistake: Equality Isn't Symmetric

If you override `.equals()` in Java, it is _your responsibility_ to ensure that the laws of equality hold!

It is _very easy_ to implement a comparison which is not symmetric, that is, `a.equals(b) != b.equals(a)`,
if you're not paying attention.

Even if we remove null from the picture (because it would be a `NullPointerException` in one case and the 
[contract for `.equals()` allows you to do this](https://docs.oracle.com/javase/8/docs/api/java/lang/Object.html#equals-java.lang.Object-)), 
if you subtype a class and override `.equals()` then you had better be careful!

```java
@Override
public boolean equals(Object o) {
    if (this == o)
        return true;
    if (o == null)
        return false;
    if (!o.getClass().isAssignableFrom(getClass())) // Danger! This is a mistake!
        return false;
    ThisClass thisClass = (ThisClass) o;
    // field comparison
    // ...
}
```

If `ThisClass` and `ASubtypeOfThisClass` both override `.equals()` with code like this, `a.equals(b)` may 
not equal `b.equals(a)`! The correct comparison would be:

```java
    if (getClass() != o.getClass())
        return false;
```

This is not just my opinion; the 
[contract for `Object.equals()` requires it](https://docs.oracle.com/javase/8/docs/api/java/lang/Object.html#equals-java.lang.Object-).

### Common Mistake: Equality Isn't Transitive

Remember one of the laws for equals comparisons is that they should be transitive; if `a = b` and 
`b = c` then `a = c`. Unfortunately, when coupled with type coersion, languages often fail at this.

In JavaScript, 

```javascript
'' == 0;      // true
0  == '0';    // true
'' == '0';    // false!
```

Never use `==` in JavaScript. Use `===` instead.  

### Common Mistake: Equality Is Inconsistent

In Kotlin, `==` returns different values depending on the type of the variable, even for the same variable:

```kotlin
fun equalsFloat(a: Float, b: Float) {
  println(a == b);
}

fun equalsAny(a: Any, b: Any) {
  println(a == b);
}

fun main(args: Array<String>) {
  val a = Float.NaN;
  val b = Float.NaN;
  equalsFloat(a, b);
  equalsAny(a, b);
}
// prints false, true
```

This is [an unfortunate combination of language features](https://kotlinlang.org/docs/reference/basic-types.html#floating-point-numbers-comparison) which results in some pretty unintuitive behavior.

### Common Mistake: Using Reference Equality When Structural Equality Is Needed

Consider the following [MSTest](https://docs.microsoft.com/en-us/dotnet/core/testing/unit-testing-with-mstest) 
unit test in C#:

```cs
[TestMethod] 
public void Calculation_Is_Correct() {
    var expected = new Result(SOME_EXPECTED_VALUE);

    var actual = _service.DoCalculation(SOME_INPUT);

    Assert.AreEqual(expected, actual);
}
```

Does this work? We can't tell! `Assert.AreEqual()` will eventually call `Object.Equals()`, which does a reference
comparison by default. Unless you've overridden `Result.Equals()` to do a structural comparison instead, the 
unit test is broken. The contract for `Object.Equals()` says that you 
[should not override it at all if your type is mutable](https://docs.microsoft.com/en-us/dotnet/api/system.object.equals?view=netframework-4.8), which is reasonable in general but probably not what you want for a unit test. 
(This is because `.Equals()` is expected to match `.GetHashCode()`, and 
[the hash code is expected not to change](https://docs.microsoft.com/en-us/dotnet/api/system.object.gethashcode?view=netframework-4.8) 
over the lifetime of the object.)
The closest thing the .NET framework has to a "guaranteed structural" comparison for reference types is 
`IEquatable<T>`, which `Assert.AreEqual()` doesn't use, even if it's implemented.

It's [worse if you use NUnit](https://github.com/nunit/nunit/issues/1249).

(Java's `Object.hashCode`, by contrast, is 
[allowed to change when the object's fields change](https://docs.oracle.com/javase/7/docs/api/java/lang/Object.html#hashCode()).)

## How to Think About Equality

Wow, I've now written 4000 words about the `=` operator and I'm not finished yet! That seems, well, out of 
proportion to the size of the operator. Why is this so complicated? Two reasons, basically:

* _Inessential complexity:_ Our programming languages _don't serve us well_ with equivalence comparisons. They 
  are often entirely broken, and even when they're not, they don't make it obvious when, for example, they'll 
  do a structural comparison vs a reference comparison. 
* _Essential complexity:_ Equivalence is often _genuinely complicated_ in places where it is needed, such as
  when comparing floating point numbers, and it gets even harder in edge cases like comparing functions.

Another way to divide this up is "stuff which should be fixed by programming language _implementors_" (the
"inessential complexity" above) and "stuff which must be resolved by programming language _users._

### What Programming Languages Should Do

With regards to inessential complexity, the situation we find ourselves in today, with mostly-broken 
implementations of equivalence in nearly every mainstream programming language is just a crying
shame. This "simple operation which must obey certain laws" is _exactly_ the sort of thing we depend on 
programming languages to get right! But it appears to me that only SML has really considered having a lawful
equality in both its semantics and its runtime/standard library, and SML isn't entirely mainstream. 

First, programming languages should make it simple to create types where equality comparison is disabled 
because it makes no sense (like 
[`[<NoEquality>]` in F#](https://msdn.microsoft.com/en-us/visualfsharpdocs/conceptual/core.noequalityattribute-class-%5bfsharp%5d)) 
and they should use this feature in their standard library where needed, such as on floating point types. 

Programming languages must make the difference between structural equality and reference equality crystal 
clear. There should never be a case where it's unclear what you're doing. Most programming lanuages overload
`==` to mean both structural equality or reference equality depending on the type of reference, most commonly
value types vs. reference types, and this is guaranteed to confuse developers. 

Kotlin comes very close to getting this right with its `===` for reference equality and `==` for structural
equality, although for some reason it translates `===` to `==` for value types, instead of just failing to 
compile for that. The goal should be reducing developer confusion. You want the developer to see `===` and 
think "reference equality," not "more equals signs is better."

F# mostly gets this right by 
[making reference equality very hard to use](https://msdn.microsoft.com/en-us/visualfsharpdocs/conceptual/languageprimitives.physicalequality%5B't%5D-function-%5Bfsharp%5D). 

I don't know of any language which has mutable by default variables which handles structural comparsions in a 
non-confusing way. But it's easy to imagine what it might look like! Have a reference equals and structural 
equals operator which is only supported in contexts where the language can reasonably expect to support it. 
For example, if .NET did not do the boxing funkiness with `Object.ReferenceEquals` and value types (it could 
just fail to compile if you tried) and had something akin to `IEquatable<T>` which would allow you to use a 
structural comparison operator, that seems like a pretty good solution to making it clear to developers 
which is which.

### What Programmers Should Do

One might look at the length of this post and say, "Wow, equality is really complicated! I'm going to give
up coding and become a soybean farmer." But this post is as long as it is mostly because so many languages
do equality _wrong._ Doing equality correctly does requre some thought, but not _too much_ though. Certainly
less than soybean farming.

When doing an equality comparison on an existing type, stop and ask yourself:

* Does it make sense to do an equality comparison at all here?
* If so, does a structural or a reference comparison make sense?
* What support does my programming language provide for the appropriate style of comparison?
* Does my programming language implement equality correctly for this comparison?

You can ask yourself similar questions when designing a custom type:

* Should my type support equality comparisons at all? Or do they need a more complicated comparison, 
  as with a float?
* Will my type be mutable? How might that affect equality?
* Would a reference comparison, a structural comparison, or both make sense?

If your type is mutable, consider if you can change it to be immutable. You can do this even in a language which
is mutable by default! Beyond giving you more options with respect to equality comparisons, there are many other
benefits of an immutable architecture as well. The C# Roslyn compiler, which uses immutable data structures 
throughout, is a great example of this:

> _The third attribute of syntax trees is that they are immutable and thread-safe. This means that after a tree is obtained, it is a snapshot of the current state of the code, and never changes. This allows multiple users to interact with the same syntax tree at the same time in different threads without locking or duplication. Because the trees are immutable and no modifications can be made directly to a tree, factory methods help create and modify syntax trees by creating additional snapshots of the tree. The trees are efficient in the way they reuse underlying nodes, so a new version can be rebuilt fast and with little extra memory._<br/>
> from the [.NET Compiler Platform SDK docs](https://docs.microsoft.com/en-us/dotnet/csharp/roslyn-sdk/work-with-syntax)

## Credits

Thank you to Paul Blasucci, Jeremy Loy, Bud Marrical, Michael Perry, Skyler Tweedie, and Thomas Wheeler for reading 
drafts of this article and giving me feedback.

### References

This post was inspired by Barry Mazur's wonderful math paper, 
"[When is one thing equal to some other thing?](http://people.math.harvard.edu/~mazur/preprints/when_is_one.pdf)" 
which uses category theory to answer the question for math. 

Thanks to Tommy Hall, who drew my attention to [this 1993 paper](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.23.9999), which, discusses many of the issues covered in this post and proposes a solution for Common Lisp.

Simon Ochsenreither has a nice series on problems with equality and fixing Haskell. 
[Overview](https://soc.me/languages/equality-and-identity-part1), 
[Problems](https://soc.me/languages/equality-and-identity-part2.html), 
[Solution](https://soc.me/languages/equality-and-identity-part3.html), 
[Fixing Haskell](https://soc.me/languages/equality-and-identity-part4), 
[Implementation in Dora](https://soc.me/languages/equality-and-identity-part5.html).

Hillel Wayne pointed me to this great essay, ["The Semantics of Object Identity."](https://www.bkent.net/Doc/semobjid.htm)

Brandon Bloom provided a link to the paper ["The Left Hand of Equals"](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/45576.pdf) 
which "takes a reflexive journey through fifty years of identity and equality in object-oriented languages, and
ends somewhere we did not expect: a 'left-handed' equality relying on trust and grace."

[^cache]: This is [probably attributable to Phil Karlson](https://skeptics.stackexchange.com/questions/19836/has-phil-karlton-ever-said-there-are-only-two-hard-things-in-computer-science)

[^BinaryRelation]: A "binary relation" deserves a little bit of explanation, but this gets into a little math, so
feel free to ignore if it doesn't help you. We have two sets _A_ and _B_. (They might be the same
set.) For any two members _a_ and _b_ of the sets, we want a rule which says whether they're in the relation or
not. So if _A_ and _B_ are the integers, the ordered pair _(1, 2)_ is not in the relation "is equal to" but the 
ordered pair _(5, 5)_ is in the relation. A relation is a subset of the cross product of the sets.

[^Gowers]: Gowers, Timothy, _Mathematics: A Very Short Introduction_, p. 60

[^Mutation]: Phil Hagelberg [tells me](https://lobste.rs/s/vpfpyk/equality_is_hard#c_hxunkw) the problem isn't
mutation of _variables_ but _data structures,_ which is a subtle but fair distinction.

[^RubyValue]: `a = b = c = []` in Ruby assigns _the same reference_ to `a`, `b`, and `c`. So if you mutate
`a`, you'll mutate `b` and `c` at the same time. That's probably not what you wanted, otherwise what would
be the point of having three separate references? In contrast, with a value type like `Integer`, mutating 
`a` will _not_ change the value of `b` or `c`.

[^SMLUnary]: `~` is the SML operator for unary negation, so `~0` should be read as "negative zero."