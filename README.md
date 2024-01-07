# DCJ11Hack+
DCJ11 Hack+ related boards, PAL code and example code
by Paula Maddox http://maddoxp.pro

This is my first github project, I've decided to share my DCJ11 based board. It's based heavily on the word done by Beent Hilpert http://madrona.ca/e/pdp11hack/ but I wanted to able to add and remove functionality via a back plane.

I've long admired this chip for no other reason than it looks so freekin' cool, I mean just look at it, it's gorgeous.

https://raw.githubusercontent.com/TechPaula/DCJ11Hack-/main/images/DCJ11_CPU.png

So far There is the main CPU board and also the RAM, ROM and text display board. You'll find the schematics and PCB files here and they were made in KiCAD Version 7.0.1 but should work with later versions of KiCAD. I've also included the PAL files for each of the PALs on the board (one on each board). Hopefully this will give you enough to get going.
The text displays are mounted on the opposite side to the RAM/ROM chips as I wanted to be able to see the text and also be able to turn it to see the DCJ11 chip (did I say how gorgeous this chip is?).

When it powers up the chip jumps to it's "ODT" mode rather than running code, this was done to allow me to play around with thinngs and get an understanding of the chip. 
The default baud rate is 115200 and uses 8bits, 1 stop and no  parity. 

The code examples are for a basic "Hello World!" which just writes characters to the display memory, there's also a more intelligent one. I've also included a "Knight Rider" (or Cylon if you prefer) bit of code and finally a terminal test code which spits "B" to the console (hit the halt switch to stop it).

You'll find the .asm files and the .oct files.

I use the pdp11 simulator found here https://programmer209.wordpress.com/2011/08/14/pdp-11-assembly-language-simulator/ to compile and test my code, there are others but this is a lot easier to copy and paste code into :)

There is also a pretty good guide to the PDP11 instruction set here - https://programmer209.wordpress.com/2011/08/03/the-pdp-11-assembly-language/

of note, this board **ONLY** supports 16bit wide read/writes, i.e. "word" only, if you use byte commands it will destroy one half of the memory, in the same way as the PDP11 Hack board does, this is less than ideal but it simplifies the circuitry needed a lot.

I user TeraTerm to upload the code, I use a 10mS character and line feed delay, just to give the CPU a chance to respond when it sees the "/".

The last board I would like to make will be some sort of dot matrix display so I can write and run game of life on this.

Finally, I do this for a hobby and for fun, so I don't know when I will add more code or do the third board.

