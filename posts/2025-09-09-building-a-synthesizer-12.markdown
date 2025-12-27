---
title: "Building a Synthesizer, Chapter 12: Breadboarding the VCF"
series: Building a Synthesizer
chapter: "12"
chapterName: Breadboarding the VCF
tags: synthesis, diy, electrical engineering
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
* [11: Debugging Circuits and Software Debugging](2025-04-07-building-a-synthesizer-11.html)
* 12: Breadboarding the VCF
* [13: Building the VCF](2025-12-27-building-a-synthesizer-13.html)
* [Glossary and Electrical Connections](2023-02-23-building-a-synthesizer-glossary.html)
</div>

Nearly all synthesizers have a filter of some kind. There are many different 
filter designs. Even a phrase like
["the Moog ladder filter" can mean many different actual circuits.](https://www.youtube.com/watch?v=IRxeIEeAAnU)
Differing filter designs can have as much to do with the character of how a synth
sounds as different oscillator shapes.

A VCF stands for a "Voltage Controlled Filter," which is similar to a regular 
equalizer filter except that it can be voltage controlled, which means that we 
can use an Envelope Generator or a Low Frequency Oscillator to vary the 
parameters of the filter (such as cutoff or resonance) as a note plays.

Moritz Klein's goal when designing the mki x es.EDU VCF was to make a "classic
sounding" filter with a very simple design. And when you think about how simple
a low-pass filter can be -- just a resistor and a capacitor, this feels like it
should be possible. 

## Breadboarding the Filter

One really minor difficulty I had when breadboarding these was figuring out which 
component was which, e.g., which jack was "input" and which was "output." Here's 
the schematic, which is clear enough:

<figure>
<a href="/images/synth/VCFFirstOrderSchematic.png">
<img src="/images/synth/VCFFirstOrderSchematic.png" loading="lazy" width="300px" alt="A schematic, from the manual, for the first order passive filter. There are no units on the resistor or capacitor.">
</a>
<figcaption>Schematic</figcaption>
</figure>

However, the breadboard layout is quite a bit less clear, and the jacks are for
whatever reason never labeled in the manual. Quick, which jack is input?

<figure>
<a name="breadboardLayout" href="/images/synth/VCFFirstOrderBreadboard.png">
<img src="/images/synth/VCFFirstOrderBreadboard.png" loading="lazy" width="300px" alt="A drawing, from the manual, of the breadboard layout of the first order passive filter">
</a>
<figcaption>Breadboard Layout</figcaption>
</figure>

(It's the one on the right.)

This becomes considerably harder when we start using seven op amps split
across two different ICs!

### Passive Filter

Anyway, here's the square wave I used as the input to the filter for my testing. You'll
soon see why I need to show this by itself first.

<figure>
<a href="/images/synth/VCFNoFilter.png">
<img src="/images/synth/VCFNoFilter.png" loading="lazy" width="300px" alt="A trace of a square wave on the oscilloscope">
</a>
<figcaption>#NoFilter, Just a Square Wave</figcaption>
</figure>

First we build a passive, first order filter using just a resistor and a 
capacitor. This does an OK job at filtering the output, but note that it also
distorts the input signal as well, because the resistor and capacitor add 
impedance to the input side of the circuit, since there is no isolation between
the filter and the input:

<figure>
<a href="/images/synth/VCFFirstOrder500.png">
<img src="/images/synth/VCFFirstOrder500.png" loading="lazy" width="300px" alt="The square wave, as a purple trace, and the output of a single order passive filter, as a yellow trace. This distorts the input as well as reshaping theo output.">
</a>
<figcaption>First Order Passive Filter 500 Hz Signal Input</figcaption>
</figure>

The purple trace above is the input square wave (distorted due to the passive circuit
here), and the output of the filter is the yellow trace. 

The filter doesn't just reshape the wave; it also reduces the output at higher
input frequencies. Above I'm using a 500 Hz input; here's with a 2 kHz input.

<figure>
<a href="/images/synth/VCFFirstOrder2k.png">
<img src="/images/synth/VCFFirstOrder2k.png" loading="lazy" width="300px" alt="The same filter at 2 kHz. The output of the filter is much lower in volume than at 500 Hz ">
</a>
<figcaption>First Order Passive Filter 2000 Hz Signal Input</figcaption>
</figure>

### Second Order Passive Filter

Then we add a second resistor and capacitor to make a second order filter. The 
output is much more like a sine wave with the second order filter. However, the 
input is even more distorted.

<figure>
<a href="/images/synth/VCFSecondOrder.png">
<img src="/images/synth/VCFSecondOrder.png" loading="lazy" width="300px" alt="A second order filter, which both turns the output into a smooth sine wave and also distorts the input into a more curved shape">
</a>
<figcaption>Second Order Passive Filter</figcaption>
</figure>

### Active Filter

Next we build the active filter. Here's the schematic:

<figure>
<a href="/images/synth/VCAActiveSchematic.png">
<img src="/images/synth/VCAActiveSchematic.png" loading="lazy" width="300px" alt="A schematic for the second order active filter which has no units on the capacitors and units on only one of the three resistors">
</a>
<figcaption>Active Filter Schematic</figcaption>
</figure>

When I first build this filter, it didn't work. I got no output at all. After 
some tracing, I finally noticed that we were supposed to replace the 1 µ 
capacitors from the passive filter with 1 n capacitors for the active filter. 
Unlike the real capacitors, which are visually very distinct, the "1 µ" and "1 n"
are just very similar looking [white blocks in the breadboard drawings](#breadboardLayout), 
and the schematic immediately above omits their values altogether! 

Anyway, with that sorted, I then had a respectable looking low-pass filter:

<figure>
<a href="/images/synth/VCFActiveTrace.png">
<img src="/images/synth/VCFActiveTrace.png" loading="lazy" width="300px" alt="An oscilloscope trace from the active filter. The input is a square wave reprepresented in purple. The output is the yellow trace and is filtered, a bit, by the low pass filter ">
</a>
<figcaption>Active Filter Input and Output</figcaption>
</figure>

### Adding Resonance

Next we make the filter resonant. We do this by feeding the output of the filter
back into the first capacitor, replacing its connection to ground with the 
filter's output. 

<figure>
<a href="/images/synth/VCFResonantTrace.png">
<img src="/images/synth/VCFResonantTrace.png" loading="lazy" width="300px" alt="Oscilloscope trace of resonant filter output. The yellow trace mostly hides the purple trace, except at the leading edge of the square wave where the output has a resonant overshoot ">
</a>
<figcaption>Resonant Filter</figcaption>
</figure>

In the instructions and in his videos, Moritz notes 
that this "is basically just the filter itself swinging at its set cutoff 
frequency in addition and reaction to the oscillation it’s supposed to be
filtering." That's correct, but it's only part of the story. In addition to the 
filter "overreact[ing] to any sudden change in voltage at its input," the filter
also introduces a delay in the signal as it passes through the filter and then
gets partially routed back into the input of the filter. The portion of the 
output which is fed back into the filter circuit is out of phase with the input.
Both the delay/phasing and the amplification are responsible for the 
characteristic sound of the resonance.

<figure>
<a href="/images/synth/VCFResonantNoResonance.png">
<img src="/images/synth/VCFResonantNoResonance.png" loading="lazy" width="300px" alt="Oscilloscope trace showing the output at a lower level than the input, and the corners of the trace rounded off due to the low pass filter ">
</a>
<figcaption>Adjustable Resonant Filter, Set to No Resonance</figcaption>
</figure>

<figure>
<a href="/images/synth/VCFResonantWithResonance.png">
<img src="/images/synth/VCFResonantWithResonance.png" loading="lazy" width="300px" alt="Oscilloscope trace showing the output with the resonance level set to a higher level, causing an overshoot at the leading edge of the square wave   ">
</a>
<figcaption>Adjustable Resonant Filter, with Resonance</figcaption>
</figure>

### Adding the Diode Ladder

We want to make the filter adjustable using control voltage. The first step is
to make it adjustable at all. This kit solves that problem using diodes as 
"voltage controlled resistors." I won't bother explaining the theory here as that
is very well covered in [the manual](https://www.ericasynths.lv/media/VCF_MANUAL_v2.pdf),
which I encourage you to read if this project is at all interesting to you. 
The manuals for the mki x es.EDU DIY kits are (really) great reading. 

<figure>
<a href="/images/synth/VCFDiodeLadder.jpg">
<img src="/images/synth/VCFDiodeLadder.jpg" loading="lazy" width="300px" alt="A photo of the breadboarded VCF circuit">
</a>
<figcaption>Filter with Diode Ladder At Upper Left</figcaption>
</figure>

### Adding the Output Stage

In the images which follow, the input square wave is in yellow, the top and 
bottom of the diode ladder are in purple and green, and the output is in cyan.

Some things to note here. First, the scaling is a bit deceptive. The input signal
is much hotter than the rest of the traces (note its vertical scaling is 2V/div).

The output signal varies quite a bit in amplitude depending on where the filter 
cutoff is set, which isn't ideal. We will fix that in the next section. 

There's a low-frequency noise, probably 60 Hz, in the output. I blame this on 
the noisy breadboard and low output level. 

<figure class="horizontalTiles">
<a href="/images/synth/VCFOutputStage1.jpg">
<img src="/images/synth/VCFOutputStage1.jpg" loading="lazy" height="200px" alt="An oscilloscope trace showing an output with a fairly square wave signal, like the input">
</a>
<figcaption>High Cutoff</figcaption>
</figure>

<figure class="horizontalTiles">
<a href="/images/synth/VCFOutputStage2.jpg">
<img src="/images/synth/VCFOutputStage2.jpg" loading="lazy" height="200px" alt="An oscilloscope trace showing an output with a somwhat rounded signal">
</a>
<figcaption>Middle Cutoff</figcaption>
</figure>

<figure class="horizontalTiles">
<a href="/images/synth/VCFOutputStage3.jpg">
<img src="/images/synth/VCFOutputStage3.jpg" loading="lazy" height="200px" alt="An oscilloscope trace showing an output with an output which looks fairly close to a sine wave">
</a>
<figcaption>Low Cutoff</figcaption>
</figure>

<div style="clear:both  ;"></div>

This build took me quite a while to debug. At first I found that a couple of 
wires were in the wrong breadboard sockets, and then after a considerable amount
of troubleshooting I found a couple of resistor leads which contacted each other due
to "leaning" on the breadboard. Which is, frankly, an easy mistake to make:

<figure>
<a href="/images/synth/VCFOutputStageBreadboard.jpg">
<img src="/images/synth/VCFOutputStageBreadboard.jpg" loading="lazy" width="600px" alt="A photo of the breadboarded VCF circuit with output stage">
</a>
<figcaption>VCF with Output Stage</figcaption>
</figure>

Still, this gave me ample opportunity to put 
[my ideas about debugging circuits](2025-04-07-building-a-synthesizer-11.html) 
into practice!

### Adding CV Processing and Output Scaling

One part of breadboarding the mki x es.EDU kits which has repeatedly caused 
confusion for me is, when going from one step to the next in the instructions,
figuring out which parts are not needed in the next step and should be removed
vs. which parts need to remain.

I think this example will show you what I mean. These two steps follow each 
other sequentially in the manual.

<figure class="horizontalTiles">
<a href="/images/synth/VCFBreadboardCV.png">
<img src="/images/synth/VCFBreadboardCV.png" loading="lazy" height="200px" alt="A hand-drawn picture of a breadboard with many components on it">
</a>
<figcaption>"CV Processing" Step</figcaption>
</figure>

<figure class="horizontalTiles">
<a href="/images/synth/VCFBreadboardResonance.png">
<img src="/images/synth/VCFBreadboardResonance.png" loading="lazy" height="200px" alt="Another hand-drawn picture of the same breadboard, with even more components on it, and a few removed">
</a>
<figcaption>"Resonance II" Step</figcaption>
</figure>

<div style="clear:both  ;"></div>

Quick, which components should I remove to go from the first to the second? 
Which components need to be added? No matter how carefully I work I still make 
mistakes. It's another opportunity to test my debugging skills. 

Anyway, after a lot of assembly and debugging, the output is much cleaner. Note
that the cyan trace here (the filter's output) has been switched to 500 mV/div, 
which is the same vertical resolution as the purple and green traces (which are
the top and bottom of the diode ladder), and 10* less magnification than the 
50 mv/div vertical resolution of the cyan trace (output, again) of the previous
section.

<figure class="horizontalTiles">
<a href="/images/synth/VCFCV2.jpg">
<img src="/images/synth/VCFCV2.jpg" loading="lazy" height="200px" alt="An oscilloscope trace showing an output with a fairly square wave signal, like the input">
</a>
<figcaption>High Cutoff</figcaption>
</figure>

<figure class="horizontalTiles">
<a href="/images/synth/VCFCV1.jpg">
<img src="/images/synth/VCFCV1.jpg" loading="lazy" height="200px" alt="An oscilloscope trace showing an output with with a somwhat rounded signal">
</a>
<figcaption>Low Cutoff</figcaption>
</figure>

<div style="clear:both  ;"></div>

I like this because you can really clearly see how the green and purple traces
get further away from each other as the filter's cutoff gets higher and higher.
This "drags the input voltage" (into either end of the diode ladder) into a 
different part of the diodes' nonlinear range, making it a variable resistor, 
which is what we wanted.

### Resonance II

The big problem that I had getting the resonance working is that I mistakenly
used the Schottky diodes supplied with the kit for the power supply in place of
the 1N4148 diodes that I was meant to use. The breadboard instructions just say
"diode," although they are not interchangeable! Anyway, with the correct diodes
in place I can now affect the resonance a bit, although at this point every time
I touched anything I would knock off the input, one of my four oscilliscope 
probes, a random electronic component, etc. I didn't want to spend a lot of 
effort adjusting the trimpot, which is fiddly enough without all of these other
cables to bump into. Still, I can see the effect of the resonance on the leading
edge of the square wave here, even if it is a bit subtle:

<figure class="horizontalTiles">
<a href="/images/synth/VCFResonanceHigh.jpg">
<img src="/images/synth/VCFResonanceHigh.jpg" loading="lazy" height="200px" alt="An oscilloscope trace which shows the output wave with the resonance knob set high, showing a small spike at the head of the wave">
</a>
<figcaption>High Resonance</figcaption>
</figure>

<figure class="horizontalTiles">
<a href="/images/synth/VCFResonanceLow.jpg">
<img src="/images/synth/VCFResonanceLow.jpg" loading="lazy" height="200px" alt="An oscilloscope trace which shows the output wave with the resonance knob set low, showing a smooth round edge at the heaed of the wave">
</a>
<figcaption>Low Resonance</figcaption>
</figure>

<div style="clear:both  ;"></div>

Anyway, now we are finished with the breadboarding!

<figure>
<a href="/images/synth/VCFBreadboardFinished.jpg">
<img src="/images/synth/VCFBreadboardFinished.jpg" loading="lazy" height="200px" alt="The completed breadboard">
</a>
<figcaption>All Finished!</figcaption>
</figure>

The breadboard is by now getting quite crowded. I think this kit might be
better built across two breadboards.

This post is getting fairly long, so I think I will save the PC board build for
next time!

## Resources

### Instructions

* [mki x es.EDU VCF User Manual](https://www.ericasynths.lv/media/VCF_MANUAL_v2.pdf)

### Product Pages
* [EDU DIY VCF](https://www.ericasynths.lv/shop/diy-kits-1/edu-diy-vcf/)
* [mki x es.EDU DIY System](https://www.ericasynths.lv/shop/diy-kits-1/mki-x-esedu-diy-system/)

### Community

* [Modwiggler thread](https://modwiggler.com/forum/viewtopic.php?p=3771212)
* [Modulargrid page](https://modulargrid.net/e/erica-synths-edu-vcf)

### Simulations

All of these simulations are by Moritz Klein

* [Static cutoff/Variable cutoff](https://tinyurl.com/y5a8tc9l)
* [Two stage LPF](https://tinyurl.com/y5x873gn)
* [Active two-stage LPF](https://tinyurl.com/y2fcoqsj)
* [Slightly resonant LPF](https://tinyurl.com/y4j2khjd)
* [Variable resonance](https://tinyurl.com/2bfrjd36)
* [Even number of stages/Odd number of stages](https://tinyurl.com/y5z9m64u)
* [Downwards shift/Upwards shift/Driving the ladder](https://tinyurl.com/2alfoolb)
* [The output stage](https://tinyurl.com/2yowgjq8)
* [Properly processed CV](https://tinyurl.com/2xp8ey77)
* [Resonance II](https://tinyurl.com/23mp8quc)

### Videos

* [Introducing the mki x es.edu DIY VCF kit](https://www.youtube.com/watch?v=wbG5lvBFCmA)
  by Moritz Klein (5:04)
* [Erica.EDU Diode Ladder Filter Kit!](https://www.youtube.com/watch?v=eMODpxvdtvs) by Quincas Moreira (16:05)

The folling series of videos are iterations on the design of what is ultimately 
a slightly different VCF built by Moritz Klein. I do think they are useful, 
though:

* [DIY SYNTH VCF Part 1: Analog Filtering Basics](https://www.youtube.com/watch?v=3tMGNI--ofU) (21:45)
* [DIY SYNTH VCF Part 2: Active Filters & Resonance](https://www.youtube.com/watch?v=YNoj9Rrw_VM) (27:30)
* [DIY SYNTH VCF Part 3: Resonant High-Pass & Vactrol-Based Voltage Control](https://www.youtube.com/watch?v=ITJX9jP-zm4) (29:20)
* [Designing a diode ladder filter from scratch](https://www.youtube.com/watch?v=jvNNgUl3al0) (36:03)
* [Turning my diode ladder filter into a eurorack module](https://www.youtube.com/watch?v=tWKLFcc_BJM) (34:46)
