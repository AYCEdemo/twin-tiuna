# Twin ("a literal twin-channeled cover")

This is a source code to the Atari 2600 music demo "Twin". It also contains the
code for the software pitch driver called TIunA which works by changing between
two pitch registers at a very fast speed at the right time. It is located in
main.asm.

Watch the demo [here](https://www.youtube.com/watch?v=5xWEkZSFwKQ). (the main flashy lines are replaced though)

Original song by Petriform. Cover by Abstract 64. Code by Natt.

## Building

Following programs are required:
- [Furnace 0.6.5](https://github.com/tildearrow/furnace/releases/tag/v0.6.5)
- [64tass](https://sourceforge.net/projects/tass64/)

Open twin_tia_ayce.fur in Furnace and do a TIunA export as song.asm with these
parameters:
- base song label name: twin
- max size in first bank: 1024
- max size in other banks: 4048

Then run following commands:
```
64tass -C -a -b -o ayce-twin.bin main.asm
```
