PREFIX ?= /usr
QMLDIR ?= $(PREFIX)/lib/qt6/qml
DEST = $(DESTDIR)$(QMLDIR)/Twilight/Settings

install:
	install -d $(DEST)
	cp -r Twilight/Settings/. $(DEST)

uninstall:
	rm -rf $(DEST)

.PHONY: install uninstall
