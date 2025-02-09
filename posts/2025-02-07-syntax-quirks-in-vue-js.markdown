---
title: "Syntax Quirks in Vue.js"
tags: vue.js, javascript
---

The markup used in a Vue.js `.vue` file is a _melange_ of JavaScript, TypeScript,
HTML, and a few other bits of punctuation thrown in for good measure. I 
encountered one of the odd corners of this today, and as it took me an hour
to figure all of this out and 
[the documentation sort of hand waves around it](https://vuejs.org/guide/essentials/template-syntax#using-javascript-expressions),
I thought I should write my notes down here.

Briefly, when you're calling a method there are not consistent rules regarding
whether or not you should put `()` after the method name. Sometimes you _can_
do this, and sometimes you _cannot,_ whereas other times the behavior of the 
document will be silently changed depending upon whether or not you use them.

If you have this in a `template`:
```html
<input :disabled="foo"/>
```
... and you know that `foo` looks like:
```javascript
foo: function() {
  return false;
}
```
...is that template right or wrong?

Or what if the template looked like:
```html
<input :disabled="foo()"/>
```
Now is it right or wrong?

The answer is: "You don't know if it's right or wrong, because I haven't told 
you where `foo` is defined (in `computed` or in `methods`), and that matters 
_a lot._ It also matters whether you place this function call in a `v-on` (`@`) 
or a `v-bind` (`:`) portion of the markup.

All of the examples here are using functions which take no arguments, for 
simplicity. Things get even more complicated when your function requires aguments!

[There's a playground here which will help as you read this.](https://play.vuejs.org/#eNrFV1mPEz8M/ypmHhCIbfv/A09lWC7xABKHON5GQumMuxM2k4wSTw+hfneczJWW3aW7oOWhbezE9i++4v5IXtT1dNVgMk9SwqpWgvA00wBpIVdhwUsSC9VyW7JEUZymZPlTnuamqhvCYlYhlaZIZ8zz/NXE6IhYSD3u3bsPxoI29GxgMYGupWZeM6+8ldHowhTbgfQMG1GeLgYoLDxK9psxzZw7kwmkUvN5eB5+nmZJ+H3VKcmS2Sm4rSaxAbTW2Dk4RA8aHUwmB/reGwKhlFmzYGz4CCQtiHkhnXdzwTj6ZQzlWlqPMPv/FedDBG7R1ffu35qzIyxXefz2ELGl6wk8/LPADVV6ZF7uR+xdkL52Pl6Z5TfUeYTRR//eVW0i/W1n3UjrtTPt8bHuYyLqzkxF70VaD8e4SNDN+0M9PzVqVKRkZOOrk/oM7ip68ps+ffeMnoBF1yhyIDVkSSl0odBORV2rLUjn6xYELBudkzQ6S2BdooataYC2NbIQGeAXB7CQZOx0vFmE6CboQqR+xfdtVU33zt0A4y8IftfQIAAZbxAhEh2mQ7ELYYV2CIJYgS7QAskKgR0OkmChTH7uRhsBryZpEQqTNxWvYWlN1cnyBS739ReWbQcHwI3g2QTBlWatYS2pDJotIzQNKanZPT3SuGnDgv3CO0JVxhHECZ2jJSE1p4cXW5d8H+/qtdA0QMooo/3KY5PUWO1gKZTDE9giRTHxpvrzJ7DAXDQOw37bSwJIXLHP9pDwy4HFFPx9U6y6vsOWlsheyjGdMXMwLIBsQ+UWVkI1eLn3Xhp2kll664xhbez5nehMOgtlF97D44aQtuekC3vwLo6PIQ+QGxIWBUetMgUq1pKbRpNPvXaonLVTJbeIcdZMXW5lTbzCTW0sQYFLwYkJP7xIIUjMh+zjwTFwffJ6d/QUO9EbmsN/Jy1jF/J8F6h+Vpn3pw+vdpH+wUIIdFc1rT7giolKN5Lm0GqKVFAp3TQgm0yGwuv0chT31bbfbfDdgHXvLblI84MHB+AOn4ojbuS/dz4sQyhSR9uuhwcEQ2b02hbGcv1OcqP8aMSF2CoM2oKmTj45ScjlRi/l2fS7M5r/aAQNPjWqWnKT/lB737ksGe6cJWGWeht43k/dzVimxPz8Av53t/G8LPnITQ3tCrNk2OOUPEPOQb/9+vN7ztFok/O0UXz6is1P6Ixq2t7nj71swtsSnQto31Q+ebmhfXGvN4Ta9ZfyQMf4Zgn/2/Kpc9nVR7iPpuEFZnfukt1PXL8G+A==)

From that playground we can derive this table, which I will explain below:

| `computed`/`methods` | () or not? | `v-on` result   | `v-bind` result   | 
| -------------------- | ---------- | --------------- | ----------------- |
| `computed`           | no ()s     | Not allowed     | Works correctly   |
| `computed`           | `()`       |	Not allowed     |	Syntax error      |
| `methods`            | no ()s     | Works correctly | Not what you want |
| `methods`			       | `()`       | Works correctly | Works correctly   | 

If your function is defined in `computed`, then using `()` will result in a 
syntax error (even though you have written a function). This is at least 
consistent and can be summarized concisely. Also, a function defined in 
`computed` cannot be used in a `v-on` (`@`) binding.

When you write your function in `methods` things get much less clear. You can 
use a `method` in either a `v-on` (`@`) or a `v-bind` (`:`) binding.

For a `v-on` binding, you are allowed to omit `()`, and the behavior
of the function will be exactly the same with or without it. That is:

```html
<input @input="inputMethod"/>
```
...and:

```html
<input @input="inputMethod()"/>
```
...will behave the same. This is ["sort of" documented](https://vuejs.org/guide/essentials/event-handling#calling-methods-in-inline-handlers).

However, with `v-bind` binding, if you omit the `()` then you are just
returning the method reference itself as a JavaScript expression, so if you have:

```html
<input :disabled="disabledMethod"/>
```
...and:
```html
<input :disabled="disabledMethod()"/>
```
...then the top example will not invoke `disabledMethod` and will return the 
value of the reference to `disabledMethod`, which is truthy if it exists. This
is probably not the behavior you want!

The bottom example will invoke `disabledMethod` and will use its result when 
assigning the disabled attribute.

If any of this is unclear, 
[try the playground](https://play.vuejs.org/#eNrFV1mPEz8M/ypmHhCIbfv/A09lWC7xABKHON5GQumMuxM2k4wSTw+hfneczJWW3aW7oOWhbezE9i++4v5IXtT1dNVgMk9SwqpWgvA00wBpIVdhwUsSC9VyW7JEUZymZPlTnuamqhvCYlYhlaZIZ8zz/NXE6IhYSD3u3bsPxoI29GxgMYGupWZeM6+8ldHowhTbgfQMG1GeLgYoLDxK9psxzZw7kwmkUvN5eB5+nmZJ+H3VKcmS2Sm4rSaxAbTW2Dk4RA8aHUwmB/reGwKhlFmzYGz4CCQtiHkhnXdzwTj6ZQzlWlqPMPv/FedDBG7R1ffu35qzIyxXefz2ELGl6wk8/LPADVV6ZF7uR+xdkL52Pl6Z5TfUeYTRR//eVW0i/W1n3UjrtTPt8bHuYyLqzkxF70VaD8e4SNDN+0M9PzVqVKRkZOOrk/oM7ip68ps+ffeMnoBF1yhyIDVkSSl0odBORV2rLUjn6xYELBudkzQ6S2BdooataYC2NbIQGeAXB7CQZOx0vFmE6CboQqR+xfdtVU33zt0A4y8IftfQIAAZbxAhEh2mQ7ELYYV2CIJYgS7QAskKgR0OkmChTH7uRhsBryZpEQqTNxWvYWlN1cnyBS739ReWbQcHwI3g2QTBlWatYS2pDJotIzQNKanZPT3SuGnDgv3CO0JVxhHECZ2jJSE1p4cXW5d8H+/qtdA0QMooo/3KY5PUWO1gKZTDE9giRTHxpvrzJ7DAXDQOw37bSwJIXLHP9pDwy4HFFPx9U6y6vsOWlsheyjGdMXMwLIBsQ+UWVkI1eLn3Xhp2kll664xhbez5nehMOgtlF97D44aQtuekC3vwLo6PIQ+QGxIWBUetMgUq1pKbRpNPvXaonLVTJbeIcdZMXW5lTbzCTW0sQYFLwYkJP7xIIUjMh+zjwTFwffJ6d/QUO9EbmsN/Jy1jF/J8F6h+Vpn3pw+vdpH+wUIIdFc1rT7giolKN5Lm0GqKVFAp3TQgm0yGwuv0chT31bbfbfDdgHXvLblI84MHB+AOn4ojbuS/dz4sQyhSR9uuhwcEQ2b02hbGcv1OcqP8aMSF2CoM2oKmTj45ScjlRi/l2fS7M5r/aAQNPjWqWnKT/lB737ksGe6cJWGWeht43k/dzVimxPz8Av53t/G8LPnITQ3tCrNk2OOUPEPOQb/9+vN7ztFok/O0UXz6is1P6Ixq2t7nj71swtsSnQto31Q+ebmhfXGvN4Ta9ZfyQMf4Zgn/2/Kpc9nVR7iPpuEFZnfukt1PXL8G+A==)
, which will hopefully correct anything I've misstated.