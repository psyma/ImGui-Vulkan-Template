#
# Cross Platform Makefile
# Compatible with MSYS2/MINGW, Ubuntu 14.04.1 and Mac OS X
#
# You will need sdl3 (http://www.libsdl.org):
# Linux:
#   apt-get install libsdl3-dev
# Mac OS X:
#   brew install sdl3
# MSYS2:
#   pacman -S mingw-w64-i686-sdl3
#

#CXX = g++
#CXX = clang++

EXE = main
IMGUI_DIR = ./
SOURCES = main.cpp
SOURCES += $(IMGUI_DIR)/imgui.cpp $(IMGUI_DIR)/imgui_demo.cpp $(IMGUI_DIR)/imgui_draw.cpp $(IMGUI_DIR)/imgui_tables.cpp $(IMGUI_DIR)/imgui_widgets.cpp
SOURCES += $(IMGUI_DIR)/backends/imgui_impl_sdl3.cpp $(IMGUI_DIR)/backends/imgui_impl_vulkan.cpp
SOURCES += $(IMGUI_DIR)/src/application.cpp
OBJS = $(addsuffix .o, $(basename $(notdir $(SOURCES))))
UNAME_S := $(shell uname -s)
LINUX_GL_LIBS = -lGL

CXXFLAGS_COMMON = -std=c++11 -I$(IMGUI_DIR) -I$(IMGUI_DIR)/backends
LIBS =

# Build mode (default to release if not specified)
MODE := $(or $(MODE), release)

# Flags for debug and release modes
ifeq ($(MODE), debug) 
	CXXFLAGS = $(CXXFLAGS_COMMON) -g -Wall -Wformat -O0 -DDEBUG
else
	CXXFLAGS = $(CXXFLAGS_COMMON) -O2 -DNDEBUG
endif

##---------------------------------------------------------------------
## OPENGL ES
##---------------------------------------------------------------------

# Uncomment if using OpenGL ES
# CXXFLAGS += -DIMGUI_IMPL_OPENGL_ES2
# LINUX_GL_LIBS = -lGLESv2

##---------------------------------------------------------------------
## BUILD FLAGS PER PLATFORM
##---------------------------------------------------------------------

ifeq ($(UNAME_S), Linux) # LINUX
	ECHO_MESSAGE = "Linux ($(MODE) mode)"
	LIBS += $(LINUX_GL_LIBS) `pkg-config sdl3 vulkan --cflags --libs`
	CXXFLAGS += `pkg-config sdl3 vulkan --cflags --libs`
	CFLAGS = $(CXXFLAGS)
endif

ifeq ($(UNAME_S), Darwin) # APPLE
	ECHO_MESSAGE = "Mac OS X ($(MODE) mode)"
	LIBS += -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo `sdl3-config --libs`
	LIBS += -L/usr/local/lib -L/opt/local/lib
	CXXFLAGS += `sdl3-config --cflags`
	CXXFLAGS += -I/usr/local/include -I/opt/local/include
	CFLAGS = $(CXXFLAGS)
endif

ifeq ($(OS), Windows_NT) # WINDOWS
    ECHO_MESSAGE = "MinGW ($(MODE) mode)"
    LIBS += -lgdi32 -lopengl32 -limm32 `pkg-config --static --libs sdl3`
    CXXFLAGS += `pkg-config --cflags sdl3`
    CFLAGS = $(CXXFLAGS)
endif

##---------------------------------------------------------------------
## BUILD RULES
##---------------------------------------------------------------------

%.o:%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o:$(IMGUI_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o:$(IMGUI_DIR)/backends/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o:$(IMGUI_DIR)/src/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

all: $(EXE)
	@echo Build complete for $(ECHO_MESSAGE)

$(EXE): $(OBJS)
	$(CXX) -o $@ $^ $(CXXFLAGS) $(LIBS)

clean:
	rm -f $(EXE) $(OBJS)
