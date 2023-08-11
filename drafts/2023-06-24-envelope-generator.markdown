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

At this point, I've built an oscillator, which makes sound, but the issue is 
that it never _stops_ making sound. It just runs forever, and that makes it 
difficult to play music. Playing distinct notes is going to require two more 
modules: An Envelope Generator and a Voltage Controlled Amplifier. 

It doesn't really matter what order you build thes in, but I decided to build 
the EG next because there are two of them in the full kit, and I wanted to space 
them out as much as possible.

## What Even Is an Envelope Generator?

An envelope allows you to control the behavior of a sound over time. They're
frequently used to vary the volume, pitch, and filter cutoff of a sound, but
really they can vary any parameter of a synth. As noted above, without an 
envelope your oscillator will just run forever, which most people don't find
musically pleasing!

Here's an envelope from the Logic Pro Vintage Synth plugin:

<figure class="">
<a href="/images/synth/LogicProVintageSynthAmpEG.png">
<img src="/images/synth/LogicProVintageSynthAmpEG.png" loading="lazy" width="400px" alt="The AMP ENV from Logic Pro. We can see an attack, decay, sustain, and release setting on a visual graph. There is a volume slider to the right.">
</a>
<figcaption>Vintage Synth Amp Env</figcaption>
</figure>

This looks superficially similar to the VCA that we'll be building, but it 
differs in some important aspects:

* The Vintage Synth "envelope" is really more equivalent to a modular EG, VCA, 
  and Mixer all wired together. There is some complexity hidden here. 
* The Vintage Synth envelope shown here is for amplitude (note volume) control
  _only._ (Vintage Synth has a separate envelope which is hard-wired to filter
  cutoff or VCO pitch.) If you wanted to use an EG to modulate some other 
  control, such as the effect mix, well, you can't do that in Vintage Synth. 
* It's possible to have a slow attack followed by a slow decay. As we'll see, 
  the mki x es.EDU module can't do this, because it would have made the circuit
  substantially more complex.

I chose this comparison because Vintage Synth is a very simple plugin. Other 
plugins such as Alchemy allow you to add an arbitrary number of envelopes routed
to any parameter on the synth, having very complex shapes. That would be a huge
digression here.

One thing which is common to nearly every synth envelope but might not be 
obvious to people who have not used them is that the controls here are:

* Attack _time_
* Decay _time_
* Sustain **_level_**
* Release _time_

One of these things is not like the other! This will turn out to be surprisingly
important in the discussion below. 

When using an envelope to control the note volume, you can change the shape of 
a note to be like an organ, which goes to full volume when you press a key and
turns the note off when you release it:

<figure class="">
<a href="/images/synth/VintageSynthOrganEnv.png">
<img src="/images/synth/VintageSynthOrganEnv.png" loading="lazy" width="400px" alt="An organ has a very short attack, no decay, sustain at 100%, and a very short release.">
</a>
<figcaption>Vintage Synth Organ Envelope</figcaption>
</figure>

...or a piano, where the note spikes briefly to full volume and then fades, 
eventually to nothing, as you hold the key. If you release the key during the 
fade the volume will of course drop immediately to nothing:

<figure class="">
<a href="/images/synth/VintageSynthPianoEnv.png">
<img src="/images/synth/VintageSynthPianoEnv.png" loading="lazy" width="400px" alt="A piano has a very short attack, a slow decay, sustain at 0%, and an instant release.">
</a>
<figcaption>Vintage Synth Piano Envelope</figcaption>
</figure>

A real piano has a somewhat more complex decay, but the vintage synth envelope
can only do a linear decay. Other synths can do an exponential or arbitrary 
decay shape which will more accurately model a piano. 

It's pretty common to have envelopes which aren't really modeled after acoustic
instruments, for example with a "pad" sound. This might have a slow attack, a 
slow decay, sustain at 75%, and a slow release:

<figure class="">
<a href="/images/synth/VintageSynthPadEnv.png">
<img src="/images/synth/VintageSynthPadEnv.png" loading="lazy" width="400px" alt="A pad envelope">
</a>
<figcaption>Vintage Synth Pad Envelope</figcaption>
</figure>

As noted, this is one of two envelopes in the Vintage Synth plugin, which is 
quite simple and lacks a modulation matrix. Other synth
plugins have additional envelopes which can be arbitrarily routed to modulate
any parameter on the synth via a modulation matrix. 

With an Envelope Generator _module,_ you can accomplish these uses by connecting 
them to other modules:

| Envelope use | Modular equivalent |
| ------------ | ------------------ |
| Change volume of note as it's held | EG connected to Voltage Controlled Amplifier |
| Modulate filter cutoff as note is held | EG connected to Voltage Controlled Filter |
| Modulate pitch of note as note is held | EG connected to VCO pitch CV input |

On a standard synthesizer you might have a separate envelope for each of these,
a switch on the envelope, or a modulation matrix to choose between these 
functions. With a modular syntesizer, there is "just" an envelope generator, but
you need to connect it to some other module to get it to do anything useful. 

## Modular Envelope Generators

A keyboard suitable for controlling a modular synth will have a "Gate" output 
which goes high when a key is pressed and low when the key is released. (Again,
you don't get chords, at least not without a surprisingly large amount of work.)
So if you press a key for half a second and then release the key for half a 
second and repeat that cycle forever, the Gate output will look like a square 
wave.

### The Eurorack "Standard," Redux

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

### The mki x es.EDU Envelope Generator

Fundamentally, the way that the mki x es.EDU Envelope Generator module works is
that it applies a low-pass filter to the Gate. A low-pass filter will tend to 
round off the corners of a sharp change in a signal. This turns what looks like a 
square wave (presuming that you're pressing and releasing a key at a constant
rate) into a smoother shape. 

In the first iteration which you build on the breadboard it applies only _one_ 
lowpass filter to the gate, giving you a more rounded shape. Then, by using a 
pair of diodes, two separate lowpass filters are used in the circuit, one for 
the rise, and a separate filter for the fall (see example on the right).

That's simple enough, but it's a little _too_ simple, even for these circuits. 
The envelope needs a sustain, and that can't be accomplished with just a filter.
So instead of just filtering the Gate signal directly, instead it splits the 
Gate input into two separate signal paths: A pulse at the start of the Gate 
similar to the "Trigger" output that some keyboards have, and a pulse wave which
is similar to the Gate but which is set at a sustain level which youc an adjust 
with a potentiometer. These two paths are mixed together, forming a shape like 
the one at the right. Just like before, you can vary the attack speed with 
one pot and the descending phases (decay and release) with another pot. 

<figure class="horizontalTiles">
<a href="/images/synth/EGPulse.png">
<img src="/images/synth/EGPulse.png" loading="lazy" width="400px" alt="This shows the signal which will be used to generate the envelope. It has a thin bar going up to 100% on the left followed by a sustain level at about 50% for the rest of the pulse. Also shown is the square wave which is the input to the E.">
</a>
<figcaption>Pulse</figcaption>
</figure>

<figure class="horizontalTiles">
<a href="/images/synth/EGPulseMeasure.png">
<img src="/images/synth/EGPulseMeasure.png" loading="lazy" width="400px" alt="The same image as before, only it's overlaid with measurement cursors showing that the width of the attack pulse is 16 ms">
</a>
<figcaption>...with measurement</figcaption>
</figure>
<div style="clear: both;"></div>

In this example the input the the EG is shown in yellow and the wave which the
EG will round off using filters to become its output is shown in turquoise. The
high pulse on the left always goes to 100%, and the sustain for the rest of the
cycle is settable by the user. Here I've adjusted it to around 50%. The width
of the pulse on the left is not assignable by the user; it's always small; here
I have measured it at a about 16 ms.

So, if you use anything besides a very short attack then it will take 
longer than the pulse at the beginning of the envelope and will go to the 
sustain level instead of all the way to 100%.

## Breadboarding the Envelope Generator

### Passive vs. Active Circuits

<figure class="inlineRight">
<a href="/images/synth/EGPassive.png">
<img src="/images/synth/EGPassive.png" loading="lazy" width="400px" alt="There is a yellow square wave representing the Gate signal overlaid with a purple trace representing the envelope output. This purple trace raises slowly and asymptotically to the top of the yellow trace, and then when the yellow trace goes back to zero it slowly goes down, again following a roughly exponential curve.">
</a>
<figcaption>Passive trace</figcaption>
</figure>

If you look at the figure on the right, the yellow trace is the square wave I
am using as the input to the EG, and the purple trace is the output of the EG.
As you can see, the output of the passive circuit is limited to the voltage of
the input to the EG. Also, the output impedance would not be handled well; the 
shape of the waveform would change depending upon what you connected to the EG.

<figure class="inlineRight">
<a href="/images/synth/EGActive.png">
<img src="/images/synth/EGActive.png" loading="lazy" width="400px" alt="Active trace">
</a>
<figcaption>Active trace</figcaption>
</figure>

With the active EG, on the other hand, the output voltage is now independent of
the input voltage, and the impedance would be better handled, due to the use
of a buffer op amp. 

<div style="clear: both;"></div>
### Attack, Decay/Release, Sustain Controls

<figure class="inlineRight">
<a href="/images/synth/EGADSRPulse.png">
<img src="/images/synth/EGADSRPulse.png" loading="lazy" width="400px" alt="ADSR trace with pulse">
</a>
<figcaption>ADSR trace</figcaption>
</figure>

I'm going to explain how the attack and decay are implemented in the circuit. 
This is, ironically considering it was done to keep the circuit itself simple, 
somewhat complicated to understand, so feel free to skip ahead to the next 
section if you're so inclined. 

The way a "real" envelope generator works on a commercial
synth works is first the attack happens, taking the envelope to its maximum 
level. Then the decay, as it goes to the sustain level, and finally, when the 
key is released, the release happens. 

With the mki x es.EDU kit, on the other hand, the release only has a chance to 
happen when the attack is quite short. If you look at the trace on the right 
you can see that with a short attack, the decay can happen, followed by the 
sustain and release. This is the "best case scenario" for this circuit. The 
figure on the right, "ADSR trace," illustrates this "bess case scenario." With
roughly this shape, you can adjust the attack (a little!), the decay/release
times as a single value, and set a sustain level. 

<figure class="inlineRight">
<a href="/images/synth/EGSlowAttack.png">
<img src="/images/synth/EGSlowAttack.png" loading="lazy" width="400px" alt="ADSR trace with slow attack">
</a>
<figcaption>ADSR trace with slow attack</figcaption>
</figure>

When I dial in a longer attack, there is no decay; in this case the attack 
takes its time to even arrive at the sustain level, wherever that happens to 
be set. Importantly, the attack in this case only goes to the sustain level; it
does not go to 100% as a standard synthesizer attack would do.

(Note how the attack level is much higher in the "ADSR trace" example, and how
the attack only goes to the "sustain" level of the "ADSR trace" in the 
"ADSR trace with slow attack" example.)

This is because of how the EG works. The attack and the decay start _at the same
time._ If you look at the figure to the right called "ADSR trace with slow 
attack," you can see a third, blue trace. The blue
trace is a pulse which is fired when the input goes high. As you can see, the 
pulse is pretty short. One way to think about the duration of the pulse is that
it's the maximum length of time your attack can be for there to still have a
separate decay. You can have a longer attack, yes, but if you do then:

1. You won't get any decay, and
2. Your attack will only go to the sustain level, not to 100%.

One way to think about the mki x es.EDU EG is that it's _a low-pass filter_ on
the gate signal. The input is a square wave and hence has lots of harmonics.
To turn the hard corner of the input into a gentle attack, the EG uses a filter.


<div style="clear: both;"></div>
## Inversion

<figure class="inlineRight">
<a href="/images/synth/EGInverted.png">
<img src="/images/synth/EGInverted.png" loading="lazy" width="400px" alt="Inverted trace">
</a>
<figcaption>Inverted trace</figcaption>
</figure>

This time the blue trace on the right is showing the inverted output. No surprise
there; it uses 
[an op amp in an inverting configuration](/posts/2023-04-03-building-a-synthesizer-4.html#inverter) 
to produce this output.

<div style="clear: both;"></div>
## Looping the Envelope

I found this section somewhat hard to understand, not least because the 
directions lead off with a confusing bit of language:

<figure>
<a href="/images/synth/EGManualError.png">
<img src="/images/synth/EGManualError.png" loading="lazy" width="800px" alt="Screenshot of the Looping the Envelope section of the manual, with a looping circuit diagram and the text &quot;You just patch it in between output (on the right) and input (on the left) &quot;">
</a>
<figcaption>It's your other left...</figcaption>
</figure>

I was pretty sure this was a mistake; the input is on the right and the output
is on the left. 
[Looking at the circuit simulator seemed to confirme this](https://tinyurl.com/y7wh2o6u).
It was only when I watched 
[Moritz's YouTube video](https://www.youtube.com/watch?v=L9vTz0vm6pc) that I 
realized he was talking about the _envelope generator_ inputs and outputs, not
the I/O for the Schmitt trigger he's describing here. Of course the output of
the Schmitt trigger goes to the input of the envelope generator, and vice/versa!


In the end the way that this produces a loop is pretty simple, and here's how
I would explain it:

First, this circuit produces a _specific type of loop._ Namely, it loops 
whenever the envelope output goes to zero. This is not an LFO-style of loop 
which will always happen on a certain timeframe.  Given that requirement, then we just
need a circuit which will make the input go high whenever the output goes low.
That sounds like a Schmitt trigger inverter, something which you'll be familiar 
with if you've previously build the mki x es.EDU VCO, and the circuit shown is 
just building a Schmitt trigger inverter using an op amp and a few passive
components. 

However, my confusion only got worse as I looked deeper into this step. I had
found the breadboard diagrams increasingly difficult to line up with the schematics as
the breadboard got more densely packed, and I ended up annotating the diagram
in this step. It differs from the schematic in the step in a couple of important
ways, and all of the jumpers and the unlabeled pots, op amps, and jacks had 
finally pushed past the point where I could keep track of this in my head.

<figure>
<a href="/images/synth/EGHuh.png">
<img src="/images/synth/EGHuh.png" loading="lazy" width="800px" alt="A schematic diagram of the full EG circuit with a breadboard diagram of the mostly-equivalent circuit below it, with a few differences circled and some annotations added to identify specific parts.">
</a>
<figcaption>Schematic and Breadboard</figcaption>
</figure>

These are _mostly_ the same as the diagrams from the manual, only I have added
all of the colored annotations. Note, especially, the red circles. The 
breadboard version of the circuit does not include the switch (the components 
for the Gate input section are on the board, but they're "permanently switched 
off" in this version), and in the breadboard version the resistor goes to the 
negative rail instead of ground. That last bit just seems like an error to me
&ndash; the full schematic and the PC board layout later in the directions match
the schematic here. So I ended up not doing this part. 

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
* [How to loop any envelope](https://www.youtube.com/watch?v=L9vTz0vm6pc) 
  by Moritz Klein (2:48)
* [Erica Synths .EDU Envelope - Building and Demo](https://youtu.be/BKg2gU8tf08)
  by Synth DIY Guy (18:05)


