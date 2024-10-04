# TODO: move this into the main makefile

GHDL=ghdl
#GHDL=/mnt/n7fs/ens/tp_guivarch/opt2023/ghdl-2.0.0/bin/ghdl
GHDLFLAGS=-fsynopsys --std=08
MODULES=\
	compteur.o \
	test_compteur.o \
	test_compteur
    # ../diviseurClk/diviseurClk.o \

TIME=2us
PLOT=output

all: test

test: $(MODULES)
	$(GHDL) -r $(GHDLFLAGS) test_compteur \
	--stop-time=${TIME} \
	--vcd=${PLOT}.vcd
       
# Binary depends on the object file
%: %.o
	$(GHDL) -e $(GHDLFLAGS) $@

# Object file depends on source
%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

clean:
	echo "Cleaning up..."
	$(GHDL) --remove $(GHDLFLAGS)
	rm -f ${PLOT}.vcd
