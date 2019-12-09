# ultrafast kick-start

make sure git, make, g++, libpopt-dev and libpopt0 are installed, and then:  

```
git clone https://github.com/CBDD/rDock.git
cd rDock
make
PREFIX=/opt/rDock make install
export RBT_ROOT=/opt/rDock
export PATH=$RBT_ROOT/bin:$PATH
export LD_LIBRARY_PATH=$RBT_ROOT/lib:$PATH
```

this will clone the repository, do a basic compilation and set up the env vars to run rDock  
for more detailed instructions in how to install rDock, keep reading.  

# rDock build instructions

## background:

rDock is written in C++ and makes heavy use of the C++ Standard Template Library (STL).
All source code is compiled into a single shared library (libRbt.so).
The executables are light-weight command-line applications linked with libRbt.so.

## prerequisites:

Make sure you have the following packages installed:

- g++		    GNU C++ compiler (or your preferred C++ compiler)
- make
- libpopt		Command-line argument processing (run-time)
- popt-devel	Command-line argument processing (compile-time)

in debian/ubuntu this can be installed by:
```
apt install g++ make libpopt-dev libpopt0
```
Optional (for testing):
- cppunit           C++ unit testing framework (port of JUnit)
- cppunit-devel     C++ unit testing framework (port of JUnit)

cppunit version must be <=1.12 as higher versions are not compatible (yet)


## basic build instructions:

1) build:  
from the base directory (where this file is located) run  
```make build```  
this will compile and link libRbt and rDock binaries.

2) test:  
NOTE: this step is not mandatory, but it is highly recommended.
to compile and run tests, run  
```make test```  
if the tests succeed rDock building has finished successfully.  
otherwise, please check your dependencies and all the previous commands or go to  
Support Section in the webpage (http://rdock.sourceforge.net) to ask for help.

3) install:  
You can either run rDock directly from the build location, or  
install the binaries and data files to a new location.  
in order to install in other location run:  
```export PREFIX=<path to the destination folder>```  
```make install```  
or, for a more compact notation:  
```PREFIX=<path> make install```  
for example:  
```export PREFIX=/opt/rdock```  
```make install```  
will create and populate /opt/rdock/lib /opt/rdock/bin and /opt/rdock/data

4) run rDock:  
rDock requires several environment variables to be set.  
First, RBT_ROOT, which must point to the installation directory  
Second, libRbt.so file must be accessible, either by having it registered  
by ld or by prepending $RBT_ROOT/lib to LD_LIBRARY_PATH variable  
Third and last (this is 'optional'), rDock binaries should be accessible  
from PATH, which can be done by prepending $RBT_ROOT/bin to PATH variable.  
this can be put in any profile file or an environment module:  
```
export RBT_ROOT=/path/to/rDock/installation/
export LD_LIBRARY_PATH=$RBT_ROOT/lib:$LD_LIBRARY_PATH
export PATH=$RBT_ROOT/bin:$PATH
```
## advanced building instructions:
the provided Makefile has a number of options and configurable variables  
and flags to provide some flexibility and adaptability to building and  
testing processes.  

these are the configurable variables, with a brief explanation on how to
use them:

| variable | Description |
|---|---|
| MODE | RELEASE/DEBUG
| | RELEASE mode uses optimization flags, |
| | DEBUG uses profiling flags. Default is RELEASE |
| PREFIX | Path where the build artifacts are to be installed |
| | Default is ./build/<MODE> |
| CXX | C++ Compiler. Default is g++ |
| LINKER | Linker. Default is g++ |
| CXX_COMPILE_FLAGS | Additional compile flags for $CXX |
| | Useful for cross-compilation or other specific |
| | situations. Default is empty |
| CXX_WARNINGS | Additional warning flags for $CXX. Default is empty |
| DAYLIGHT |YES/NO |
| | YES instructs this Makefile to compile daylight |
| | library related functionalities and executables. If |
| | flag is set to YES, one of the next must happen: |
| |     1) daylight libraries and headers must be |
| |         directly accessible for compiler and linker |
| |         (i.e. registered by ld). |
| |     2) daylight libraries and headers location must |
| |         be specified through the INCDIR and LIBDIR |
| |         variables (see below). |
| | Default is NO. |
| INCDIR | Additional paths for compiler to look for headers. |
| | Must be provided in the form of '-I<path>' to be |
| | passed directly to the compiler. Default is empty. |
| LIBDIR | Additional paths for linker to lookk for libraries. |
| | Must be provided in the form of '-L<path>' to be |
| | passed directly to the linker. Defaults is empty. |

these are the available targets in the Makefile, briefly explained:  
| target | description |
|---|---|
| build | Builds the library and binaries. Default target. |
| build_lib | Builds the library. |
| build_exes | Builds the binaries. |
| | It depends on build_lib |
| build_test | Builds the testing framework. |
| | It depends on build_exes. |
| clean | Removes intermediate object files. |
| veryclean | Removes intermediate object files and all the built |
| | artifacts (library, binaries and test framework). |
| rebuild | Same as veryclean + build |
| test | Runs the tests to check the results are correct. |
| | Depends on build_test. Recomended |
| install | Copies bin/ lib/ and data/ to PREFIX folder |
| | (./build/<MODE> by default) |