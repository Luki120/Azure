TARGET := iphone:clang:latest:latest
INSTALL_TARGET_PROCESSES = Azure

APPLICATION_NAME = Azure

Azure_FILES = $(wildcard Cells/*.m) $(wildcard Controllers/Core/*.m) $(wildcard Controllers/Other/*.m) $(wildcard Controllers/SwiftControllers/*.swift) $(wildcard Core/*.m) $(wildcard Libraries/*.m) $(wildcard Managers/*.m) $(wildcard Views/*.swift)
Azure_CFLAGS = -fobjc-arc
Azure_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk
