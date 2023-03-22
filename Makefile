ARCHS = arm64
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Azure
APPLICATION_NAME = Azure

rwildcard = $(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

Azure_FILES = $(call rwildcard, Sources, *.swift)
Azure_CFLAGS = -fobjc-arc
Azure_FRAMEWORKS = UIKit CoreGraphics
Azure_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk
