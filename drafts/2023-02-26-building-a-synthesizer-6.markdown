---
title: "Building a Synthesizer, Chapter 6: Debugging Circuits"
series: Building a Synthesizer
chapter: "6"
chapterName: What Can Debugging Circuits Teach Us About Software Debugging?
tags: diy, electrical engineering, computer science, debugging
---

Sometimes you build a circuit and it doesn't work correctly the first time. This
is especially true if it's a new design, but even when building an existing, 
known-good design it might be that your specific construction doesn't function
correctly. No worries; it happens to the best of us! But how can you find and 
fix the problem?

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
[whole](https://amzn.to/3WVxwL7) [books](https://amzn.to/4aORbSJ) 
[on](https://amzn.to/3Ep1qRt) [the](https://amzn.to/42NwRze) 
[subject](https://amzn.to/3Ep1qRt). But this sort of material just doesn't seem
to be included in "introductory" texts! 

I follow a similar process when debugging code or hardware:

1. Look for obvious problems
2. Have a model of the thing I'm looking at
3. Compare the observed behavior with the model
4. When I find a deviation of the observed behavior from the model, try making a change
5. Observe if the change brings the behavior of the system closer to the model
   and keep it or revert it as needed
6. If the circuit still does not work, go back to the step 2 and iterate until 
   I have a working system

One difference between debugging softare and hardware is that when I debug 
software I am often writing new tests. It's not that tests are impossible with 
hardware, and indeed I can see them being quite useful on complex circuits, 
particularly if there's a microprocessor available to run them. But the circuits
I work on are quite simple, and there is no microprocessor available to run a 
test suite, so I must unfortunately do without. 

## Look for Obvious Problems

Without power, a circuit cannot work. It's worth testing that the power rail
is connected and at the right voltage, and similarly for the ground.

If you turn on a circuit and a component incinerates itself in a puff of smoke,
that may give you a fairly good idea of where the problem lies! Similarly, if 
a component is getting hot or smelly, well, unplug the power and take a look in
that neighborhood. 

If you're workign on an old circuit it's probably worth giving all capacitors a
visual inspection before you start any deeper analysis. 

If this is a new circuit board that you've just built, a quick visual inspection
for cold solder joints can save hours of debugging.

## Have a Model

Actually, have two: A logical model and a physical model. To be honest, I 
usually have more than one logical model, but rather a tree structure of them.
"An analog synthesizer is composed of several VCOs, VCAs, VCFs... A VCO is 
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

Another tool which I find super-helpful in building a mental model of how a 
circuit should work is a simulator. For the work I do, 
[Falstad](https://www.falstad.com/circuit/) is honestly all I've ever needed, 
although it's quite limited, supporting only a handful of components. There are
many more advanced tools, some of which are free, but Falstad has worked for me.

Sometimes people try to solve problems without having a model. They will say
things like "look for cold solder joints," or "look at the power supply, and 
look for shorts to ground," or "look for shorted capacitors." 
That's fine if it works -- indeed, such advice probably comes from hard-won 
experience -- but there will be many problems which you can't solve so
easily!

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

How do you know wha the signal at some point in the circuit "should" be? It may
be that your mental model of the circuit is so good that you will just know.
But if that's not the case, there are some other techniques you can use:

* Many circuits have "test points" and documentation on what the voltage/frequency
  should be at those labeled test points.
* You can use a simulator to approximate what the reading should be.
* You can "lower your standards" and just trace "am I getting any signal at all" 
  without thinking too hard about what it should be, specifically.

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
benchtop style, and a current clamp style. All of these do in general the same
things, but may have different accuracy or a few specific features.

An oscilloscope, by contrast, is all about showing how a signal changes over 
time. The signal that you are measuring is _usually_ voltage, although you can 
buy current probes as well. Besides just displaying a trace of voltage over time
on the screen, even low-end oscilloscopes today will do frequency counting and 
Fourier transforms. Even to just list the features of a contemporary low-end
digital oscilloscope would be a post by itself. 

I got a great idea from YouTuber 
[Mitch](https://www.youtube.com/channel/UCuWlekkRZkTF0iIpVbgkUPg), which is 
connect leads to an amplifier and a small speaker and use that in lieu of an 
oscilloscope when tracing an audio signal through a circuit. This allows me to 
hear the signal instead of see it, so that I can keep my eyes on the circuit.

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

Beyond that, we get into "optional, but nice to have, depending on what you're 
doing" hardware. A power supply might seem like a must, although the circuit 
you're working on probably already has one. A waveform generator is handy to 
have around, and I've gotten a lot of mileage from mine while working on different
synthesizer modules, but I could have just used the VCO module that I built if 
I didn't have it. 

I have a [cheap component tester](https://amzn.to/4aOxWZD) which I can stick a 
transistor, capacitor or diode into and it will identify the device, the pinout,
and a few relevant characteristics. I don't use this very often. Going further
down this road, you might want an LCR or ESR meter if you are testing capacitors,
or a spectrum analyzer or vector network analyzer if you're dealing with radio/RF 
signals. But I have never needed them.

## Make a Change

At some point you will identify a problem in the circuit and will have an idea
as to how to proceed. Perhaps you've found a bad solder joint, or perhaps a 
wire has popped out of your breadboard? Perhaps you've discovered you used a 
100 Ω resistor where you intended to use a 100 kΩ resistor. 

Software is so malleable that we don't really think much about how to change it;
we just type. But hardware can be more complicated. You might need to replace a 
part (or just remove it for testing out of circuit), or perhaps cut a trace on a
PC board -- or solder it back.

Go ahead and make that change.

## Analyze the "New" Circuit

Before powering up the circuit, it's worth thinking about the "new" circuit 
you've built. Perhaps you think that now it will work, that this one change 
you've made is all it will take to make everything work. And maybe that is so!
But it's worth considering that when a circuit fails it can do so destructively,
so you might want to consider that and carefully look at the circuit for other
mistakes before powering it up again.

When you do power it up again, you should then decide if the change that you 
made is _good._ Hopefully this is so! But sometimes you will want to undo the 
change.

## Does It Work?

Hopefully the change that you made _improves_ the circuit, but that doesn't 
always mean a complete fix. If the circuit now works, great, you're done, you 
can stop and consider what you have learned from the experience. 

But if the circuit still is not fully functional, now it's time to go back to 
step 2, "Have a Model," and work through the process again.

We haven't learned lessons about modularity yet -- small vs. trusted, composed
The triumph of error correction in digital computers
Break it down into smaller parts (when possible, impedance)
Check power + ground first. Binary search. Search by modules/functional blocks. Lastly, start at the beginning: Physically, following the path of a circuit, or temporally -- capture a trace on your scope.
Digital error correction is really great and analog computers don't have it, mostly
Build a model in the simulator, compare it to real hardware. Compare real hardware with both functional and physical models.
Software is so malleable that sometimes people forget to make a high-level mental model of how it should work and patch around bugs until a test passes. Avoid this. You can't avoid it with hardware, anyway.
Pretending current travels at infinite speed. 
Models of circuits: Pretending a transistor is a resistor and a curent source.
"Cut the traces" == commenting out code. 
Make sure you really have the parts you think you have -- I've mixed up resistors more times than I can count.
Triple check connections, especially to anonymous IC pins.
You're going to fail at soldering
Breadboards are sometimes not so great.

[^books]: Specifically: _The Art of Electronics,_ by Horowitz and Hill, 
  _Make: Electronics,_ by Charles Platt, and 
  _Practical Electronics for Inventors,_ by Paul Scherz and Simon Monk, plus 
  some titles specialized to building synthesizers.