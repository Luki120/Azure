TARGET := iphone:clang:latest:latest
INSTALL_TARGET_PROCESSES = Azure
APPLICATION_NAME = Azure

Azure_FILES = $(shell find * -name "*.m") $(shell find * -name "*.swift")
Azure_CFLAGS = -fobjc-arc
Azure_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk
