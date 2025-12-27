---
title: "Building a Synthesizer, Chapter 13: Building the VCF"
series: Building a Synthesizer
chapter: "13"
chapterName: Building the VCF
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
* [12: Breadboarding the VCF](2025-09-09-building-a-synthesizer-12.html)
* 13: Building the VCF
* [Glossary and Electrical Connections](2023-02-23-building-a-synthesizer-glossary.html)
</div>

This is the second chapter discussing the VCF build; if you haven't already read
the first, you might want to [start there](2025-09-09-building-a-synthesizer-12.html).
As a reminder, "VCF" stands for "Voltage Controlled Filter." A VCF can be any 
kind of filter; the mki x es.EDU VCF is just a lowpass filter. The "Voltage 
Controlled" for this kit means that we can control the filter's cutoff using a 
control voltage signal, such as one produced by the 
[envelope generator](2024-01-31-building-a-synthesizer-8.html). Using an envelope
generator allows us to vary the filter's cutoff over the course of a note, which
makes it sound more interesting. Of course there are many, many more ways to use
a VCF!

## Assembling the PC Board

This turned out to be a fairly easy build. Everything worked correctly after 
initial assembly. I made one mistake, which was accidentally melting two of the 
capacitor housings a bit with my soldering iron (I work under a magnifiying lens,
and this was out of sight!):

<figure>
<a href="/images/synth/VCFPCBoard.jpeg">
<img src="/images/synth/VCFPCBoard.jpeg" loading="lazy" height="300px" alt="The completed PC board. In the middle of the board there are three red capacitors next to each other, and the corner of these are melted a little">
</a>
<figcaption>PC Board with Slightly Melted Capacitors</figcaption>
</figure>

One tip I found handy: Before installing the trimpot resistor, set it to the 
middle of its range using your ohmmeter, because it's hard to tell where it's 
set once it's in the circuit. From there you can easily adjust it up or down as
needed. I found it needed not adjustment at all, however!

A couple of other views:

<figure class="horizontalTiles">
<a href="/images/synth/VCFFinishedFront.jpeg">
<img src="/images/synth/VCFFinishedFront.jpeg" loading="lazy" height="300px" alt="A front view of the finished VCF, showing many knobs and jacks">
</a>
</figure>

<figure class="horizontalTiles">
<a href="/images/synth/VCFFinishedSide.jpeg">
<img src="/images/synth/VCFFinishedSide.jpeg" loading="lazy" height="150px" alt="A side view of the finished VCF, showing potentiometers, capacitors, ICs, and resistors">
</a>
</figure>

<div style="clear:both  ;"></div>

## Matching Diodes?

While I was building this PC board, I noticed something a bit strange at the
top. There were two spaces for diodes, for which no extra diodes were supplied in the
kit. 

<figure>
<a href="/images/synth/VCFDiodes.jpeg">
<img src="/images/synth/VCFDiodes.jpeg" loading="lazy" height="300px" alt="A photo of the PC board. There are two unpopulated spaces for diodes.">
</a>
<figcaption>Missing Diodes?</figcaption>
</figure>

This was not mentioned in the directions, but I found reference to them on the
schematic:

<figure>
<a href="/images/synth/VCFDiodesSchematic.png">
<img src="/images/synth/VCFDiodesSchematic.png" loading="lazy" height="300px" alt="A detail of the schematic, showing the diode testing circuit">
</a>
<figcaption>Mystery... Solved?</figcaption>
</figure>

There are two links on the schematic, and they go to 
[an article on diode matching](https://makingcircuits.com/blog/diode-matching-circuit-pairing-circuit/)
and another on 
[how to measure diodes with your multimeter](https://www.fluke.com/en/learn/blog/digital-multimeters/how-to-test-diodes).
The latter is clearly aimed at people who have never used diode mode on their
meter before. (No shade intended here! We all need to learn!) The former is sort 
of interesting, but I can't understand why this little circuit is on the board 
at all, because, 
[as Moritz notes](https://modwiggler.com/forum/viewtopic.php?p=3862109&sid=3fec989e512c1ea72847f75c828e1e43#p3862109):

* Careful matching of diodes is not needed for this circuit
* If you were going to build the circuit from the first link to carefully match
  diodes, it would make a lot more sense to do it on a breadboard than to 
  solder the diodes onto a PC board temporarily!

So, I didn't bother to match my diodes. I guess it might make sense to do that 
if I was trying to build the cleanest filter imaginable, but in this case I 
prefer a kind of crunchy sound!

## Finished!

Here we have a square wave input and three possible settings of the filter: No
filtering at all, a low pass filter without resonance, and no filtering but a 
"medium" amount of resonance:

<figure class="horizontalTiles">
<a href="/images/synth/VCFFinishedNoFilter.jpg">
<img src="/images/synth/VCFFinishedNoFilter.jpg" loading="lazy" height="200px" alt="A square wave displayed on the oscilloscope">
</a>
<figcaption>#NoFilter</figcaption>
</figure>

<figure class="horizontalTiles">
<a href="/images/synth/VCFFinishedLowPass.jpg">
<img src="/images/synth/VCFFinishedLowPass.jpg" loading="lazy" height="200px" alt="The square wave with a low pass filter applied, which rounds off the sharp edges of the wave">
</a>
<figcaption>Low Pass</figcaption>
</figure>

<figure class="horizontalTiles">
<a href="/images/synth/VCFFinishedResonance.jpg">
<img src="/images/synth/VCFFinishedResonance.jpg" loading="lazy" height="200px" alt="The square wave with a low pass filter and resonance filter applied, which shows an up and down line at the start of each wave">
</a>
<figcaption>Resonance</figcaption>
</figure>

<div style="clear:both  ;"></div>

If you turn up the resonance still further you hear a high-pitched feedback.

Next, I connected the output of the Envelope Generator to the CV1 input of this
kit, which caused the cutoff to cycle back and forth between "no low-pass
filtering, but some resonance," and
and "a low-pass filter with resonance" (this is a video, press play to see it):

<video height="300" controls>
  <source src="/images/synth/VCFCV.mp4" type="video/mp4">
</video>

At this point you may be wondering how it sounds. Pretty nice! I want to put 
some demos together, but I will save that for a future post. Hopefully soon!

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

This simulation by Moritz Klein is the closest to the entire kit as built on the
PC board

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
