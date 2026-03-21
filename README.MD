# 100 Hours of Embedded Challenge

I want to become an embedded engineer, so I asked claude to make me a study plan. I plan on doing 10 hours of embedded for 10 days. 

### Day 1.

The day 1 took me three days. At the actual day 1 I tried to set up sigrok, picoprobe using my rp2040 boards and picos. 

- I soldered my custom PCB with all the necessary components (so I thought).
- Setting up software was a nightmare on Fedora. I downloaded nightly build of PulseView (took my a while) and extensions on vscode for pico probe.
- I managed to flash a software using pico probe to other pico's SWD pins. (Success) Though I couldn't reliable pause the execution at red bullets in vscode)

on Day 2 I studied Chapter 5 at K&R C Language book and set up Obsidian notes (might and hope to include it in repo).

- Learned in details pointers and how do they work.
- In particular I understood how functions can be pointed at.
- and that we can have a vector table (an array of pointers to functions, that's crazy)

on Day 3. I studied Chapter 6 Structs at K&R.

- Recalled myself what structs are how they manage memory
- Found out what is union and typedef
- Performed bit manipulations a lot (like it)
- Made an LED Blink without using pico sdk (almost). The code is written without sdk but built with it. I hope I will be able to build programs without any SDKs in future.
