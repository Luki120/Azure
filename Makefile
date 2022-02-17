TARGET := iphone:clang:latest:latest
INSTALL_TARGET_PROCESSES = Azure
APPLICATION_NAME = Azure

# Azure_FILES = $(wildcard Categories/*.m) $(wildcard Cells/*.m) $(wildcard Controllers/Core/*.m) $(wildcard Controllers/Swift/*.swift) $(wildcard Core/*.m) $(wildcard Libraries/*.m) $(wildcard Managers/*.m) $(wildcard Views/*.swift)
Azure_FILES = $(shell find . -name "*.m") $(shell find . -name "*.swift")
Azure_CFLAGS = -fobjc-arc
Azure_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk
