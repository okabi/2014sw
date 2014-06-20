exe = sample
o = test.o
c = main.c
asm = test.asm
tc = test.tc
tinyc = tinyc.rb
y = compiler.y

$(exe): $(o) $(c) $(asm) $(tc) $(tinyc) $(y)
	racc -o $(tinyc) $(y)
	ruby $(tinyc) < $(tc)
	nasm -f elf $(asm)
	gcc -m32 -o $(exe) $(c) $(o)

$(o): $(c) $(asm) $(tc) $(tinyc) $(y)
	racc -o $(tinyc) $(y)
	ruby $(tinyc) < $(tc)
	nasm -f elf $(asm)