TARGET := iphone:clang:latest:latest
INSTALL_TARGET_PROCESSES = Azure
APPLICATION_NAME = Azure

Azure_FILES = $(wildcard Sources/Categories/*.m) $(wildcard Sources/Cells/*.m) $(wildcard Sources/Controllers/Core/*.m) $(wildcard Sources/Controllers/Swift/*.swift) $(wildcard Sources/Core/*.m) $(wildcard Sources/Libraries/*.m) $(wildcard Sources/Managers/*.m) $(wildcard Sources/Views/*.m) $(wildcard Sources/Views/*.swift)
#Azure_FILES = $(shell find . -name "*.m") $(shell find . -name "*.swift")
Azure_CFLAGS = -fobjc-arc
Azure_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk
