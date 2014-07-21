exe = sample
c = c_fun.c
asm = test.asm
o = test.o
tc =  test
tinyc = tinyc.rb


$(exe).out: $(tc).tc
	ruby $(tinyc) < $(tc).tc 2> $(exe).err
	nasm -f elf $(asm)
	gcc -m32 -o $(exe) $(o) $(c)
