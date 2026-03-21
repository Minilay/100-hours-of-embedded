### Day 1

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


Result: Ohh I touched registers today, it felt illegal how you can. Change local variables without API passes or any functions called, just change variables and hardware physically changes its state. 

Registeres that will never be clean after I touched them today:

- I changed RESET registers and polled program until RESET_DONE registers are done.
- GPIO_CTRL register. Apparently this register is responsible for which peripheral will be responsible for register today.
- GPIO_OE. This register sets Gpio to output or input mode.
- GPIO_OUT. This register sets gpio to high or low (if output mode was selected)

The most confusing part for me is CMakeLists.txt I don't know yet how my main.c is converted to a binary that RP2040 understands.
