PKGS = --pkg gio-2.0
VALAC = valac

all: usbled

usbled: usbled.vala
	$(VALAC) $(PKGS) -o usbled usbled.vala

install:
	install -o root -m 4755 usbled /usr/local/bin

uninstall:
	rm /usr/local/bin/usbled

clean:
	rm -f usbled