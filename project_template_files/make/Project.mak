
# Set the default target (before any external file import)
default_target: all

ECHO      = 0
ECHOON    = $(ECHO:0=@)
ECHO_FLAG = $(ECHOON:1=)

ARCH      = linux64
CONFIG    = Debug

ifeq ($(ARCH), linux64)
TOOLS_PATH =
else
TOOLS_PATH = /opt/cross-pi-gcc/bin/arm-linux-gnueabihf-
endif

MAKE = make
CC   = $(TOOLS_PATH)gcc
CPP  = $(TOOLS_PATH)g++
LD   = $(TOOLS_PATH)g++
AR   = $(TOOLS_PATH)ar

OBJ_DIR    = $(ROOT_DIR)/arch/$(ARCH)/obj/$(CONFIG)
BIN_DIR    = $(ROOT_DIR)/arch/$(ARCH)/bin/$(CONFIG)
CC_INCLUDE = $(PROJ_INC_DIR:%=-I%)
CC_DEFINES = $(PROJ_MACROS:%=-D%)
CFLAGS     = -ansi -pedantic-errors -Wall -Wextra -fPIC $(CFG_FLAGS) $(PROJ_CFLAGS)
CPPFLAGS   = -ansi -pedantic-errors -Wall -Wextra -fPIC -Wold-style-cast $(CFG_FLAGS) $(PROJ_CPPFLAGS)
LDFLAGS    = -L$(BIN_DIR) $(PROJ_LDFLAGS)

ifeq ($(CONFIG), Debug)
CFG_FLAGS = -g -DDEBUG -UNDEBUG
else
CFG_FLAGS = -g -O2 -UDEBUG -DNDEBUG
endif

ifeq ($(suffix $(PROJ_OUT)), $(filter $(suffix $(PROJ_OUT)), .out .so))
# executables (.out) or shared objects (.so)
PROJ_OBJS_C   = $(filter %.o, $(PROJ_SRCS:%.c=$(OBJ_DIR)/%.o))
PROJ_OBJS_CPP = $(filter %.obj, $(PROJ_SRCS:%.cpp=$(OBJ_DIR)/%.obj))
PROJ_OBJS     =  $(PROJ_OBJS_C) $(PROJ_OBJS_CPP)
else
# archive (.a)
LIB_OBJS = $(filter-out $(wildcard $(OBJ_DIR)/*_test.o), $(wildcard $(OBJ_DIR)/*.o))
endif

PROJ_OTHER_OBJS = $(PROJ_ADD_OBJS:%=$(OBJ_DIR)/%)

ifneq ($(MAKECMDGOALS), clean)
-include $(PROJ_OBJS_C:.o=.d) $(PROJ_OBJS_CPP:.obj=.d)
endif

.DELETE_ON_ERROR:

$(OBJ_DIR)/%.d $(OBJ_DIR)/%.o: %.c
	@echo Creating dependencies and object files for $<
	$(ECHO_FLAG)$(CC) $(CFLAGS) $(CC_DEFINES) $(CC_INCLUDE) -MMD -c -o $(@D)/$(*F).o $<

$(OBJ_DIR)/%.d $(OBJ_DIR)/%.obj: %.cpp
	@echo Creating dependencies and object files for $<
	$(ECHO_FLAG)$(CPP) $(CPPFLAGS) $(CC_DEFINES) $(CC_INCLUDE) -MMD -c -o $(@D)/$(*F).obj $<

##################################################################
#  Rules  --------------------------------------------------------
##################################################################

all: $(PROJ_DEPENDS) $(BIN_DIR)/$(PROJ_OUT)
	@echo All targets made

$(BIN_DIR)/$(basename $(PROJ_OUT)).out: $(PROJ_OBJS) $(PROJ_OTHER_OBJS)
	@echo Creating application $(@F)
	$(ECHO_FLAG)$(LD) $(PROJ_OBJS) $(PROJ_OTHER_OBJS) -Wl,-rpath="\$$ORIGIN" $(LDFLAGS) $(PROJ_LIBS:%=-l%) -o $@
	$(ECHO_FLAG)ln -s -f $(@) $(basename $(PROJ_OUT)).$(CONFIG).out

$(BIN_DIR)/$(basename $(PROJ_OUT)).so: $(PROJ_OBJS) $(PROJ_OTHER_OBJS)
	@echo Creating shared object $(@F)
	$(ECHO_FLAG)$(LD) $(PROJ_OBJS) $(PROJ_OTHER_OBJS) -shared $(LDFLAGS) $(PROJ_LIBS:%=-l%) -o $@

$(BIN_DIR)/$(basename $(PROJ_OUT)).a: $(LIB_OBJS)
	@echo Creating library $(@F)
	$(ECHO_FLAG)$(AR) -crs $(@) $(LIB_OBJS)

.PHONY: noapp
 $(BIN_DIR)/noapp: $(PROJ_OBJS) $(PROJ_OTHER_OBJS)
	@echo Object files created successfuly

clean: $(PROJ_DEPENDS)
	@echo Deleting dependencies and object files
	$(ECHO_FLAG)mkdir -p $(OBJ_DIR)
	$(ECHO_FLAG)mkdir -p $(BIN_DIR)
	$(ECHO_FLAG)rm -f $(PROJ_OBJS) $(PROJ_OBJS_C:.o=.d) $(PROJ_OBJS_CPP:.obj=.d) $(PROJ_OUT:%=$(BIN_DIR)/%)
	$(ECHO_FLAG)rm -f $(basename $(PROJ_OUT)).$(CONFIG).out

.PHONY: $(PROJ_DEPENDS)
$(PROJ_DEPENDS):
	$(ECHO_FLAG)$(MAKE) -C $(dir $@) -f $(notdir $@) $(MAKECMDGOALS) CONFIG=$(CONFIG) ECHO=$(ECHO)
