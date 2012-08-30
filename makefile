# Unix/x86 SPITBOL
#


# SPITBOL Version:
TARGET=   x86
DEBUG=	1

# Minimal source directory.
MINPATH=./

OS=./os

vpath %.c $(OS)


AS=nasm
CC=     bin/tcc
INCDIRS = -Imusl/include
ifeq	($(DEBUG),1)
CFLAGS =  -g  $(INCDIRS)
endif

# Assembler info -- Intel 32-bit syntax
ifeq	($(DEBUG),0)
ASFLAGS = -f elf32 
else
ASFLAGS = -f elf32 -g
endif

# Tools for processing Minimal source file.
LEX=	lex.spt
TRANS=    $(TARGET)/$(TARGET).spt
ERR=    $(TARGET)/err-$(TARGET).spt
SPIT=   ./bin/spitbol

# Implicit rule for building objects from C files.
./%.o: %.c
#.c.o:
	$(CC) -c $(CFLAGS) -o$@ $(OS)/$*.c

# Implicit rule for building objects from assembly language files.
.s.o:
#	$(AS) -a=$*.lst -o $@ $(ASFLAGS) $*.s
	$(AS) -o $@ $(ASFLAGS) $*.s

# C Headers common to all versions and all source files of SPITBOL:
CHDRS =	$(OS)/os.h $(OS)/port.h $(OS)/sproto.h $(OS)/spitio.h $(OS)/spitblks.h $(OS)/globals.init

# C Headers unique to this version of SPITBOL:
UHDRS=	$(OS)/systype.h $(OS)/extern32.h $(OS)/blocks32.h $(OS)/system.h

# Headers common to all C files.
HDRS=	$(CHDRS) $(UHDRS)

# Headers for Minimal source translation:
VHDRS=	$(TARGET)/$(TARGET).cnd $(TARGET)/$(TARGET).def $(TARGET)/$(TARGET).hdr $(TARGET)/hdrdata.inc $(TARGET)/hdrcode.inc

# OS objects:
SYSOBJS=sysax.o sysbs.o sysbx.o syscm.o sysdc.o sysdt.o sysea.o \
	sysef.o sysej.o sysem.o sysen.o sysep.o sysex.o sysfc.o \
	sysgc.o syshs.o sysid.o sysif.o sysil.o sysin.o sysio.o \
	sysld.o sysmm.o sysmx.o sysou.o syspl.o syspp.o sysrw.o \
	sysst.o sysstdio.o systm.o systty.o sysul.o sysxi.o

# Other C objects:
COBJS =	arg2scb.o break.o checkfpu.o compress.o cpys2sc.o doexec.o \
	doset.o dosys.o fakexit.o float.o flush.o gethost.o getshell.o \
	int.o lenfnm.o math.o optfile.o osclose.o \
	osopen.o ospipe.o osread.o oswait.o oswrite.o prompt.o rdenv.o \
	sioarg.o st2d.o stubs.o swcinp.o swcoup.o syslinux.o testty.o\
	trypath.o wrtaout.o

# Assembly language objects common to all versions:
CAOBJS = errors.o serial.o inter.o mtoc.o int-arith.o real-arith.o math-lib.o
#arith.o

# Objects for SPITBOL's HOST function:
#HOBJS=	hostrs6.o scops.o kbops.o vmode.o
HOBJS=

# Objects for SPITBOL's LOAD function.  AIX 4 has dlxxx function library.
#LOBJS=  load.o
#LOBJS=  dlfcn.o load.o
LOBJS=

# main objects:
MOBJS=	main.o getargs.o

# All assembly language objects
AOBJS = $(CAOBJS)

# Minimal source object file:
VOBJS =	spitbol.o

# All objects:
OBJS=	$(MOBJS) $(COBJS) $(HOBJS) $(LOBJS) $(SYSOBJS) $(VOBJS) $(AOBJS)

# main program
LIBS = -Lmusl/lib/crt -Lmusl/lib 
spitbol: $(OBJS)
	tcc -o spitbol $(LIBS) -lm  $(OBJS)  
#	tcc -o spitbol $(LIBS) musl/lib/libm.a $(OBJS)  
#	$(CC) -o spitbol -lm  -L/usr/lib32 -L/usr/lib/x86_64_linux_gnu $(CFLAGS) $(OBJS) 

# Assembly language dependencies:
errors.o: errors.s
spitbol.o: spitbol.s

# SPITBOL Minimal source
spitbol.s:	spitbol.lex $(VHDRS) $(TRANS) mintype.h
	  $(SPIT) -u "spitbol:$(TARGET):comments" $(TRANS)

spitbol.lex: $(MINPATH)spitbol.min $(TARGET)/$(TARGET).cnd $(LEX)
	 $(SPIT) -u "$(MINPATH)spitbol:$(TARGET):spitbol" $(LEX)

spitbol.err: spitbol.s

errors.s: $(TARGET)/$(TARGET).cnd $(ERR) spitbol.s
	   $(SPIT) -1=spitbol.err -2=errors.s $(ERR)

inter.o: mintype.h os.inc

int-arith.o: mintype.h os.inc

real-arith.o: mintype.h os.inc

math-lib.o: mintype.h os.inc

mtoc.o: mintype.h os.inc

# make os objects
cobjs:	$(COBJS)

# C language header dependencies:
$(COBJS): $(HDRS)
$(MOBJS): $(HDRS)
$(SYSOBJS): $(HDRS)
main.o: $(OS)/save.h
sysgc.o: $(OS)/save.h
sysxi.o: $(OS)/save.h
dlfcn.o: dlfcn.h

boot:
	cp -p bootstrap/spitbol.s bootstrap/spitbol.lex bootstrap/errors.s .

install:
	sudo cp spitbol /usr/local/bin
clean:
	rm -f $(OBJS) *.lst *.map *.err spitbol.lex spitbol.tmp spitbol.s errors.s
