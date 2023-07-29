---
title: "Building a Synthesizer, Chapter ???: Building the Envelope Generator"
series: Building a Synthesizer
chapter: "???"
chapterName: Building the Envelope Generator
tags: synthesis, diy, electrical engineering
---

<div class="toc">
* [Introduction: The World of DIY Synthesizers](2023-01-22-building-a-synthesizer-0.html)
* [1: The mki x es.EDU DIY System](2023-01-29-building-a-synthesizer-1.html)
* [2: Building the Power Supply](2023-01-29-building-a-synthesizer-2.html)
* [3: Breadboarding the VCO](2023-01-29-building-a-synthesizer-3.html)
* [4: The Logic Circuits Model of Computation](2023-02-18-building-a-synthesizer-4.html)
* [5: Building the VCO](2023-02-20-building-a-synthesizer-5.html)
* [6: Debugging Circuits](2023-02-26-building-a-synthesizer-6.html)
* 7: Building the Mixer
* ???: Building the Envelope Generator
* [Glossary and Electrical Connections](2023-01-23-building-a-synthesizer-glossary.html)
</div>

As I've noted earlier, there seems to be no proscribed order in which to build 
the kits in the mki x es.EDU series. Probably the most useful modules to build 
after the VCO would be the <abbr title="Voltage Controlled 
Amplifier">VCA</abbr> or the <abbr title="Voltage Controlled Filter">VCF</abbr>,
but they would generally be controlled by the Envelope Generator, so whether to 
build the EG, the VCA, or the VCF first would be a "chicken or the egg" 
question. In the end I decided to build the EG next because there are two of 
them in the full kit, and I wanted to space them out as much as possible.

## The Eurorack "Standard," Redux

Reviewing 
[some of the online comments](https://www.modwiggler.com/forum/viewtopic.php?t=259994), 
it seems that a few people had trouble with this module. Based on some of
the comments there, it seems that once again people are getting bitten by the 
fact that the "Eurorack standard" is anything but! To be more precise, different
keyboards and sequencers put out differing voltages on their Gate/Trigger output.

To quote from the Doepfer [A-100 Technical Details](https://doepfer.de/a100_man/a100t_e.htm) 
document:

> The gate level +5V shown in the picture is only an example. Within the A-100 
> usually any voltage beyond about +3V is treated as "high" (e.g. +5V, +8V, 
> +10V, +12V will work) and will trigger an ADSR or any other module with a Gate 
> or Clock input (e.g. trigger delay, sequencer, clock divider, clock 
> sequencer). Any voltage below 1V is treated as "low". If the specification of 
> a module differs from this voltage standard it is mentioned in the description 
> of the module in question.

The circuit in the mki x es.EDU Envelope Generator is designed to trigger at 
3.8V. Quoting from the manual:

> I’ve set up a voltage divider to get our reference voltage. A 100k/47k 
> combination gives us approximately 3.8 V to work with. So whenever our input 
> voltage is higher than that, the comparator’s output will jump to +12 V. And 
> if it’s lower, it drops down to –12 V. Why did I choose that exact threshold? 
> To be honest, mostly just because I had packs of 100k and 47k resistors lying 
> on my table when I was testing this. But I still feel that 3.8 V is a
> decent value here.

Given the fuzziness of the specification, "because I had these packs of 
resistors conveniently at hand" is as good of a reason as any, and meets the 
Doepfer requirements.

I measured the output of my Novation SL MkIII's Gate output, and it's 5 V. People
on the thread I linked claim that the B\*hr\*ng\*r Neutron is only 3.3 V. Which 
"kind of almost" conforms to the Doepfer text ("usually/about"!), but is 
apparently low enough to cause some heartache with this kit. 

The instructions for the kit say:

> To properly test this circuit, you’ll need a square wave LFO and a module 
> with a CV input like a VCF.

In light of the above, you would want to consider your inputs carefully! 
You could use the VCO module, but probably not for the output _and_ 
input of the EG. My pocket scope has a function generator built in, but it can
only output a maximum of 2.5v peak to peak. 

My recommendation is to measure the output of the actual device you'll be using 
to control the module when you're finished with it. I don't typically use my 
keyboard when building the modules, as it's big and I don't want to carry it 
around the house, but I did take care to note its output. You don't want to 
use one device when building a module and then be surprised by the power 
requirements of some other device when playing with the module.

Also, you might want to consider changing the resistor going into the comparitor
if you require supporting gear with a lower output. R9 in the schematic is a 
47k resistor. If you substitute a 33k restistor instead, then I calculate that
you'll change the trigger threshold to 3 V, which is maybe a better default?

## Resources

### Instructions

* [mki x es.EDU Envelope Generator User Manual](https://www.ericasynths.lv/media/EG_MANUAL_v3.pdf)

### Community

* [Modwiggler thread](https://www.modwiggler.com/forum/viewtopic.php?t=259994)
* [Modulargrid page](https://www.modulargrid.net/e/erica-synths-edu-envelope)

### Simulations

* [Simplest Envelope](https://tinyurl.com/y7ea7j3a)
* [Passive A/R Envelope](https://tinyurl.com/y7xguhoo)
* [Active A/R Envelope](https://tinyurl.com/ycz4qc3b)
* [Pseudo ASDR Envelope](https://tinyurl.com/yc2c8u5h)
* [Status LED](https://tinyurl.com/y7gr9hnj)
* [Inverting Buffers](https://tinyurl.com/y9rrt8pp)
* [Looped Envelope](https://tinyurl.com/y7wh2o6u)


### Videos

* [Introducing the mki x es.EDU DIY EG kit](https://www.youtube.com/watch?v=Oo3Tu0WPqzE) 
  by Moritz Klein (5:03)
* [Designing a simple ADSR(-ish) envelope generator from scratch](https://www.youtube.com/watch?v=aGFb7JbTdNU)
  by Moritz Klein (30:59)
* [Erica Synths .EDU Envelope - Building and Demo](https://youtu.be/BKg2gU8tf08)
  by Synth DIY Guy (18:05)


