---
title: "Building a Synthesizer, Chapter 6: Debugging Circuits"
series: Building a Synthesizer
chapter: "6"
chapterName: What Can Debugging Circuits Teach Us About Software Debugging?
tags: diy, electrical engineering, computer science, debugging
---

To keep this post short, I won't be really talking about tools and how to use them (e.g., soldering irons), but they're obviously involved.
Consider obvious things first: (Ground short)
Use a schematic, but keeping the schematic mentally aligned with real hardware on (especially, a) breadboard or PC board can be surprisingly tricky.
Multimeter/current clamp, oscilloscope
Your eyes and senses (look for bridges, cold solder joings. is anything hot? smelly?)
Use a speaker/amplifier as a probe
Oscilliscope tips: Get your ground right, Remember DC coupling, learn the tool
Test components with a tester
Different oscilloscope probes, Power supplies, Signal generators, ESR meters, Vector network analyzers, Spectrum analyzers.
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
