PKGS = --pkg gio-2.0
VALAC = valac

all: usbled

usbled: usbled.vala
	$(VALAC) $(PKGS) -o usbled usbled.vala

install:
	install -o root -m 4755 usbled /usr/local/bin
	install -T usbled.bash.completion.sh /etc/bash_completion.d/usbled

uninstall:
	rm -f /usr/local/bin/usbled
	rm -f /etc/bash_completion.d/usbled

clean:
	rm -f usbled
