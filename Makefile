NAME		:= mp12wav
DESCRIPTION	:= Convert mp1 to wav
COMPANY		:= Deltabeard
COPYRIGHT	:= Copyright (c) 2020 Mahyar Koshkouei
LICENSE_SPDX	:= 0BSD

# Default compiler options for GCC and Clang
CC	:= cc
OBJEXT	:= o
RM	:= rm -f
EXEOUT	:= -o
CFLAGS	:= -std=c99 -pedantic -Wall -Wextra -O2 -g3
EXE	:= $(NAME)
LICENSE := $(COPYRIGHT); Released under the $(LICENSE_SPDX) License.
GIT_VER := $(shell git describe --dirty --always --tags --long)

# Default configurable build options
EXAMPLE_OPTION := 0

define help_txt
C template project.
Available options and their descriptions when enabled:
  EXAMPLE_OPTION=$(EXAMPLE_OPTION)
          Enables debug symbols and reduces optimisation.

$(LICENSE)
endef

ifeq ($(EXAMPLE_OPTION),1)
	$(info EXAMPLE_OPTION was enabled!)
	# Add relevant defines to CFLAGS. Example:
	#   override CFLAGS += -DEXAMPLE_OPTION
	# "-D" is compatible with GCC, Clang, and MSVC.
endif

SRCS := $(wildcard src/*.c)
OBJS := $(SRCS:.c=.$(OBJEXT))

# File extension ".exe" is automatically appended on MinGW and MSVC builds, even
# if we don't ask for it.
ifeq ($(OS),Windows_NT)
	EXE := $(NAME).exe
endif

ifeq ($(GIT_VER),)
	GIT_VER := LOCAL
endif

override CFLAGS += -Iinc

all: $(NAME)
$(NAME): $(OBJS) $(RES)
	$(CC) $(CFLAGS) $(EXEOUT)$@ $^ $(LDFLAGS)

%.obj: %.c
	$(CC) $(CFLAGS) /Fo$@ /c /TC $^

%.res: %.rc
	rc /nologo /DCOMPANY="$(COMPANY)" /DDESCRIPTION="$(DESCRIPTION)" \
		/DLICENSE="$(LICENSE)" /DGIT_VER="$(GIT_VER)" \
		/DNAME="$(NAME)" /DICON_FILE="$(ICON_FILE)" $^

clean:
	$(RM) *.$(OBJEXT) $(EXE) $(RES)

help:
	@cd
	$(info $(help_txt))
