## Makefile for rDock building. by ggutierrez
##	basic usage
##		make
##		make test (optional)
##		make install
##	resulting in a build/RELEASE directory with library, binaries and data
##	folders.

## for detailed information on how to use this Makefile, please read the
## Advanced Build Instructions section in README.md file


MODE		:=	$(if $(MODE),$(MODE),RELEASE)
PREFIX		:=	$(if $(PREFIX),$(PREFIX),./build/$(MODE))
CXX			:=	$(if $(CXX),$(CXX),g++)
LINKER		:=	$(if $(LINKER),$(LINKER),g++)
DAYLIGHT	:=	$(if $(DAYLIGHT),$(DAYLIGHT),NO)

RBT_ROOT := $(shell pwd)

CXX_COMPILE_RELEASE_FLAGS	:= -O3 -ffast-math
CXX_COMPILE_DEBUG_FLAGS		:= -g

CXX_RELEASE_DEFINES			:= -D_NDEBUG
CXX_DEBUG_DEFINES			:= -D_DEBUG

CXX_WARNINGS_ON				:= -Wall -W -Wextra
CXX_WARNINGS_OFF			:= -Wno-deprecated

## for now, I'll keep warnings off
CXX_WARNINGS		:= $(CXX_WARNINGS_OFF)
CXX_COMPILE_FLAGS	:= $(CXX_COMPILE_$(MODE)_FLAGS) -fPIC -pipe -m64 -std=c++03 -fpermissive $(CXX_COMPILE_FLAGS) $(CXX_$(MODE)_DEFINES) $(CXX_WARNINGS)

INCDIR				+= -I./include -I./include/GP -I./import/simplex/include -I./import/tnt/include
LIBDIR				:= $(LIBDIR)
LIBS_DAYLIGHT_YES	:= -ldt_smarts -ldt_smiles
LIBS				:= -lm
LIBS				:= $(LIBS) $(LIBS_DAYLIGHT_$(DAYLIGHT))

SIMPLEXSRC			:= $(shell find import/simplex/src -type f -name '*.cxx')
SIMPLEXOBJ			:= $(subst src/,,$(subst import/, obj/, $(SIMPLEXSRC:.cxx=.o)))

LIBSRC				:= $(shell find src/lib -type f -name '*.cxx')
LIBOBJ				:= $(subst src/, obj/, $(LIBSRC:.cxx=.o))

GPSRC				:= $(shell find src/GP -type f -name 'Rbt*.cxx')
GPOBJ				:= $(subst src/, obj/, $(GPSRC:.cxx=.o))

DLSRC_YES			:= $(shell find src/daylight -type f -name '*.cxx')
DLOBJ				:= $(subst src/, obj/, $(DLSRC_$(DAYLIGHT):.cxx=.o))

EXESRC_DAYLIGHT_YES	:= $(shell find src/exe -type f -name 'rb*.cxx')
EXESRC_DAYLIGHT_NO	:= $(shell find src/exe -type f \( -name 'rb*.cxx' ! -name 'rbtether.cxx' ! -name 'rbconvgrid.cxx' \))
EXEBIN				= $(subst src/exe/, bin/, $(EXESRC_DAYLIGHT_$(DAYLIGHT):.cxx=))

TESTPRM				= $(shell find test/RBT_HOME/*.prm)
TEST_AS				= $(TESTPRM:.prm=.as)

export LD_LIBRARY_PATH =./lib:$$LD_LIBRARY_PATH
export RBT_HOME	= ./test/RBT_HOME

.PHONY: build_lib build_exes build_test build clean veryclean rebuild test install

###############################
## Phony targets definitions ##
###############################
build:
	$(MAKE) build_lib
	$(MAKE) build_exes

build_lib: lib/libRbt.so

build_exes: build_lib
	$(MAKE) $(EXEBIN)

build_test: build_exes
	$(CXX) $(CXX_COMPILE_FLAGS) -L./lib $(INCDIR) -I./test ./test/*.cxx -lRbt -ldl -lcppunit -o ./test/unit_test

clean:
	rm -rf obj

clean_test:
	rm -rf test/unit_test $(TEST_AS) restart.sd test/RBT_HOME/1YET_test_out.*

veryclean:
	$(MAKE) clean
	$(MAKE) clean_test
	rm -rf lib/libRbt.so
	rm -rf $(EXEBIN)

rebuild:
	$(MAKE) veryclean
	$(MAKE) build

test: build_test
	$(MAKE) $(TEST_AS)
	@echo "Running rDock unit tests..."
	./test/unit_test
	$(RBT_ROOT)/bin/rbdock -r1YET_test.prm -i ./test/RBT_HOME/1YET_c.sd -p dock.prm -n 1 -s 48151623 -o ./test/RBT_HOME/1YET_test_out > ./test/RBT_HOME/1YET_test_out.log
	python ./test/RBT_HOME/check_test.py ./test/RBT_HOME/1YET_reference_out.sd ./test/RBT_HOME/1YET_test_out.sd

install:
	mkdir -p $(PREFIX)
	cp -r bin lib data $(PREFIX)

################################
## cavity mapping for testing ##
################################
test/RBT_HOME/%.as:	test/RBT_HOME/%.prm
	@echo "Cavity mapping of $<"
	$(RBT_ROOT)/bin/rbcavity -r$< -was

##############################
## linking of libRbt libary ##
##############################
lib/libRbt.so: $(LIBOBJ) $(SIMPLEXOBJ) $(GPOBJ) $(DLOBJ)
	mkdir -p lib
	$(CXX) -shared $(LIBDIR) $^ -o lib/libRbt.so $(LIBS)

#############################################
## compilation of object files for library ##
#############################################
obj/lib/%.o : src/lib/%.cxx
	mkdir -p obj/lib
	$(CXX) $(CXX_COMPILE_FLAGS) $(INCDIR) -c -o $@ $<

obj/GP/%.o : src/GP/%.cxx
	mkdir -p obj/GP
	$(CXX) $(CXX_COMPILE_FLAGS) $(INCDIR) -c -o $@ $<

obj/daylight/%.o : src/daylight/%.cxx
	mkdir -p obj/daylight
	$(CXX) $(CXX_COMPILE_FLAGS) $(INCDIR) -c -o $@ $<

obj/simplex/%.o : import/simplex/src/%.cxx
	mkdir -p obj/simplex
	$(CXX) $(CXX_COMPILE_FLAGS) $(INCDIR) -c -o $@ $<

########################################
## compilation of executable binaries ##
########################################
bin/% : src/exe/%.cxx
	mkdir -p bin
	$(CXX) $(CXX_COMPILE_FLAGS) $(INCDIR) $(LIBDIR) -L./lib $< -o $@ $(LIBS) -lRbt -lpopt
