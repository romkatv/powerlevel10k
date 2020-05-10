APPNAME ?= gitstatusd
OBJDIR ?= obj

CXX ?= g++

VERSION ?= $(shell . ./build.info && printf "%s" "$$gitstatus_version")

# Note: -fsized-deallocation is not used to avoid binary compatibility issues on macOS.
#
# Sized delete is implemented as __ZdlPvm in /usr/lib/libc++.1.dylib but this symbol is
# missing in macOS prior to 10.13.
CXXFLAGS += -std=c++14 -funsigned-char -O3 -DNDEBUG -DGITSTATUS_VERSION=$(VERSION) -Wall -Werror # -g -fsanitize=thread
LDFLAGS += -pthread # -fsanitize=thread
LDLIBS += -lgit2 # -lprofiler -lunwind

SRCS := $(shell find src -name "*.cc")
OBJS := $(patsubst src/%.cc, $(OBJDIR)/%.o, $(SRCS))

all: $(APPNAME)

$(APPNAME): usrbin/$(APPNAME)

usrbin/$(APPNAME): $(OBJS)
	$(CXX) $(OBJS) $(LDFLAGS) $(LDLIBS) -o $@

$(OBJDIR):
	mkdir -p -- $(OBJDIR)

$(OBJDIR)/%.o: src/%.cc Makefile build.info | $(OBJDIR)
	$(CXX) $(CXXFLAGS) -MM -MT $@ src/$*.cc >$(OBJDIR)/$*.dep
	$(CXX) $(CXXFLAGS) -Wall -c -o $@ src/$*.cc

clean:
	rm -rf -- $(OBJDIR)

-include $(OBJS:.o=.dep)
