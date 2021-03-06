#####################################################################
#
# IOb-SoC Configuration File
#
#####################################################################

#
# PRIMARY PARAMETERS: CAN BE CHANGED BY USERS
#


#FIRMWARE SIZE (LOG2)
FIRM_ADDR_W ?=17

#SRAM SIZE (LOG2)
SRAM_ADDR_W ?=17

#DDR 
USE_DDR ?=0
RUN_DDR ?=0

#CACHE DATA SIZE (LOG2)
CACHE_ADDR_W:=24

#ROM SIZE (LOG2)
BOOTROM_ADDR_W:=12

#PRE-INIT MEMORY WITH PROGRAM AND DATA
INIT_MEM ?=1

#PERIPHERAL LIST
#must match respective submodule or folder name in the submodules directory
#and CORE_NAME in the core.mk file of the submodule
#PERIPHERALS:=UART
PERIPHERALS :=UART TIMER KNN

#
#SIMULATION
#

#default simulator
SIMULATOR ?=icarus
LOCAL_SIM_LIST ?=icarus
VCD ?=0

#set according to SIMULATOR
ifeq ($(SIMULATOR),ncsim)
	SIM_SERVER ?=micro7.lx.it.pt
	SIM_USER ?=user19
endif

#simulator used in testing
SIM_LIST:=icarus ncsim

#
#FPGA BOARD COMPILE & RUN
#

#DDR controller address width
FPGA_DDR_ADDR_W ?=30

#default board
BOARD ?=BASYS3

#Boards for which the FPGA compiler is installed in host
LOCAL_FPGA_LIST=CYCLONEV-GT-DK AES-KU040-DB-G BASYS3

#boards installed host
#LOCAL_BOARD_LIST=CYCLONEV-GT-DK
#LOCAL_BOARD_LIST=AES-KU040-DB-G
#LOCAL_BOARD_LIST=BASYS3

#set according to FPGA board
ifeq ($(BOARD),AES-KU040-DB-G)
#	BOARD_SERVER ?=baba-de-camelo.iobundle.com
	BOARD_SERVER ?=localhost
	BOARD_USER ?=$(USER)
	FPGA_OBJ ?=synth_system.bit
	FPGA_LOG ?=vivado.log
#	FPGA_SERVER ?=pudim-flan.iobundle.com
	FPGA_SERVER ?=localhost
	FPGA_USER ?=$(USER)
else #default; ifeq ($(BOARD),BASYS3)
	BOARD_SERVER ?=localhost
	BOARD_USER ?=$(USER)
	FPGA_OBJ ?=output_files/top_system.sof
	FPGA_LOG ?=output_files/top_system.fit.summary
	FPGA_SERVER ?=localhost
	FPGA_USER ?=$(USER)
endif

#board list for testing
BOARD_LIST ?=CYCLONEV-GT-DK AES-KU040-DB-G 


#
#ROOT DIR ON REMOTE MACHINES
#
REMOTE_ROOT_DIR ?=sandbox/iob-soc

#
# DOCUMENTATION
#

#DOC_TYPE
#must match subdirectory name in directory document

#DOC_TYPE:=presentation
DOC_TYPE ?=pb

#
# ASIC COMPILE (WIP)
#
#ASIC_NODE:=umc130



#############################################################
# DERIVED FROM PRIMARY PARAMETERS: DO NOT CHANGE
#############################################################

ifeq ($(RUN_DDR),1)
	USE_DDR=1
endif

#paths
HW_DIR:=$(ROOT_DIR)/hardware
SIM_DIR=$(HW_DIR)/simulation/$(SIMULATOR)
BOARD_DIR=$(HW_DIR)/fpga/$(BOARD)
ASIC_DIR=$(HW_DIR)/asic/$(ASIC_NODE)

SW_DIR:=$(ROOT_DIR)/software
FIRM_DIR:=$(SW_DIR)/firmware
BOOT_DIR:=$(SW_DIR)/bootloader
CONSOLE_DIR:=$(SW_DIR)/console
PYTHON_DIR:=$(SW_DIR)/python

DOC_DIR:=$(ROOT_DIR)/document/$(DOC_TYPE)
TEX_DIR=$(UART_DIR)/submodules/TEX

#submodule paths
SUBMODULES_DIR:=$(ROOT_DIR)/submodules
SUBMODULES=CPU CACHE $(PERIPHERALS)
$(foreach p, $(SUBMODULES), $(eval $p_DIR:=$(SUBMODULES_DIR)/$p))

#defmacros
DEFINE+=$(defmacro)BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
DEFINE+=$(defmacro)SRAM_ADDR_W=$(SRAM_ADDR_W)
DEFINE+=$(defmacro)FIRM_ADDR_W=$(FIRM_ADDR_W)
DEFINE+=$(defmacro)CACHE_ADDR_W=$(CACHE_ADDR_W)

ifeq ($(USE_DDR),1)
DEFINE+=$(defmacro)USE_DDR
ifeq ($(RUN_DDR),1)
DEFINE+=$(defmacro)RUN_DDR
endif
endif
ifeq ($(INIT_MEM),1)
DEFINE+=$(defmacro)INIT_MEM
endif
DEFINE+=$(defmacro)N_SLAVES=$(N_SLAVES)

#address selection bits
E:=31 #extra memory bit
ifeq ($(USE_DDR),1)
P:=30 #periphs
B:=29 #boot controller
else
P:=31
B:=30
endif

DEFINE+=$(defmacro)E=$E
DEFINE+=$(defmacro)P=$P
DEFINE+=$(defmacro)B=$B

#baud rate
SIM_BAUD:=10000000
HW_BAUD:=115200
BAUD ?= $(HW_BAUD)
DEFINE+=$(defmacro)BAUD=$(BAUD)

#operation frequency
ifeq ($(FREQ),)
DEFINE+=$(defmacro)FREQ=100000000
else
DEFINE+=$(defmacro)FREQ=$(FREQ)
endif

#create periph serial number
N_SLAVES:=0
$(foreach p, $(PERIPHERALS), $(eval $p=$(N_SLAVES)) $(eval N_SLAVES:=$(shell expr $(N_SLAVES) \+ 1)))
$(foreach p, $(PERIPHERALS), $(eval DEFINE+=$(defmacro)$p=$($p)))

#test log
ifneq ($(TEST_LOG),)
LOG=>test.log
endif



#RULES

gen-clean:
	@rm -f *# *~

.PHONY: gen-clean
