---
title: "Building a Synthesizer, Chapter 11: Debugging Circuits and Software Debugging"
series: Building a Synthesizer
chapter: "11"
chapterName: Debugging Circuits and Software Debugging
tags: diy, electrical engineering, computer science, debugging
---

<div class="toc">
* [Introduction: The World of DIY Synthesizers](2023-02-20-building-a-synthesizer-0.html)
* [1: The mki x es.EDU DIY System](2023-02-21-building-a-synthesizer-1.html)
* [2: Building the Power Supply](2023-02-22-building-a-synthesizer-2.html)
* [3: Breadboarding the VCO](2023-03-02-building-a-synthesizer-3.html)
* [4: A Gentle Introduction to Op Amps](2023-04-03-building-a-synthesizer-4.html)
* [5: Building the VCO](2023-05-22-building-a-synthesizer-5.html)
* [6: The Logic Circuits Model of Computation](2023-08-11-building-a-synthesizer-6.html)
* [7: Building the Mixer](2023-09-21-building-a-synthesizer-7.html)
* [8: Building the Envelope Generator](2024-01-31-building-a-synthesizer-8.html)
* [9: A Field Guide to Oscillators](2024-02-21-building-a-synthesizer-9.html)
* [10: Building the VCA](2024-06-24-building-a-synthesizer-10.html)
* 11: Debugging Circuits and Software Debugging
* [12: Breadboarding the VCF](2025-09-09-building-a-synthesizer-12.html)
* [13: Building the VCF](2025-12-27-building-a-synthesizer-13.html)
* [14: Building the Sequencer](2026-02-05-building-a-synthesizer-14.html)
* [Glossary and Electrical Connections](2023-02-23-building-a-synthesizer-glossary.html)
</div>

Sometimes you build a circuit and it doesn't work correctly the first time. This
is especially common if it's a new design, but even when building an existing, 
known-good design it might be that your specific construction doesn't function
correctly. No worries; it happens to the best of us! But you're now staring at a
hunk of silicon which doesn't do anything useful. How can you even begin to find 
and fix the problem?

In the software world we call such an endeavor "debugging." In the world of 
electronic hardware, doing this falls under the umbrella of "analysis," although
that also means understanding a working circuit, to a greater degree than 
"debugging" means understanding working code. The electronics community has 
informally adopted the term "debugging" for "what to do when the board you're staring at
doesn't work," but I find it interesting that I own several books[^books] on 
electrical engineering and _none of them_ have so much as a chapter on debugging
circuits! It seems like such a strange omission; I guess they presume that we
are learning this stuff in college and can just call a TA over if we get stuck?

It's not that there is no interest in the topic; there are 
[whole books](https://amzn.to/4aORbSJ) 
[on the](https://amzn.to/42NwRze) 
[subject](https://amzn.to/3Ep1qRt). But this sort of material just doesn't seem
to be included in "introductory" texts! 

## Step By Step

I follow a similar process when debugging code or hardware:

1. Look for obvious problems
2. Have a model of the thing I'm looking at
3. Compare the observed behavior with the model
4. When I find a deviation of the observed behavior from the model, try making a 
   change
5. Observe if the change brings the behavior of the system closer to the model
   and keep it or revert it as needed
6. If the circuit still does not work, go back to the step 2 and iterate until 
   I have a working system

One difference between debugging software and hardware is that when I debug 
software I am often writing new tests which run automatically. It's not that 
tests are impossible with hardware, and indeed I can see them being quite useful 
on complex circuits, particularly if there's a microprocessor available to run 
them. 
[Testing harnesses are common](https://oxide-and-friends.transistor.fm/episodes/raiding-the-minibar) 
when doing mass production of circuits. But 
the circuits I work on are quite simple, nearly always "one off" (not mass 
production) and there is no microprocessor available to run a test suite, so I 
must unfortunately do without any tests other than manual analysis of the 
circuit.

## Look for Obvious Problems

Without power, a circuit cannot work. It's worth testing that the power rail
is connected and at the right voltage, and similarly for the ground. Also, make
sure that all parts of the circuit have the same "ground"; one problem I've 
encountered myself is when an input to a circuit (such as an arbitrary waveform 
generator) and the circuit itself have two different "grounds." (The fix, in that 
case, was to simply connect the two grounds together with a wire.)

If you turn on a circuit and a component incinerates itself in a puff of smoke,
that may give you a fairly good idea of where the problem lies! Similarly, if 
a component is getting hot or smelly, well, unplug the power and take a look in
that neighborhood. 

If you're working on an old circuit it's probably worth giving all capacitors a
visual inspection before you start any deeper analysis. Old capacitors are 
[prone to failure](https://antiqueradio.org/recap.htm) and can be tested in 
circuit with an [ESR meter](https://en.wikipedia.org/wiki/ESR_meter) or out of
circuit with a multimeter.  

If this is a new circuit board that you've just built, a quick visual inspection
for cold solder joints can save hours of debugging.

## Have a Model

Actually, have two: A logical model and a physical model. To be honest, I 
usually have more than one logical model, but rather a tree structure of them.
"An analog synthesizer is composed of several 
[VCOs](2023-03-02-building-a-synthesizer-3.html), 
[VCAs](2024-06-24-building-a-synthesizer-10.html), VCFs... A VCO is 
composed of an oscillator core, wave shaping circuits... Etc." The physical 
model says things like, "I expect the voltage drop across this resistor to be..."

Another way to look at this is that the logical model is the "top down" point 
of view, and the physical model is the "bottom up" point of view. Both viewpoints
are needed to solve the problem. 

This is similar to how I work in code. I have a logical and a physical model of
how the software should operate. The logical model is a high level interaction
between components or systems, and focuses more on the specific business problem
that the softare is solving. The physical model is at the functions and bytes
level. Some people argue that this is foolishness and I should just change the 
code without thinking too much about it until my tests pass. I disagree with 
that methodology!

Having a schematic is incredibly helpful with both types of models. A schematic
will often put the design into blocks, which helps you understand the logical 
model, as well as listing specific components and voltages, which helps you 
understand the physical model. Keeping a physical circuit mentally lined up with
a schematic can be quite tricky! To give one example, a physical circuit might 
have an IC containing 4 different op amps, whereas the schematic will put those
4 op amps in 4 different places in the diagram. 

### Model Building

It can be difficult to keep a model in your head, so sometimes it's helpful to 
build a model. You can do this for example with a breadboard. Breadboards are 
(electrically) noisy, but they allow you to make changes to a circuit nearly as
fast as you can change code. 

Another tool which I find super-helpful in building a model of how a 
circuit should work is a simulator. For the work I do, 
[Falstad](https://www.falstad.com/circuit/) is honestly all I've ever needed, 
although it's quite limited, supporting only a handful of components. There are
many more advanced tools, some of which are free, but Falstad has worked for me.

### Noise

One significant difference between debugging hardware and software is that with 
hardware, noise must always be considered. Error correction in digital 
computers is so good that although noise can and does disrupt circuits in a 
computer, as software developers we rarely have to actually consider this. 

But when working with hardware, noise is more than an occasional annoyance; it's 
the sea in which we swim. Noise is always present and often significant. 

Sources of noise include:

* Poor connections on a breadboard
* Signals reflected in an incorrectly-terminated cable
* Less than "ideal" components
* Radio frequency interference from nearby devices

Sometimes people try to solve problems without having a model. They will say
things like "look for cold solder joints," or "look at the power supply, and 
look for shorts to ground," or "look for shorted capacitors." 
That's fine if it works -- indeed, such advice probably comes from hard-won 
experience -- but there will be many problems which you can't solve so easily!

### Datasheets

Electronics datasheets are a helpful tool for building your physical model of a 
circuit. These are particularly important with ICs, because it is an 
unfortunate fact that knowing the pinouts, signal voltages, etc., for one model
of IC tells you absolutely nothing about another, and getting, say, the power 
pins of an IC incorrect can cook the IC when power is applied. If designing a 
circuit from scratch, instead of building someone else's design, I review the 
datasheets for each active component I use 100% of the time, and I usually end
up reading them when building designs that other people have created, as well.

## Compare the Observed Behavior

When we talk about comparing actual behavior with observed behavior, we are 
probably talking about doing this comparison _at a specific part_ of the circuit,
and it's worth talking about how we will choose where to begin tracing. 

It may be that the nature of the failure gives us some clue as to where to start
looking. If the circuit seems completely dead, perhaps the failure is towards 
the beginning of the signal path? 

But it might also be the case that there is no obvious place to begin looking.
In this case a good technique is to do a binary search. Start in the middle, 
compare the signal with your model. If it seems correct, go halfway further 
along the circuit. If it seems incorrect, back up halfway towards the beginning.
Repeat as necessary.

How do you know what the signal at some point in the circuit "should" be? It may
be that your mental model of the circuit is so good that you will just know.
But if that's not the case, there are some other techniques you can use:

* Many circuits have "test points" on the PC board and documentation on what the 
  voltage/frequency should be at those labeled test points.
* You can use a simulator to approximate what the reading should be.
* You can "lower your standards" and just trace "am I getting any signal at all" 
  without thinking too hard about what it should be, specifically.

Whenever your mental model differs from the physical circuit you're building, 
that's a great place to look for issues. For example, your physical mental model
might include a pair of op amps in different points in a circuit, but your 
breadboard might just have a single IC. The confusion this causes can be a source
of error -- you might connect a wire to the wrong pin, or forget to connect the 
power leads to the IC, which were omitted from your mental model.

### Tools

In order to compare the actual behavior of the circuit with the model which is
in your head or on paper, you need a way to see what is going on inside the 
circuit. A "hardware debugger." It turns out that there are many different kinds
of hardware debuggers. 

Why not just have one tool which does it all? 
[There are attempts at it!](https://digilent.com/shop/analog-discovery-3/). 
But these tend to be featureless boxes which connect to a computer, and I find
them quite awkward to use. Having "one knob per function" is really helpful to 
me when I'm working on a real circuit. 

#### Multimeter

So, at a bare minimum, I think you need a multimeter and an oscilloscope. A 
multimeter measures voltage, current, and other things when they don't change
very much. That is to say, if I want to measure a voltage which I expect to be
constant, then I will reach for my multimeter. I say "very much," because of 
course nothing is black and white and many multimeters have maximum/minimum 
detection, inrush current measurement, etc. But as a general rule this is for
measuring things which are fairly steady. A multimeter is also great when you 
need to measure something such as resistance or capacitance, which are not 
generally directly measurable with an oscilloscope. Multimeters come in a few
different form factors, including the standard handheld "brick" style, a 
benchtop style, and a current clamp style. All of these do generally the same
things, but may have different accuracy or a few specific features.

#### Oscilloscope 

An oscilloscope, by contrast, is all about showing how a signal changes over 
time. The signal that you are measuring is _usually_ voltage, although you can 
buy current probes as well. Besides just displaying a trace of voltage over time
on the screen, even low-end oscilloscopes today will do frequency counting and 
Fourier transforms. Even to just list the features of a contemporary low-end
digital oscilloscope would be a post by itself. 

#### Audio Amplifier

I got a great idea from YouTuber 
[Mitch](https://www.youtube.com/@hackmodular), which is 
connect leads to an amplifier and a small speaker and use that in lieu of an 
oscilloscope when tracing an audio signal through a circuit. This allows me to 
hear the signal instead of see it, so that I can keep my eyes on the circuit.

#### Desoldering Tools

There is one other tool which I've found so handy while debugging physical 
circuits that I'm leaning towards throwing it in the "essentials" category: Some
kind of desoldering tool. It's _possible_ to do this with a standard soldering 
iron, but it's so much more of a pleasant experience with a vacuum desoldering 
iron or tool! You can buy a spring-loaded desoldering tool for about $10, so 
at a bare minimum you want something like this, even if you can't justify a 
more expensive electric vacuum desoldering iron.

One of the reasons that having a really good desoldering tool is so handy is 
that many parts cannot be tested in a circuit. To give one very simple example,
if you measure a resistor in circuit and you try to measure its resistance, you 
may not get a correct measurement as there may be other resistors in parallel 
to it. You must remove it from the circuit to get an accurate measurement. 

#### Other Tools

Beyond that, we get into "optional, but nice to have, depending on what you're 
doing" hardware. A power supply might seem like a must, although the circuit 
you're working on might already have one. A waveform generator is handy to
have around, and I've gotten a lot of mileage from mine while working on different
synthesizer modules, but I could have just used the VCO module that I built if 
I didn't have it. 

I have a [cheap component tester](https://amzn.to/4i3sIuI) which I can stick a 
transistor, capacitor or diode into and it will identify the device, the pinout,
and a few relevant characteristics. I don't use this very often. Going further
down this road, you might want an LCR or ESR meter if you are testing capacitors,
or a spectrum analyzer or vector network analyzer if you're dealing with radio/RF 
signals. But I have never needed them.

A logic analyzer is super-useful if you're working on digital circuits, and
probably unnecessary if you're not. 

### Testing Components "In Circuit"

Software developers will be familiar with the distinction between a unit test 
and an integration test; a similar distinction exists in hardware. 

* In a **unit test**, we test a single function to determine if it returns the
  expected result given some input. Similarly, we can test electrical components
  **in isolation** (not as part of a circuit) to ensure that they are behaving 
  correctly. This is useful because the component cannot be affected by the 
  rest of the circuit, but it can be difficult if it's necessary to un-solder a 
  component to do it.
* In an **integration test**, we test an entire program to ensure that it 
  behaves correctly given some input. Similarly, we can test an entire 
  electrical circuit. Note that the test might occur at any point in the 
  circuit, not only at the output. But the important distinction here is that 
  the components of the circuit are connected together, and hence have some 
  influence on eath other's behavior.

In both cases, there are significant limitations on what we can test when real
hardware is involved. For example, you generally _cannot_ measure the resistance
of a resisitor in circuit; the effect of the connected components might 
overwhelm the individual value of one resistor. By contrast, some components 
can't exactly be tested by themselves; a 555 timer, for example, requires 
external components to work. 

So similarly to unit tests and integration tests in code, doing tests on 
hardware "out of circuit" or "in circuit" gives us information about just one 
component or the component in the context of a whole circuit. But whereas we 
can generally test a function either with a unit test or an integration test, 
there are some components which can really only be tested in circuit or out 
of circuit, and it is up to the engineer to know the distinction, when it 
occurs.

## Make a Change

At some point you will identify a problem in the circuit and will have an idea
as to how to proceed. Perhaps you've found a bad solder joint, or perhaps a 
wire has popped out of your breadboard? Perhaps you've discovered you used a 
100 Ω resistor where you intended to use a 100 kΩ resistor. 

Software is so malleable that we don't really think much about how to change it;
we just type. But hardware can be more complicated. You might need to replace a 
part (or just remove it for testing out of circuit), or perhaps cut a trace on a
PC board -- or solder it back. Cutting a trace on a PC board is the equivalent 
of "commenting out" code. 

Go ahead and make that change.

## Analyze the "New" Circuit

Before powering up the circuit, it's worth thinking about the "new" circuit 
you've built. Perhaps you think that now it will work, that this one change 
you've made is all it will take to make everything work. And maybe that is so!
But it's worth considering that when a circuit fails it can do so destructively,
so you might want to consider that and carefully look at the circuit for other
mistakes before powering it up again.

When you do power it up again, you should then decide if the change that you 
made is _good._ Hopefully this is the case! But sometimes you will want to undo 
the change.

## Does It Work?

Hopefully the change that you made _improves_ the circuit, but that doesn't 
always mean a complete fix. If the circuit now works, great, you're done, you 
can stop and consider what you have learned from the experience. 

But if the circuit still is not fully functional, now it's time to go back to 
step 2, "Have a Model," and work through the process again.

## Grit

Just as with debugging hardware, a significant factor in finding the solution to 
a problem with hardware is grit: Your ability to stick to a problem and work 
with it until you find the solution. You need a certain degree of persistence, 
but not _too much._ Just as with software, you also need the ability to 
recognize when you're not getting anywhere and "call a friend." I wish I had 
better advice than just "don't go too far in the direction of 'not trying hard
enough' or 'trying too hard,'" but I will say that if you've been in software for 
a while then you will recognize this problem and hopefully be good at judging
for yourself!

[^books]: Specifically: _The Art of Electronics,_ by Horowitz and Hill, 
  _Make: Electronics,_ by Charles Platt, and 
  _Practical Electronics for Inventors,_ by Paul Scherz and Simon Monk, plus 
  some titles specialized to building synthesizers.