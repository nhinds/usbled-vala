USB LED Vala Control Program
========

This is a simple program written in Vala to control devices which use the
usbled linux kernel module.

The program is expected to be installed with the setuid bit set so that
regular users can access the USB LED devices; the device files are owned
by root so regular users cannot normally write data to them.

Usage
--------
`usbled -l` lists available USB devices

`usbled <device> <red> <green> <blue>` sets the RGB values of the USB device

Requirements
--------
* Vala 0.20 (to compile)
* USB device which is handled by the usbled driver

Building
--------
`make`

Installing
--------
`sudo make install`
