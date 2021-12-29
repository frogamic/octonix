{ config, lib, pkgs, ... }: let
	sudo = "/run/wrappers/bin/sudo";
	printer = {
		name = "ender3v2";
		usbVendor = "0483";
		usbProduct = "5740";
	};
in {
	imports = [
		(import ./octoprint.nix {inherit sudo printer;})
	];

	# Give the printer a consistent device
	services.udev.extraRules = with printer; lib.concatStringsSep ", " [
		"SUBSYSTEM==\"tty\""
		"ATTRS{idVendor}==\"${usbVendor}\""
		"ATTRS{idProduct}==\"${usbProduct}\""
		"SYMLINK+=\"${name}\""
		"OWNER=\"${name}\""
		"GROUP=\"${name}\""
		"MODE=\"0660\""
	];

	fileSystems."/mnt/${printer.name}" = {
		label = lib.toUpper printer.name;
		fsType = "vfat";
		options = [
			"rw"
			"nofail"
			"noexec"
			"noatime"
			"sync"
			"x-systemd.automount"
			"x-systemd.idle-timeout=10min"
			"gid=${printer.name}"
			"uid=${printer.name}"
			"fmask=0113"
			"dmask=0002"
		];
	};

	users = {
		# Group with access to the printer tty and filesystem
		groups.${printer.name} = {
			members = [ config.users.users.me.name "octoprint" printer.name ];
		};

		# User whos shell is direct gcode to the printer
		users.${printer.name} = {
			isNormalUser = true;
			openssh.authorizedKeys.keys = config.users.users.me.openssh.authorizedKeys.keys;
			shell = with printer; (pkgs.writeShellScriptBin "${name}Shell" ''
				PRINTUSER="$(${sudo} ${pkgs.lsof}/bin/lsof $(readlink -f /dev/${name}) | tail -n1 | head -n1 | cut -f3 -d" ")"
				[ "$PRINTUSER" != "" ] && echo "/dev/${name} is in use by $PRINTUSER" && exit 1
				exec ${pkgs.printrun}/bin/pronsole.py --execute="connect /dev/${name}"
			'').overrideAttrs ( _: {
				passthru.shellPath = "/bin/${name}Shell";
			});
		};
	};

	# Allow octoprint to restart itself and the pi
	security.sudo.extraRules = [{
		users = [ printer.name ];
		commands = [{
			command = "${pkgs.lsof}/bin/lsof /dev/tty*";
			options = [ "NOPASSWD" ];
		}];
	}];
}
