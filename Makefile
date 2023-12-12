QEMU=qemu-system-riscv32

CC=/opt/homebrew/opt/llvm/bin/clang

CFLAGS=-std=c11 -O2 -g3 -Wall -Wextra --target=riscv32 -ffreestanding -nostdlib

OBJCOPY=/opt/homebrew/opt/llvm/bin/llvm-objcopy

.PHONY: run
run: kernel.elf
	$(QEMU) -machine virt -bios default -nographic -serial mon:stdio --no-reboot -kernel kernel.elf

kernel.elf: kernel.c common.c shell.bin.o
	$(CC) $(CFLAGS) -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf kernel.c common.c shell.bin.o

shell.bin.o: shell.bin
	$(OBJCOPY) -Ibinary -Oelf32-littleriscv shell.bin shell.bin.o

shell.bin: shell.elf
	$(OBJCOPY) --set-section-flags .bss=alloc,contents -O binary shell.elf shell.bin

shell.elf: shell.c user.c common.c
	$(CC) $(CFLAGS) -Wl,-Tuser.ld -Wl,-Map=shell.map -o shell.elf shell.c user.c common.c

.PHONY: clean
clean:
	rm -f *.o *.elf *.bin *.map
