# # Building Illiterate
#
# We use [GNU Make](http://www.gnu.org/software/make/) to automate
# different parts of the build process.
#
# This is the top level make file, we use it to generate
# the whole Illiterate libraray as well as for running tests
# and automating repetitive tasks.
#


# # Global Variables
#
# The following variables are used commonly throughout the make file.
#

# The library name
NAME = "Bencha"

# The output directory
LIBDIR = ./lib

# The directory containing source code
SRCDIR = ./src


# The directory containing the compiled tests
TESTDIR = ./test

# The detault test reporter
REPORTER = "spec"

# The current time
DATE = $(shell date +%I:%M%p)

# A nice green tick mark, used to indicate success
TICK = \033[32m✔\033[39m

# A nasty red cross, used to indicate failure
CROSS = \033[31m✘\033[39m


# # Build the application
# Runs the whole build process
# and runs tests
build: compile test
	@echo "\n  $(TICK) Done at $(DATE)."


# # Compile All
# Compiles all the source code
compile:
	@coffee \
		--compile \
		--output lib \
		src
	@echo "  $(TICK) Compiled ${NAME} Files."





# # Run Unit Tests
test:
	@mocha \
		--compilers coffee:coffee-script \
		$(TESTDIR)/index.coffee \
		--reporter $(REPORTER)


.PHONY: test
