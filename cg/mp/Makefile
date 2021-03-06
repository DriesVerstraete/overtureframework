#
# Main Makefile for cgmp
#
THISPKG := mp

# check for targets that do not need source file dependencies:
NODEP := $(strip $(filter usage doc clean cleano cleanc cleandep,$(MAKECMDGOALS)))

# ============== optional capabilities: use on/off ==============


# sparse solver packages:
usePETSc   := off
ifeq ($(usePETSc),)
usePETSc   := off
useSuperLU := off
endif

# (buildStaticLib is used in the file "make" )
buildStaticLib := off
# ================================================================

include configFile
include $(CONFIGDIR)/make.dirs
include $(CONFIGDIR)/make.$(OS)
include $(CONFIGDIR)/make.rules
include $(CONFIGDIR)/make.options
include make

# List of packages to build
PKGS := src

# include Overture/Oges to get the PETSc solver and Ogmg files
vpath % $(PKGS) $(GUIDIR)/src $(Overture)/Oges $(OvertureCheckout)/oges
VPATH = $(PKGS) $(GUIDIR)/src $(Overture)/Oges $(OvertureCheckout)/oges

SRC_FILES :=
TESTS :=
PKG_INCLUDE := $(foreach p, $(PKGS), $(p)/files)

all: $(BINDIR)cgmp

cgmp: $(BINDIR)cgmp

# make the library
lib_build: $(LIBDIR)libCgmp
	touch lib_build

usage:
	-@echo "usage : "
	-@echo "        % make " $(COPTS) "<all|cgmp|mp>"

config_os:
	-@echo "using configuration for $(OS)"

include $(PKG_INCLUDE)

# This next include defines how to compile the lists:
#  SRC_FILES : list of C++, C, and fortran files that are to be compiled in the default way.
#  CSRCO : list of C++ files that are to be compiled optimized by default
#  FSCRO : list of Fortran files that are to be compiled optimized by default
#  FSRC   : list of Fortran files that are to be compiled without auto-dbl
#  FSCRSO : list of Fortran files that are to be compiled optimized and without auto-dbl
include $(CONFIGDIR)/make.src

# add dependencies for main programs that are not in the previous source file lists
DEP += cgmpMain.d

#* QSRC := $(SRC_FILES)
#*
#* OBJ := $(patsubst %.cc, %.o, $(QSRC))
#* OBJ := $(patsubst %.c, %.o, $(OBJ))
#* OBJ := $(patsubst %.C, %.o, $(OBJ))
#* OBJ := $(patsubst %.f, %.o, $(OBJ))
#* OBJ := $(patsubst %.F, %.o, $(OBJ))
#* DEP := $(patsubst %.o, %.d, $(OBJ))
#* DEP += cgmpMain.d
#*
#* OBJ := $(addprefix $(OBJPREFIX),$(OBJ))
#* DEP := $(addprefix $(DEPPREFIX),$(DEP))

.PHONY: doc cgmp

# here is a list of the different types of object files
LIB_OBJS = $(OBJ) $(OBJCO) $(OBJN) $(OBJO) $(OBJSO)

SHARED_LIBRARY = $(LIBDIR)libCgmp$(SHARED_LIBRARY_EXT)

# make cgmp in the bin dir:
PETSC_FILES_OBJ := $(addprefix $(OBJPREFIX),$(PETSC_FILES))
CGMP_EXTRA_FILES = $(PETSC_FILES_OBJ)

# libCommon:=$(CGBUILDPREFIX)common/lib/libCgCommon.so
libCommon:=$(CGBUILDPREFIX)common/libCgCommon

$(LIBDIR)libCgmp: $(LIB_OBJS) $(CGMP_EXTRA_FILES)
	  $(SHARED_LIBRARY_COMMAND) -o $(SHARED_LIBRARY) $(SHARED_LIBRARY_FLAGS) \
		     $(LIB_OBJS) $(SHARED_LIBRARY_LOAD_LIBS) $(CGMP_EXTRA_FILES) $(LIBS)
	  touch $@

$(BINDIR)cgmp: $(OBJDIR)cgmpMain.o lib_build $(libCommon) SOLVER_LIBS
	-@mkdir -p $(BINDIR)
	$(CXX) $(CXX_FLAGS) -o $@ $(OBJDIR)cgmpMain.o $(LIB_MP)


# Here is the test routine for multi-physics and multi-domain problems
MPOBJ =
mp: $(OBJDIR)mp.o $(MPOBJ)
	-@mkdir $(BINDIR)
	$(CXX) $(CXX_FLAGS) -o $(BINDIR)$@ $(OBJDIR)mp.o  $(MPOBJ) $(LIBS)

# build the library in cg/common
$(libCommon):; @cd ../common; $(MAKE) lib

SOLVER_LIBS:
	@cd ../ad;  $(MAKE) lib_build
	@cd ../asf; $(MAKE) lib_build
	@cd ../cns; $(MAKE) lib_build
	@cd ../ins; $(MAKE) lib_build
	@cd ../sm;  $(MAKE) lib_build

$(DEPDIR)depdep: $(DEPDIR) $(BINDIR) $(LIBDIR) $(OBJDIR)
	touch $(DEPDIR)depdep

$(BINDIR) $(LIBDIR) $(DEPDIR) $(OBJDIR):
	@-mkdir -p $@

doc:
	-@mkdir doc

check:

cleano:
	-rm -f $(OBJPREFIX)*.o
cleandep:
	-rm -f $(OBJPREFIX)*.d
clean:
	-rm -f *~ */*~ $(OBJPREFIX)*.o $(DEPPREFIX)*.d $(LIBDIR)libCgmp* $(BINDIR)cgmp \
  $(BINDIR)mp cmd/*.show* cmd/*.debug cmd/*.check cmd/*.log cmd/*.move cmd/cgmp.cmd

# include dependencies except for a list of commands
ifeq ($(NODEP),)
-include $(DEPDIR)depdep
-include $(DEP)
endif
