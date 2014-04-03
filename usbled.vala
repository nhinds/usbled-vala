
namespace USBLEDHandler {
	errordomain InvalidDevice {
		NO_DEVICES,
		MISSING_DEVICE,
		BAD_DEVICE
	}

	private static const string SYS_USBLED_PATH = "/sys/bus/usb/drivers/usbled";
	private static File SYS_USBLED;

	private class RGBLed {
		private static const string RED = "red";
		private static const string GREEN = "green";
		private static const string BLUE = "blue";

		private File red;
		private File green;
		private File blue;

		public RGBLed(string device) throws InvalidDevice {
			if (!SYS_USBLED.query_exists()) {
				throw new InvalidDevice.NO_DEVICES(@"$SYS_USBLED_PATH does not exist, no usbled devices present");
			}
			var device_file = SYS_USBLED.get_child(device);
			// Check the device we were given is under the usbled driver (not ../../ or an absolute path)
			if (!SYS_USBLED.equal(device_file.get_parent())) {
				throw new InvalidDevice.BAD_DEVICE(@"Device $device is not a child of $SYS_USBLED_PATH");
			}
			// Check the device exists
			FileInfo device_info;
			try {
				device_info  = device_file.query_info(FileAttribute.STANDARD_IS_SYMLINK, FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
			} catch (Error e) {
				if (e is IOError.NOT_FOUND) {
					throw new InvalidDevice.MISSING_DEVICE(@"Device $device does not exist");
				} else {
					throw new InvalidDevice.BAD_DEVICE(@"Error querying information about device $device: $(e.message)");
				}
			}
			// Check the device is a symbolic link to the real sys location
			if (!device_info.get_is_symlink()) {
				throw new InvalidDevice.BAD_DEVICE(@"Device $device is not a symbolic link to a USB device");
			}
			// Check the device has the required red/green/blue files
			this.red = device_file.get_child(RED);
			this.green = device_file.get_child(GREEN);
			this.blue = device_file.get_child(BLUE);
			if (!this.red.query_exists() || !this.blue.query_exists() || !this.green.query_exists()) {
				throw new InvalidDevice.BAD_DEVICE(@"Device $device does not have the required files $RED, $GREEN and $BLUE");
			}
		}

		public void set_colour(int red, int green, int blue) throws Error {
			write(this.red, red);
			write(this.green, green);
			write(this.blue, blue);
		}

		private static void write(File file, int data) throws Error {
			var stream = file.open_readwrite();
			var output = new DataOutputStream(stream.output_stream);
			output.put_string(data.to_string());
		}
	}

	private static void list_devices() throws Error {
		if (!SYS_USBLED.query_exists()) {
			return;
		}
		
		var children = SYS_USBLED.enumerate_children(FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NONE);
		FileInfo? child;
		while ((child = children.next_file()) != null) {
			try {
				new RGBLed(child.get_name());
				print(@"$(child.get_name())\n");
			} catch (InvalidDevice e) {
				// Ignore invalid devices
			}
		}
	}

	public static int main(string [] argv) {
		SYS_USBLED = File.new_for_path(SYS_USBLED_PATH);
		if (argv.length == 2 && argv[1] == "-l") {
			try {
				list_devices();
				return 0;
			} catch (Error e) {
				stderr.puts(e.message + "\n");
				return 2;
			}
		}

		if (argv.length < 5) {
			print("Usage:\n");
			print(@"\t$(argv[0]) <device> <red> <green> <blue>\n");
			print(@"\t$(argv[0]) -l\n");
			return 1;
		}

		try {
			new RGBLed(argv[1]).set_colour(int.parse(argv[2]), int.parse(argv[3]), int.parse(argv[4]));
			return 0;
		} catch (InvalidDevice e) {
			stderr.puts(e.message + "\n");
			return 2;
		} catch (Error e) {
			stderr.puts(e.message + "\n");
			return 3;
		}
	}
}