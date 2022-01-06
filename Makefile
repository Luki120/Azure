TARGET := iphone:clang:latest:latest
INSTALL_TARGET_PROCESSES = Azure

APPLICATION_NAME = Azure

Azure_FILES = Cells/AzurePinCodeCell.m Core/AZAppDelegate.m Core/main.m Controllers/AzureTableVC.m Controllers/AzureRootVC.m Controllers/LinksVC.swift Controllers/NotAuthenticatedVC.m Controllers/PinCodeVC.m Controllers/SettingsVC.swift Managers/TOTPManager.m TOTPGenerator/MF_Base32Additions.m TOTPGenerator/OTPGenerator.m TOTPGenerator/TOTPGenerator.m Views/LinksView.swift
Azure_CFLAGS = -fobjc-arc
Azure_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk
