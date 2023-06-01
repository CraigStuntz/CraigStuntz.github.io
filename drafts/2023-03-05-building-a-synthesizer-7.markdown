---
title: "Building a Synthesizer, Chapter 7: Building the Mixer"
series: Building a Synthesizer
chapter: "7"
chapterName: Building the Mixer
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
* [Glossary and Electrical Connections](2023-01-23-building-a-synthesizer-glossary.html)
</div>

There are two "mixer" modules in the mki x es.EDU system, the "Mixer" module and
the "Output" module. Both can combine multiple audio signals into one, but they
do it somewhat differently and the use cases are different. This "Mixer" module
will combine up to three mono signals into a single mono output, and it can also
optinally clip or invert the signal. The "Output" module will combine up to two
mono signals into a stereo line level and headphones output, with panning. A 
mixer is a pretty handy module to have, and there are different reasons to use a 
mixer!

Another big difference between the two modules is the directions. The directions
for the "Mixer" module were written by Moritz Klein and very much follow the 
style set out in most of the rest of the mki x es.EDU modules, with an emphasis
on breadboarding before soldering, and a folksy, style. Moritz frequently says, 
in both the printed directions and his videos, approximately, "you could use 
math to calculate these values, but I prefer to use trial and error."

I'll discuss the Output module in a future post, but for now let's just say that
the directions are day-and-night different. 

## Passive vs. Active Mixing

The instructions make a valiant attempt to explain how the mixer works in its 
final configuration, when it uses an op amp in an inverting configuration. It 
mostly succeeds, but I do think portions of it could be clearer, so I will 
attempt to add some additional explanation.

The instructions take us through three steps: 

1. A passive mixer
2. An "active mixer" with an op amp in a non-inverting configuration
3. An active mixer with an op amp in an inverting configuration

### Passive Mixers, and Why They're Not So Great

The manual correctly identifies low output volume of the signal 
(caused by a high output impedance) as one problem with the passive mixer 
design. But it's not the only problem. One of the problems with a passive
mixer is that if you have a musical signal connected to one of the inputs and 
then you connect a 0V signal into another input, the level of the music on the 
output changes! 

It's even worse when you have more than two inputs. If you have three inputs, 
and you have two of them connected to music inputs, and you set the levels 
appropriately, then you will be very surprised when you plug in a third input
and the levels change relative to each other. 

Why? A passive mixer is just a voltage divider in disguise. 
And it's not much of a disguise. A voltage divider with one input connected to 
ground is a voltage divider, whereas the same circuit with the same input entirely
disconnected is just a single resistor. End users of your mixer will not expect
this behavior.

### "Active" Mixers (with Scare Quotes)

Klein introduces the notion of an "active" mixer by putting a op amp buffer in
non-inverting mode after the passive mixer. While this is "active" in the sense
that it contains active components, namely the op amp, it's not what most people
would consider an active mixer, because the mixer itself is still passive.

To be honest I'm not sure why you would use this configuration, because it 
doesn't fix the problem with the volume _or_ the problem with a 0V signal and 
an entirely disconnected mixer input resulting in two different behaviors when
connecting a real signal to some other input.

### Active Mixers (No Scare Quotes)

When you swap the non-inverting op amp for an op amp in an inverting 
configuration, however, things change. Naïvely, this shouldn't make a 
difference, because what good does inverting the signal do? But we're not just
inverting the signal, we are also moving the feedback signal from the op amp 
input which doesn't take the mix output to the one which does. And _that_ is 
what makes the difference. 

## Weirdness

<figure class="inlineRight">
<a href="/images/synth/MixerOptionalOpAmp.png">
<img src="/images/synth/MixerOptionalOpAmp.png" width="156px" loading="lazy" alt="Schematic of optional op amp circuit with zero-Ohm resistors">
</a>
<figcaption>Huh?</figcaption>
</figure>

The kit includes two [zero Ohm resistors, which really are a thing](https://en.wikipedia.org/wiki/Zero-ohm_link). They are totally unmentioned in the manual, and omitted from the 
bill of materials, but are in the schematic and the pictures of the completed 
board. They are part of an "optional inverting/noninverting op amp circuit" which 
is not in the signal path of the rest of the mixer. (See schematic at right; 
R12 and R14 are zero Ohms. The remaining resistors should not be 
installed at all; "DNM" means "Do Not Mount.")

Installing the two zero-Ohm resistors puts the second op amp in the second TL072
into a buffer configuration, with the noninverting input set to ground. So it
buffers ground? I guess this circuit is "reserved for future expansion."

Perhaps the (currently unused) op amp wants to be grounded to avoid noise 
problems? The data sheet doesn't mention this. It's a weird omission from the 
manual.

## Resources

### Instructions

* [mki x es.EDU Mixer User Manual](https://www.ericasynths.lv/media/VCO_MANUAL_v2.pdf)

### Simulations

All of these simulations are by Moritz Klein

* [A simple "active" mixer](https://www.falstad.com/circuit/circuitjs.html?ctz=CQAgjCAMB0l3BWK0AcB2ATATjAZhbgGy6aR64iFYhIAsFCApgLRhgBQAHjSkmpBRRhIIfoRC0QuDCACCAYQAqASQBqAUQA6AZwCyygBrqASuwDulWiJSFJt61nGRzlkVgwpXIFI6jtjNIRuHjRgMu6eInZwNFBxMAjsAE5eEYHBkeDwcP7p3rahMjaSIhS4MUgiVdCJKQhB+XZWjXHC2exWFLQFaAgy9dZgTjQA+igjkCNh2LQjtNBYi0tLKCgY0rgTsHBgI6wjGCMII7gdAhIFWGjiA1nNpWMTUxgzcwvLy6vr61vwu-uHTanACGlFW3hQ1hiq2s4BkrBkbWyIAw0AwCEWaDQVgECEgWG6aBRaKC2R2GFoWDxSCROQshHBxTBniEThcDJZQ280K5zgskMG4gFEKq7MZvns3l8zgA8tzrJCpULFaLOt5aCyYgTJEyRGBZuNJtMCW9lnj4Ph1mBDdsyHtdhwAEYSLmEBBExZ6yAEPxAA) (passive mixer with an op amp output buffer)
* ["Inverting" mixer](https://www.falstad.com/circuit/circuitjs.html?ctz=CQAgjCAMB0l3BWK0AcB2ATATjAZhbgGy6aR64iFYhIAsFCApgLRhgBQAHjYUoSpBApaKSgRC0QuDCACSAOQBqAUQBKAFQUBxADoBnALKyAGmvYB3SrUEEZha0PtQLVm1kKvHkyO1U83HghgMijuUBKUcDThgjAI7ABOnqGBhAHhYPBwvv5C0jTBeTKCFLhRSLHI8UkIaUXJ+YKZWezWFLROpLlowuEIAPoo-ZD9wdi0-bTQWFhZcBi0GPa4uMOwcGD9rP0Y-QO4rZDtTli0krVNcKIlg8OjGOOT07NzC0v0uAMw8Jvbu6sHACGYlEKAEQiiYJs4BkrBkzSyIGYuGg+AEZTAIjYGDQCDQuBYGAglxaln4oKc5KEYA8PksAhsNIhNnBdJBXmSTh8AHlmUJwSl+ZUfG0hCI+adJCgueBVkMRmNTv0sNMEFg0GQiSQMAgUGA0GsfltNhwAObswVUyUxRJ8vUeKn2jJzdgAIwkYGoxCQWBQSEyuucQA) (an active mixer with an op amp in an inverting configuration)
* ["Double negative" mixer](https://www.falstad.com/circuit/circuitjs.html?ctz=CQAgjCAMB0l3BWK0AcB2ATATjAZhbgGy6aR64iFYhIAsFCApgLRhgBQAHjQhpStSyE+VPrRC4+AEQDyAVQBCAGQCiAHQDOAORUBxAIIAVAJIA1dRoCyxgBoqASuwDulWpBAERbj4XGRnru44Xu4ovlDs9jSEQVh8CGB8WHFQIOIx7kju2dAI7ABOgSDJ8THFKe5g8HCR0aGSNIkeDe4UuHA0qTl5hQhlnkUDldX+bhS04aR1IGgofjQA+igLkAuJ2LQLtNDJu3tYaFSQyzDwYAusCxgLCAu47GNp4VUY4n3DKCipuEsraxgbLY7fZ7Q5YSBoFawODnS7XH73ACG-C+n1CHTRHnAfFYfCqIxAzFOMLIuDJE0kuDiJAOqXx8AChE+PnSzJQYEIERcKAxHI8GJ5XJRLMG4X8AHNhQJOUyvlhaPN-IUeaE+bKPHzhtUCuU+ANMUNwCN2JLMcEPIKhNkIjJdR4hEa2Q7sgESs0kilpUKDYKDS12MiDQ63V6vk1cUaCcSyKTcGB6IRCFUEJAELM6cblQLQr7BVqGY8qt52Zy2EQLdawJCTv9AVVYGgyQIMGBkmgyCdoWQLucONzs-zhpgbYOjcO2JBxFVhy7C6nOW62LwjX1Uq9fqt1vK1qdGwhwUy0GgELQEJ2zj21ozvG7fEEmkrpua78UH5GGVF3q-4k1zZU0imnTWjAeSPPg4iYrQloKmuyw1lumzbPs+BxrQWBzEQUIXnCVzLPcABGEjli+bDoOA8ZfP4QA) (has another inverting op amp to allow for a non-inverting output)
* ["Adjustable" mixer](https://www.falstad.com/circuit/circuitjs.html?ctz=CQAgjCAMB0l3BWK0AcB2ATATjAZhbgGy6aR64iFYhIAsFCApgLRhgBQAHjW5VrSH7UqaEANwYQAQQAiAKQCqAZQAqUgEIAZAKIAdAM4BJAHIAFBSoM6Aats1L2Ad0q1IIApMKv3XqE5duOJ7eKL6Q7ABKYiiBWJL0klhxUGKUcDQpbjAI7ABOAYLJCISxkm5g8HCR0W4eYhLuDW4UuOlIWcg5+cW1DV69ZeCV4a4tKAKkNSBo4ykIAPoo85DzYBjYtPO00Em7u5hYmBibMPBg86zzGPMLuOyjIPgCFcdTFSgoKbiLy6vr-Fsdnt9tgjidYHBzpdrt87gBDSgfdwxdzpD61cCSViSCrDEDMU7wBCuSBoMAIHAzOKEBCicrDfyEJGhARMz4oMCEPzOGK1Tmo2oo8LONk+VkhMLsADmiPZWC5ov4AiyeQF7n5oo5XPplVVSUkdXRjUGuPg0uRgTWFsEJUy7AA8oUDfKhsyXSrnPrjU73O7-EaAyi6uEEQGXV6UC7PlbsUM8YTECSSmgsJBabhaMSMO042b8rzrYGOqaqg8KiF+WwiNbymgfis1ht5oRoAhaZBXGAUMVsyhjssIWQLucODy0UH0hVMH5HQWpzjy0Npyqy2muV62AgcWuUv2lg3-psW22yWSJF5sAgSAOzsPVozvF7+oIreFuraggVPzqzVFaCjPwSF8TTEBA3BzLJW3uSAWg7a0SUEWhlRADAln3P4mwWBMoXOa5UPmO4wDQAR-wGGhUO9H90hgNBCDQVphmGCATHMFRwH8BArS1HgDWo81iQEOoBPcf87WcTjePA20C2FGhpLaaSmg46SUR6YDuR4601KNcIZWEz99Ioj1NMjLkJJrdgiJIgCrS3T5v1zajoCIMASUYyokBYiwUMs4ipi9OyfSoyDEBALy2LucSrUOMzottXSaCQn1hNxT5jPM+UpMCeLlOyrKgvYAAjFDiRcaMMEnckVSAA) (has adjustable input levels, plus inverting and non-inverting outputs)
* [Entire circuit](https://www.falstad.com/circuit/circuitjs.html?ctz=CQAgjCAMB0l3BWK0AcB2ATATjAZhbgGy6aR64iFYhIAsFCApgLRhgBQAHiLStYSgzg4-FHRBEQAdQCSAFQASAHQDOAZQDyAMTmqAwgBkZABWMBRACKqNAVTnG77AO6VakEASGE3H71Geu7jhePih+kOwASjwoQVhC9EJY8VA8lHA0qe4wCOwAToEgyUIIhHFC7mDwcFEx7p48uEIN7hS4GUjZyLkFpfVNhS3C1exubSi0IKR1UxOpCAD6KAuQC2AY2LQLtNBYfMkHWLQbaDgrsHBgC6wLGAuLuKOQ45NVGJO8lZAoKKm4Sys1hsjttdvtDkcTmcYPArjc7v9HgBDSg-DyxDwZH71cBCVhCKrVbIXOD0U6EDCxU6JLCk1KE+ABAS-MKTZkeMCEfwuWL1TmY+oYiIudmswbhdgAc1RLKwXPZR0m2XyAo58rRKH5XxGBWKHgG2P1FWGjOlhuC6KCZSy7A0RRSfC5bEgk0dNpceoanrl3MtfsNLXYKIDPu9XN+6xA+JN8CjMPgZKwCDcvDCGFw62o2sZBV5-oxhuzNTGwlKavAYAQzSF4DQANW602C0I0FoaFox3wkHJJHw51h1yuHB5WILGSqmH8drzE4JVVe3eNERLVTLerYVdLXPc73rQKbLbbtAQCCacvoeywdfjZEHayZPj13iCkYivWtFufRVfMYi0U+34JAMFqVDwCDuJ0WTQLkJbtK6GJuEEHapJSe6NiCOwQvgGa0OeSb9pcd53KhjxgO2MwNFWLIDEWxLtmgSAyAAcg4cjgAECCRpqXKcc0GQRNKyaugMQkeLw7o0FxHTWnmwo0DJ0n9BUHEyRifSAb6vF+uphZSjQyEWqJ8S-MqLhaW65lCuwZEfBihmUhptHIEQYCIUSRKMSxdggBg1nkQBepUfaxoMvxFyeaxEgcZGV48TF1oCfpkyBchhImZp8UQR+CUqVaWXlL6FrrOJbrFSZASGmVHg+lVETcFQlSUv0TqUhQryTIYJiqMxchmExajyAAmqociRDIACyXAeBgSB4FiuHgO0bXgJMGCQAA0hVfh4FxNUZspPLbU1vivPt-g2dVLUlUdPo7tU3S4HK7lEhAmg6CAnXGCAPV9QNciDSqM5rYKjX8aiIzSoqi0GalJDbv4uqpcdUN4MhO5oIyLiri1-LY7iVmI68x14+sNahXJKPpkkSNWWae27U6uBo1OW64rj85s-DFORusGSU-xQZFEjuOQGW6z8tQkbRuTxK0GRaAEJ8uHYAQrnIHLCvPDtpxwJSTpEhVGK8y+BLA-4AAmGlVUVZsEkxcu8OwluVWbLviXbDsoAEYbBRWa2FSkbD+zOvO+iHwfjmby7PKzbCSBuptgwgWBocCWwYNAGCuR255gHKGNhARt43BwABGPknpQGAtS6K3vP4QA) (as breadboarded, adds diode clipping)

### Videos

* [Introducing the mki x es.edu DIY S&H/Noise and Mixer kits](https://www.youtube.com/watch?v=_vrc4qgBqbA),
  by Moritz Klein (3:57)
### Web Sites

* [Mod Wiggler thread](https://modwiggler.com/forum/viewtopic.php?t=263624) (Pretty empty when I looked)
* [ModularGrid page](https://www.modulargrid.net/e/erica-synths-edu-mixer)