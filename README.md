# AssemblyTesting
## NASM Calculator (Linux only)
calc.asm is a simple calculator I wrote. 
It only works on Linux and if you're on Windows I recommend you use WSL and run it there
### Build instructions
run:
``` 
nasm -f elf64 calc.asm
ld calc.o -o calc
```
and exucute with:
```
./calc
```
on any x86_64 Linux distro.

And you have *a totally not unnecessary* cl calculator 
