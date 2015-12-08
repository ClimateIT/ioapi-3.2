#.........................................................................
# VERSION "$Id: Makefile.template 244 2015-10-22 18:39:41Z coats $"
#      EDSS/Models-3 I/O API Version 3.2.
#.........................................................................
# COPYRIGHT
#       (C) 1992-2002 MCNC and Carlie J. Coats, Jr., and
#       (C) 2003-2004 by Baron Advanced Meteorological Systems,
#       (C) 2005-2014 Carlie J. Coats, Jr., and
#       (C) 2014-2015 UNC Institute for the Environment
#       Distributed under the GNU Lesser PUBLIC LICENSE version 2.1
#       See file "LGPL.txt" for conditions of use.
#.........................................................................
#  Usage:
#       Either edit this Makefile to un-comment the options you want, or
#       override the options by environment or command-line variables.
#       For example:
#
#    setenv BIN      Linux2_x86_64ifort
#    setenv BASEDIR  /wherever/I-ve/un-tarred/the/code
#    setenv CPLMODE  nocpl
#    make
#
#  or:
#
#    make BIN=Linux2_x86_64pg  CPLMODE=pncf INSTALL=/foo/bar
#    
#.........................................................................
#  Environment/Command-line Variables:
#
#       BIN     machine/OS/compiler/mode type. Shows up as suffix
#               for "$(IODIR)/Makeinclude.$(BIN)" to determine compilation
#               flags, and in $(OBJDIR) and $(INSTALL) to determine
#               binary directories
#
#       INSTALL installation-directory root, used for "make install":
#               "libioapi.a" and the tool executables will be installed
#               in $(INSTALL)/$(BIN)
#
#       LIBINST overrides  $(INSTALL)/$(BIN) for libioapi.a
#
#       BININST overrides  $(INSTALL)/$(BIN) for M3TOOLS executables
#.........................................................................
#  Directories:
#
#       $(BASEDIR)  is the root directory for the I/O API library source,
#                   the M3Tools and M3Test source,the  HTML documentation,
#                   and the (machine/compiler/flag-specific) binary
#                   object/library/executable directories.
#       $(HTMLDIR)  is the web documentation
#       $(IODIR)    is the I/O API library source
#       $(TOOLDIR)  is the "M3TOOLS" source
#       $(OBJDIR)   is the current machine/compiler/flag-specific
#                   build-directory
#       $(INSTALL)  installation-directory root, used for "make install":
#                   "libioapi.a" and the tool executables will be installed
#                   in $(INSTALL)/$(BIN) object/library/executable directory
#.........................................................................
# Note On Library Versions and configuration:
#
#       Environment variable "BIN" specifies library version up to
#       link- and compile-flag compatibility.  Dependecies upon machine,
#       OS, and compiler are found in file "Makeinclude.$(BIN)".
#       Command-line "make BIN=<something>..." overrides environment
#       variable "% setenv BIN <something>" which overrides the
#       make-variable default below.
#
#       IN PARTICULAR, pay attention to the notes for various versions
#       that may be built for Linux x86 with the Portland Group
#       compilers:  see comments in $(IODIR)/include 'MAKEINCLUDE'.Linux2_x86pg
#.........................................................................
# Special Make-targets
#
#       configure:  "Makefile"s, with the definitions indicated below.
#       all:      OBJDIR, FIXDIR, libioapi.a, and executables, with
#                 the current mode.
#       lib:      OBJDIR, FIXDIR, libioapi.a
#       clean:    remove .o's, libioapi.a, and executables from OBJDIR
#       rmexe:    remove executables from OBJDIR
#       relink:   rebuild executables from OBJDIR
#       install:  copy "libioapi.a" and executables to $(INSTDIR)
#       dirs:     make OBJDIR and FIXDIR directories
#       fix:      FIXDIR and extended-fixed-source INCLUDE-files
#       gtar:     GZipped tar-file of the source and docs
#       nametest: test of name-mangling compatibility (requires that
#                 libnetcdff.a be manually placed into $(OBJDIR))
#
######################################################################
#      ----------   Definitions for "make configure"  ------------------
#
#  VERSIONING DEFINITIONS:  the preprocessor definitions in $(IOAPIDEFS)
#  (below) govern I/O API behavior; versions with distinct combinations
#  of these options are NOT library- nor object-compatible and should
#  be built in *distinct*  $(OBJDIR)s:
#
#       Defining IOAPICPL turns on PVM-enabled "coupling mode" and
#       requires "libpvm3.a" for linking.
#
#       Defining IOAPI_PNCF turns on PnetCDF based distributed I/O
#       and requires libpnetcdf.a and libmpi.a for linking; it should
#       be used only with an MPI-based ${BIN} (e.g., Linux2_x86_64ifortmpi)
#
#       Defining IOAPI_NCF4 turns on full netCDF-4 interfaces, including
#       support for INTEGER*8 variables and attributes.  It requires
#       extra libraries for linking, which can be found by running the
#       commands  "nf-config --flibs" and "nc-config --libs"
#
#       Defining IOAPI_NO_STDOUT suppresses WRITEs to the screen in
#       routines INIT3(), M3MSG2(), M3MESG(), M3PARAG(), and M3ABORT().
#       This also helps control the "double-printed-message" behavior
#       caused by recent SGI compilers.
#
#       Defining IO_360 creates the 360-day "global climate" version
#       of the library.
#
#       Defining BIN3_DEBUG turns on trace-messages for native-binary
#       mode routines.

BIN        = Linux2_x86_64          # fall-back to gcc/gfortran
BASEDIR    = ${cwd}                 # fall-back to source under this current directory
INSTALL    = ${HOME}                # fallback to installation directly under ${HOME}
LIBINST    = $(INSTALL)/$(BIN)      # fall-back for installation of library
BININST    = $(INSTALL)/$(BIN)      # fall-back for installation of m3tools executables
CPLMODE    = nocpl
IOAPIDEFS  = 
PVMINCL    = $(PVM_ROOT)/conf/$(PVM_ARCH).def
NCFLIBS    = -lnetcdf -lnetcdff     #  assumes netCDF-4-style separate libs

#               ****   Variants   ****
#
# BASEDIR    = ${HOME}/ioapi-3.2    # fall-back to versioned source under this directory
#
# CPLMODE   = cpl                   #  turn on PVM coupling mode
# IOAPIDEFS = "-DIOAPICPL"
#
# CPLMODE   = pncf                  #  turn on PnetCDF distributed-file mode
# NCFLIBS   = -lpnetcdf -lnetcdf -lnetcdff
# IOAPIDEFS = "-DIOAPI_PNCF"
# 
# NCFLIBS   = -lnetcdf             #  Assumes netcdf-3-style unified libs
# IOAPIDEFS = "-DIOAPI_PNCF"
# 
# NCFLIBS   = -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz  # netcdf-4 with HDF but not DAP
# IOAPIDEFS = "-DIOAPI_NCF4"
# 
# NCFLIBS   = -lpnetcdf -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz  # PnetCDF+netcdf-4 with HDF but not DAP
# IOAPIDEFS = "-DIOAPI_PNCF -DIOAPI_NCF4"
# 
# NCFLIBS   = "-lnetcdff -lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lmfhdf -ldf -ljpeg -lm -lz -lcurl -lsz"   # all-out netcdf-4
# 
# NCFLIBS   = "`nf-config --flibs` `nc-config --libs`"   # general-case netcdf-4 with NetCDF "bin" in ${path}
# 
# INSTALL   = <installation base-directory> -- what GNU "configure" calls "--prefix=..."
# LIBINST   = $(INSTALL)/lib
# BININST   = $(INSTALL)/bin

#      ----------  Edit-command used by "make configure"  to customize the "*/Makefile*"

SEDCMD = \
-e 's|IOAPI_BASE|$(BASEDIR)|' \
-e 's|LIBINSTALL|$(LIBINST)|' \
-e 's|BININSTALL|$(BININST)|' \
-e 's|IOAPI_DEFS|$(IOAPIDEFS)|' \
-e 's|NCFLIBS|$(NCFLIBS)|' \
-e 's|MAKEINCLUDE|include $(IODIR)/Makeinclude.$(BIN)|' \
-e 's|PVMINCLUDE|include  $(PVMINCL)|'


#      ----------   I/O API Build System directory definitions  --------

VERSION = 3.2-${CPLMODE}

IODIR      = $(BASEDIR)/ioapi
FIXDIR     = $(IODIR)/fixed_src
HTMLDIR    = $(BASEDIR)/HTML
TOOLDIR    = $(BASEDIR)/m3tools
OBJDIR     = $(BASEDIR)/$(BIN)


#      ----------------------   TOP-LEVEL TARGETS:   ------------------
#
all:  dirs fix configure
	(cd $(IODIR)   ; make all)
	(cd $(TOOLDIR) ; make all)
	(cd $(RTTDIR)  ; make all)

configure:
	(cd $(IODIR)   ;  sed $(SEDCMD) < Makefile.$(CPLMODE).sed > Makefile )
	(cd $(TOOLDIR) ;  sed $(SEDCMD) < Makefile.$(CPLMODE).sed > Makefile )
	(cd $(TESTDIR) ;  sed $(SEDCMD) < Makefile.$(CPLMODE).sed > Makefile )

bins:  dirs
	(cd $(IODIR)   ; make bins)
	(cd $(TOOLDIR) ; make bins)
	(cd $(RTTDIR)  ; make bins)

clean:
	(cd $(IODIR)   ; make -i clean)
	(cd $(TOOLDIR) ; make -i clean)

relink:
	(cd $(TOOLDIR) ; make -i rmexe; make)

install: $(LIBINST) $(BININST)
	echo "Installing I/O API and M3TOOLS in $(LIBINST) and $(BININST)"
	(cd $(IODIR)   ; make INSTDIR=${LIBINST} install)
	(cd $(TOOLDIR) ; make INSTDIR=${BININST} install)

dirs: $(OBJDIR) $(FIXDIR)

fix:
	(cd $(IODIR)   ; make fixed_src)

gtar:
	cd $(BASEDIR); date > VERSION.txt; \
gtar cvfz ioapi-$(VERSION).tar.gz --dereference -X $(BASEDIR)/exclude \
Makefile*  VERSION.txt exclude ioapi HTML m3tools

lib:  dirs
	(cd $(IODIR)   ; make all)

nametest:  lib $(OBJDIR)/libnetcdff.a
	(cd $(IODIR)   ; make nametest)

$(FIXDIR):
	mkdir -p $(FIXDIR)

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(LIBINST): $(INSTALL)
	cd $(INSTALL); mkdir -p $(LIBINST)

$(BININST): $(INSTALL)
	cd $(INSTALL); mkdir -p $(BININST)

