include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ChanEliteFix
ChanEliteFix_FILES = Tweak.x

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Chan"
