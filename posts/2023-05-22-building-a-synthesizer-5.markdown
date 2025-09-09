---
title: "Building a Synthesizer, Chapter 5: Building the VCO"
series: Building a Synthesizer
chapter: "5"
chapterName: Building the VCO
tags: synthesis, diy, electrical engineering
---

<div class="toc">
* [Introduction: The World of DIY Synthesizers](2023-02-20-building-a-synthesizer-0.html)
* [1: The mki x es.EDU DIY System](2023-02-21-building-a-synthesizer-1.html)
* [2: Building the Power Supply](2023-02-22-building-a-synthesizer-2.html)
* [3: Breadboarding the VCO](2023-03-02-building-a-synthesizer-3.html)
* [4: A Gentle Introduction to Op Amps](2023-04-03-building-a-synthesizer-4.html)
* 5: Building the VCO
* [6: The Logic Circuits Model of Computation](2023-08-11-building-a-synthesizer-6.html)
* [7: Building the Mixer](2023-09-21-building-a-synthesizer-7.html)
* [8: Building the Envelope Generator](2024-01-31-building-a-synthesizer-8.html)
* [9: A Field Guide to Oscillators](2024-02-21-building-a-synthesizer-9.html)
* [10: Building the VCA](2024-06-24-building-a-synthesizer-10.html)
* [11: Debugging Circuits and Software Debugging](2025-04-07-building-a-synthesizer-11.html)
* [12: Breadboarding the VCF](2025-09-09-building-a-synthesizer-12.html)
* [Glossary and Electrical Connections](2023-02-23-building-a-synthesizer-glossary.html)
</div>


Actually building the <abbr title="Printed Circuit">PC</abbr> board incarnation 
of the VCO was quite a bit easier than 
[getting it to work on the breadboard](2023-03-02-building-a-synthesizer-3.html). 
Really there was nothing tricky 
about it; I just soldered it together and it worked well the first time. I don't 
really remember how long it took; I'm thinking 2-3 hours? It was
certainly much easier to solder than 
[the power supply](2023-02-22-building-a-synthesizer-2.html), where the
large ground traces made getting the solder joints hot enough difficult. 

This once again reinforces my feeling that I made the right decision getting the 
mki x es.EDU kits instead of some of the other synthesizer kits on the 
market. The emphasis on breadboarding allows me to make and fix mistakes, and
that's the best way to learn. When you connect components to labeled holes on a 
PC board, well, there's not a ton of opportunity to screw things up.

When I was in high school I occasionally built 
[Heathkit](https://www.heathkit.com) electronics kits. I still have my 
Heathkit DMM that I built decades ago. Their motto was, "We won't let you fail."
Now I am thinking it would have been better if they did let me fail, just a 
little!

<figure class="horizontalTiles">
<a href="/images/synth/VCOFrontPanel.jpg">
<img src="/images/synth/VCOFrontPanel.jpg" loading="lazy" height="300px" alt="The front of the VCO, which is a PC board with two ICS and a number of discrete resistors and capacitors">
</a>
<figcaption>VCO Front</figcaption>
</figure>

<figure class="horizontalTiles">
<a href="/images/synth/VCOPCBack.jpg">
<img src="/images/synth/VCOPCBack.jpg" loading="lazy" height="300px" alt="The back of the VCO, which is a PC board with two ICS and a number of discrete resistors and capacitors">
</a>
<figcaption>VCO Back</figcaption>
</figure>

<figure class="horizontalTiles">
<a href="/images/synth/HeathDMM.jpg">
<img src="/images/synth/HeathDMM.jpg" loading="lazy" height="300px" alt="A Heathkit IM-2320 DMM">
</a>
<figcaption>My Venerable Heathkit DMM</figcaption>
</figure>

<div style="clear:both  ;"></div>

## Differences Between the Breadboarded VCO and the PC Board Version

The PC board version has some extra components which are not used when you build
the VCO on the breadboard. These are mostly discussed in 
[the instructions](https://www.ericasynths.lv/media/VCO_MANUAL_v2.pdf) in the 
section entitled "Module Assembly Appendix," so I'll refer you there for an
explanation of what they do. 

The is a component which is added to the PC board version and which is not 
mentioned in the "Module Assembly Appendix." The PC board version adds 1k 
resistors in front of the two output jacks. Presumably this is to protect the 
circuit if the output is accidentally shorted to ground while plugging in a 
patch cable. Putting a 1k resistor here ensures that there is always some 
resistance on the output, even if the patch cable momentarily joins the output 
with ground while plugging it in/out

## Tuning

<figure class="inlineRight">
<a href="/images/synth/NovationPitchCVCalibration.png">
<img src="/images/synth/NovationPitchCVCalibration.png" loading="lazy" width="400px" alt="CV calibration instructions for the Novation SL MkIII keyboard">
</a>
<figcaption>Pitch CV Calibration Instructions</figcaption>
</figure>

Nothing takes the romance out of analog synthesizers faster than tuning. When 
you play a note, let's say middle C, on a keyboard, you would ideally like the 
VCO to oscillate at a corresponding value of 261.63 Hz. Many things have to be 
set correctly for this to happen! 

Let's start with the keyboard: It will emit a pitch control voltage when you 
play a key, but will it be the "correct" voltage for the modules you use? My 
keyboard has a "CV Calibration" feature which allows you to change the pitch 
CV emitted when you press a key. 

So my first task was to connect the keyboard's pitch CV output to a voltmeter 
and adjust this signal to the expected values. What are those? 
[this list](https://notebook.zoeblade.com/Pitches.html) seems fairly standard.
(The [list of voltages currently on Wikipedia](https://en.wikipedia.org/w/index.php?title=CV/gate&oldid=1093674895#CV) 
sets 0V = A instead of C. There has been disagreement on which note 0V should 
correspond to over the years, but for Eurorack you'll want it to be C.)
I *do not* 
recommend doing this by connecting to a sound device and tuning it by ear, as 
the instructions suggest, because the sound device itself might be out of tune. 
One thing at a time!

<figure class="inlineLeft">
<a href="/images/synth/VCOTuning.jpg">
<img src="/images/synth/VCOTuning.jpg" loading="lazy" width="400px" alt="The VCO during tuning. A digital tuner is shown on a computer screen in the background of the image, as well as the right side of an oscilliscope. The digital tuner shows that the VCO is about 9 cents sharp.">
</a>
<figcaption>Almost, but not quite!</figcaption>
</figure>

Unfortunately, I found a firmware bug while doing this! Adjusting the "CV 1 Low"
and "CV 1 High" dials didn't change the pitch or produce any visual indication 
that they were doing anything. I eventually figured out that although they were
adjusting the pitch I couldn't hear the change until I pressed another button
to change to the other control. I guess I will report that to Novation. At any
rate, I was eventually able to get the output voltage correct.

That sorted, I could then connect the keyboard's pitch CV to the VCO's "1V/oct"
input and tune the VCO. There's 
[a video of Moritz Klein tuning the breadboarded version of an early version of this project](https://www.youtube.com/watch?v=dd1dws6pSNo&t=1253s) which you can watch to see the project. I do think he 
makes this process seem a bit easier than it actually is, though!

When you're first tuning the VCO, it might be *way* out of tune. Here are some 
tips for tuning the VCO:

<figure class="inlineRight">
<a href="/images/synth/VCOCompleteBack.jpg">
<img src="/images/synth/VCOCompleteBack.jpg" loading="lazy" width="300px" alt="A photo of the back of the completed VCO">
</a>
<figcaption>Note 4 thermistors directly above the trimpot</figcaption>
</figure>

* Warm up the VCO by powering it on for 15 minutes or so before you start
* Try to avoid handling the module too much (although it's difficult to avoid!),
  and especially don't touch the temperature-sensitive components such as the 
  thermistors and transistors
* Like Moritz does in the video, I used a hardware sequencer to emit an 
  alternating pitch and used a plugin tuner. But I also connected a software 
  instrument so that I would have an audio pitch reference as well. 
* The first time you tune, start with a narrow interval such as one octave. 
  Then expand the interval. Later you can go directly to five octaves or 
  whatever.

When you are tuning a mki x es.EDU module which is *not* on a breadboard, the 
1k precision trimmer ("offset") and the coarse/fine pots are on opposite sides
of the module! So the process of tuning involves a lot of handling the module
as you flip it back and forth. This seems unnecessary and it's probably my 
biggest complaint about the VCO. Why not make the trimpot accessible through
the front of the module? 

Also, while you're handling the module, be careful not to touch the line of 4
thermistors, which are right next to the trimpot! They are there to keep the 
pitch stable even when the operating temperature of the whole module changes
(due, perhaps, to a change in outside temperature or internal heating of a 
nearby power supply). Touching one will throw the pitch off!

I found having both a software instrument playing an audio pitch reference as
well as a tuner helpful when tuning for a couple of reasons. First, my tuner
only reports the note name, not the octave. When I was first tuning the VCO I 
wasn't sure it was even playing the correct octave! Second, a tuner will tend 
to jump between the "actual" note that you're playing (say, a C) and its 
relative fifth (G, in this case). Having an audio reference makes it easier 
to distinguish these, and it's very easy to do when your keyboard can emit both
MIDI and CV at the same time. 

Some modern analog synthesizers have an auto-tune feature, but the mki x es.EDU 
VCO unfortunately does not have this nicety. 

## Instructions Errata

One kind of funny omission from the instructions: For whatever reason, one of 
the resistors, R11, was never shown assembled in the photos. Looking at the 
schematic it's certainly needed, and an appropriate resistor is included with 
the kit. 

## Test Point Voltages

Someone was asking for this data, so here are the voltages I measured at the 
various test points on the PCB with the completed kit.

### Before Tuning

Before I tuned the oscillator, I measured the voltage at test points A-D.

For test points A-C, I moved the large coarse tuning potentiometer when taking
measurements. For test point D, I moved the PWM Width potentiometer when taking
measurements. In all cases I took these measurements without connecting any kind
of external CV signal, which might have changed the "DC" signals into something
else entirely.

|              |    A  |       B       |       C       |    D   |
| -------------| ----- | ------------- | ------------- | ------ |
| Signal type* | DC    | Saw           | Saw           | DC     |
| Pot at 0%    | 0.37V | 3Vpp, 8.92 Hz | 3Vpp, 8.92 Hz | -1.39V |
| Pot at 50%   | 0.46V | 3Vpp, 273 Hz  | 3Vpp, 273 Hz  | 0.08V  |
| Pot at 100%  | 0.52V | 3Vpp, 3905 Hz | 3Vpp, 3905 Hz | 1.39V  |

*The signal type when no CVs are connected to the input jacks.

### After Tuning

I also measured the voltage out of the oscillator from the PWM jack after tuning
and with a "C3" (one octave below middle C) CV voltage on the 1V/Oct jack. This 
is an [FFT](https://www.edn.com/ffts-and-oscilloscopes-a-practical-guide/) of 
the square wave which you can see in yellow. It's cool because you can see the 
[harmonics](https://www.prosoundtraining.com/2010/03/13/square-waves-and-dc-content/) 
in the FFT chart.

<figure>
<a href="/images/synth/SDS00001.png">
<img src="/images/synth/SDS00001.png" loading="lazy" width="600px" alt="FFT of voltage measured from output of the VCO">
</a>
<figcaption>FFT</figcaption>
</figure>

## What's Next?

In keeping with the semirandom nature of the posts in this series, I will have
a few things to say about 
[alternate models of computation](2023-08-11-building-a-synthesizer-6.html). 
Stay tuned!

## Resources

### Instructions
* [mki x es.EDU VCO User Manual](https://www.ericasynths.lv/media/VCO_MANUAL_v2.pdf)

### Community
* [Modwiggler thread](https://www.modwiggler.com/forum/viewtopic.php?t=257249)
* [Modulargrid page](https://www.modulargrid.net/e/erica-synths-edu-vco)

### Product Pages
* [EDU DIY VCO](https://www.ericasynths.lv/shop/diy-kits-1/edu-diy-vco/)
* [mki x es.EDU DIY System](https://www.ericasynths.lv/shop/diy-kits-1/mki-x-esedu-diy-system/)

### Simulation
* The [full VCO](https://www.falstad.com/circuit/circuitjs.html?ctz=CQAgjCAMB0l5YCsA2ATIkrqIOwE5IBmQvPMHMPQyZZEHAFhA0UmYFMBaMMAKDAAchEJ1Q5U4ZHBFgpk6WxgYw0WiELRizKLwAmMuUlRtR48ImOZwAOQZgGA3gHcDbWdO6GLi5yLET3E39zS0heAGM-M0CogOQBRUxoY3hUtKIuPCSKOwQhQUJ0VGRhGDg+AHNYyQTq2Tw6HxdTOI9iOhiw5uCYzzd4ptcakzBUAWGdAEMZMclkJk55uaZx0ZnwdOz7SEZkMkgBFCQMLBywPMICopKN1N9Fplklh8lZHWal2TfuWa-G+9Gq2Q30BkgcOkiLyeTH6S0UsFSECwVCEhVQDBIqAI5CgCL4ACcoMsieRZm40rwqm5xONqQwYe8SbQmODoToAC4iQgWV50TjtXkkvzJISQRCIBg4ARS-CIN4wDHnBglRDUem4BgoW4gXTsABmkwArgAbdmUrmEDolCT8y2SBpEsKczh2K2FLkCR7WonccAqPBy0aUQgUHDiHYiBX4PDouyIATIHCWpPa3UGk1m5qET2C-k8v46Qn8nMF4uPbwk9K8ABKHvLljL5kgDLYDDcEkSShrdbB40b5DWiTb6072F4RblcXdnEn9saTa6IlnsmnDn67rC5AWy72fOXNPAt3hcAwADEAJYAO3Y5pdDoHNoY95wch8E7WK5ty4r5LuW5EUhAh4gG9oe5wKAiGAAMIAPaTPiADON5FiBvSoaq87gfA44AQcxKLHhpK0uo1BwN2BGrAeFHgC+nYgMOPyOriiDkehdrUUgzZMcOg6OmO75Tl+MaSBuR5kdMbj0mwtT2MOqw2h+mwKqgxiurgcCKkQkbJOi6A4OKYwYm2YDulhZEuJJWqwjC-CMDIH4hny96SgEYnwoUgjpOkwgAAomkhIAAOrnro7IABY4ZwznolyAQMDFv7YbW3AOS+9kBJadE8R2fEsclPBxWYKVxQIxGtiMOXwixWZxTFnjgPFNlFqZjWxQ1pUkm2ZFVPyJV9qZrAtgCHStZJCW8NM5AjVq6DTXQWRIDIyibC60CHBQqltgIBVYiIDBrbg9QIMYSAlDgbkTfRQIyb8AwgAtGDcMtaTaSp8WsKqBBPngmpZJwMBvXpBmeoQxmmRSLhTQ10RpZxNmQ7Dg2YFqcOMrNTZMOj9hWb4rK7ldNFkjhrIHqCRGVnckO-KTt21GEhIk7MJPCa2ODYVUzMSKyCRlbwqA8OAtNuMJsh04eCTSASIAyVJgurLLiVkYSZOy2TBlEgM5lyw1PGwwrfMC1jmp0GqDVWeL8CYOaav5r8KC86SS4fhWM7O1xbDnSoEgYKO0EAGogD557suEYUgAAkpeAAOhpms1tULKZmUaxLm52b14DJxnJkfsjqS4vYdo+YFACyIBQQHAAy7AAG7sMatk2qZWJ8s3cL0ESPu5YHgXl379ysoUfaD6+A+rFnSej80a4iY+eMbgP8+Pm8n46AAHku+YOI9v3teMmNMEHIdhQAOghFe2Qs9KrBhe14yvbnHmKICniXA8DTmLqmcC-zT9-3zX0FPTO+N92KAPsB1RWac57yw6i6VkxsiSezWtoX2L8y4Xw3i6YEOtzoujEGbVsmAmCv14Fg+Mgs0AkmKBgA+Pc34wXolkYibZSCoIRHAPAL4UDoCJFzLIhBeCMPFNLahWI2AaDwAmZUrBID8ykQ0H6uJ4AQFUbwIAA)
(as breadboarded; this is missing a few components not on the breadboard such as 
thermistors and output protection resistors)

### Videos
* [Introducing the mki x es.edu DIY VCO kit](https://www.youtube.com/watch?v=8JuYLLpZzBs) 
  by Moritz Klein (7:23). This is a super-short overview with a demo of the
  full system.
* [Erica Synths .EDU VCO - Building, tuning, playing](https://www.youtube.com/watch?v=MMif8sz_6Cc)
  by Synth Diy Guy (17:53)