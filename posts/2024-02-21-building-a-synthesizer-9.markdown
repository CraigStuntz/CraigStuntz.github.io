---
title: "Building a Synthesizer, Chapter 9: A Field Guide to Oscillators"
series: Building a Synthesizer
chapter: "9"
chapterName: A Field Guide to Oscillators
tags: synthesis, electrical engineering, oscillators
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
* 9: A Field Guide to Oscillators
* [Glossary and Electrical Connections](2023-01-23-building-a-synthesizer-glossary.html)
</div>

If you own a synthesizer, or have worked with software synthesizer plugins, you
have no doubt encountered the term "VCO" or "Voltage Controlled Oscillator," 
and indeed 
[we have seen it before in this series](2023-03-02-building-a-synthesizer-3.html). 
Today most synthesizers are fully digital and just have "oscillators," which produce
arbitrary waveforms using a computer, but you may also encounter "DCOs" or 
perhaps just "Oscillators," and wonder if these names actually mean 
anything distinct.

In this post I'll explain the "oscillator" part of how synthesizers produce 
sound, look at three designs for actually building an oscillator, and talk about
the differences in sound that you may hear from these designs. 

## Voltage Controlled Oscillators

I won't spend a ton of time explaining how a VCO works because 
[I've already done that](2023-03-02-building-a-synthesizer-3.html). For the sake
of this post I'll just say that the entire oscillator, including both the 
control of the tuning/timing as well as the shape of the wave produced, is analog.

The earliest commercial synthesizers,[^commercial] such as Moogs, ARPs, and 
Buchlas from the 1960s all used VCOs. 

One of the major downsides of a VCO is you have to tune it. A lot. Some later
commercial synths with VCOs introduced an automatic tuning feature which helps
considerably, but they will still drift as you play them due primarily to 
temperature changes but also due to aging of electronic componaents and the 
inherent differences between two "identical" components. Two transistors from 
the same manufacturer with the same model number and made in the same production 
run can have very different electrical characteristics, for example. Also, as the name 
suggests, they are *Voltage Controlled,* that is, controlled with an analog 
voltage which might be produced by a keyboard or a sequencer, and there is 
no single standard for control voltages, so you have to tune the VCO to produce
the correct note when you, for example, press keys on your keyboard. 

On the other hand, VCOs often sound *amazing,* and the tuning drift may be part
of the reason! One surefire way to fatten up nearly any synthesizer sound is to
add another oscillator and *detune* the second oscillator so it doesn't produce
precisely the same frequency as the first. Make it "fatter" still by using a 
LFO (Low Frequency Oscillator) to vary the detuning over time just a bit. Our 
ears hear this difference in frequencies as a beating sound
which might be pleasant or unpleasant, depending upon the amount of difference
between the two oscillators. Do this with two VCOs and there will be a certain
amount of drift between the two oscillators *as you play,* and this can be a 
very pleasant sound. For a while, anyway, until it goes *way* out of tune and
you have to stop playing and retune it. 

VCOs are said to have a characteristic sound due both to a limitation in the 
waveshapes which are used (typically, square, sine, sawtooth/ramp, triangle, 
and a few others) and also due to the variations in tuning. Happily, though,
many people really like the sounds that they produce.

## Digitally Controlled Oscillators

A DCO still produces an individual cycle of oscillation using analog electronics,
but uses a digital timer (typically controlled via a microcontroller) to trigger 
each cycle. This allows the DCO to always have "perfect pitch." Like a VCO, a DCO is also an 
analog oscillator which uses analog circuits to produce the wave shape that you
hear. 

A DCO will never require tuning. The note "A 440" will always sound at 440 Hz. 
You can detune a DCO, which as above you might do if using two oscillators 
together to produce a fatter sound. But there will not be any random "drift" in 
the tuning.[^DCO]

The first synth with a DCO was the Roland Juno-6, which was available in 
1982.[^ARP] DCO-based oscillators are not so common today. The majority of 
commercial synthesizers are digital, and folks looking for an "authentic" 
analog sound often want a VCO in spite of tuning headaches. 

Essentially, the way a DCO works is the microcontroller sends a signal to the 
analog circuit when it's time to produce each cycle of the waveform. You can 
think of a microcontroller sending a pulse every 1/440th of a second to produce 
an "A" note. From there an analog circuit produces a single cycle in almost 
exactly the same way that a VCO does, and then it stops and waits for the next 
pulse from the digital controller.

I would explain how a DCO is implemented in hardware, but 
[Thea Flowers has already done a much better job of this than I ever could](https://blog.thea.codes/the-design-of-the-juno-dco/), so if you're interested (and it is *very* interesting, I think!)
then I recommend you go read her article!

Conceptually, the only "audible" difference between a DCO and a VCO is that the 
DCO will never drift in the
tuning of its fundamental frequency. From a practical, real-world standpoint, 
however, they might be implemented with different components and hence sound 
very distinct, and even two "identical" analog oscillators can sound different 
because of the difference between "identical" analog parts. Also, VCOs, as noted,
*do* drift in pitch, and this also makes them sound different than a DCO.

## Digital Synthesis

Digital Synthesis produces a sound by using a computer program to produce 
a waveform digitally. This includes samplers/sample players, all software 
synthesizers, and "virtual analog" synths which use clever programming to try
to reproduce the sound of a VCO or DCO. 
[Some of them do it quite well!](https://www.whippedcreamsounds.com/uhe-diva-review/)

The first mainstream digital synthesizers were [the Casio VL-1 in 1979](https://www.youtube.com/watch?v=3TT5nAW8gi4), which was
something of a toy but considerably cheaper than the other digital synthesizers 
available at that time which were > $10000 in 1980 dollars. Other notable 
milestones in making digital synthesis a mainstream technique were the E-mu 
Emulator, released in 1982, and the Yamaha DX-7, in 1983.

The sound of a digital "oscillator" will be precisely what its programmers 
specify. This could be a perfect sine wave, playback of a sample, 
a modeled recreation of an analog oscillator, small slices of a sample as with a 
[wavetable synthesizer](https://blog.native-instruments.com/what-is-wavetable-synthesis/),
or many other things. A digital synthesizer will have a Digital to Analog 
Converter (DAC) in its signal path; a VCO or DCO based synth will not require 
this.

Some people will tell you that they can hear the digital "stepping" as, for example, a
16 bit, 44.1 kHz digital oscillator changes its output through its 65,536 possible 
amplitudes over every 1/44100s. I will tell you that these people are wrong, and
that they cannot hear this.[^Nyquist] However, they *may in fact* hear the 
difference between a VCO and a "perfect" digital recreation of the "same" VCO, 
because, once again, even two "identical" VCOs may sound different because of 
differences between the analog parts, their variance with temperature, etc. 

While it's both theoretically and practically possible for a digital oscillator
to reproduce the sound of an analog oscillator well, there's no denying that 
many synth manufacturers have not bothered to do it well. Sometimes this is on
purpose; a wavetable synth, for example, is not *trying* to reproduce the sound
of a VCO. But even in cases where a synth manufacturer explicitly claims to 
have an "analog sound" from their digital oscillators, well, some of them do 
it better than others.

## Synthesizers Today

The majority of hardware synthesizers, and *all* software synthesizers, sold 
today are digital. Digital oscillators are quite common even in the modular 
synthesis world. However, there are still fully analog hardware synthesizers 
produced, in keyboard, desktop, and modular forms, generally with VCOs. 

[^commercial]: Yes, I'm aware that there were earlier synthesizers; the market 
for "mass produced" syntesizers took off in the 1960s-early 1970s. 

[^ARP]: I have seen claims online that the ARP Pro Soloist (1972) has a DCO, 
including claims that it was *the first* commercial synth to use DCOs. I 
have also seen schematics for the Pro Soloist online and as far as I can tell 
these claims are incorrect. Never trust anything you find on the Internet, kids.

[^DCO]: In principle it would be possible to make a DCO reproduce the sound of
a VCO exactly by programming the microcontroller to have VCO-like drift in its
tuning. In practice I've never seen a DCO-based synth do this, although it's a 
fairly common technique in "virtual analog" digital synths. Note also that 
with any synth it's quite common for preset designers to use the synth's LFOs to 
modulate the pitch a little (or a lot, as with vibrato), but this is a different
effect than the analog variations which are characteristic of a VCO and might 
be emulated by a digital synthesizer. So in practice DCO-based synths sound 
somewhat different from VCO-based synths, even if in principle they *could* 
sound the same.

[^Nyquist]: See, for example, the 
[Nyquist theorem](https://en.wikipedia.org/wiki/Nyquist%E2%80%93Shannon_sampling_theorem)
which shows that there is no difference between a properly dithered digital 
recreation of an analog signal and the original analog signal at audible 
frequencies, and before you tell me that your golden ears can hear sounds only
audible to dogs please consider that most synthesizer presets are low-pass filtered
down to frequences which all of us can hear. This is a complicated topic both
because there is in fact an actual audible difference between "identical" analog
VCOs as well as the metric tons of horse poop produced by the "audiophile" press
on the subject.