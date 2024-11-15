# GHDL=/mnt/n7fs/ens/tp_guivarch/opt2023/ghdl-2.0.0/bin/ghdl
GHDL=ghdl
GHDLFLAGS=-fsynopsys --std=08
MODULES=\
    er_1octet.o \
	MasterOpl.o \
	SlaveOpl.o \
	TestOpl.o \
	TestOpl

TIME=5000ns
PLOT=output

all: test clean

test: $(MODULES)
	$(GHDL) -r $(GHDLFLAGS) TestOpl \
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
#
#	rm -f ${PLOT}.vcd
