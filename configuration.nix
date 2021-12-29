{ config, lib, pkgs, ... }: {

	imports = [ ./octoprint ];

	fileSystems."/" = lib.mkDefault {
		label = lib.mkDefault "NIXOS_SD";
		fsType = lib.mkDefault "ext4";
		options = lib.mkDefault [ "rw" "noatime" "defaults" ];
	};
	swapDevices = lib.mkDefault [
		{ device = "/dev/disk/by-label/SWAP"; }
	];
	powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
	boot = {
		kernelPackages = pkgs.linuxPackages_rpi4;
		kernelParams = [
			"8250.nr_uarts=1"
			"console=tty1"
			"console=ttyAMA0,115200"
		];
		tmpOnTmpfs = true;
		loader = {
			grub.enable = false;
			generic-extlinux-compatible.enable = true;
			raspberryPi = {
				enable = true;
				version = 4;
			};
		};
	};

	documentation.enable = false;
	time.timeZone = "Australia/Melbourne";
	i18n.defaultLocale = "en_AU.UTF-8";
	services.xserver = {
		layout = "dvorak";
		xkbOptions = "caps:swapescape";
	};
	console = {
		font = "Lat2-Terminus16";
		useXkbConfig = true;
	};
	programs.zsh.enable = true;
	environment = {
		systemPackages = with pkgs; [
			vim
		];
		variables = {
			EDITOR = "vim";
		};
		shellAliases = {
			ll = "ls -alh";
			ns = "function _ns() { nix-shell -p \"$1\" --run \"$*\"; }; _ns";
		};
	};
	users.mutableUsers = lib.mkDefault false;
	services.openssh = {
		enable = true;
		startWhenNeeded = true;
		passwordAuthentication = false;
		challengeResponseAuthentication = false;
	};
	networking.useDHCP = lib.mkDefault false;
	nix = {
		autoOptimiseStore = true;
		gc = {
			automatic = true;
			options = "--delete-older-than 14d";
		};
	};

	users.users.me = {
		name = "dominic";
		isNormalUser = true;
		extraGroups = [ "wheel" ];
		openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzGL9KhRd2lKNuTZq1cK+4bkioGBkaMetfbzf/uuqTj dominic@enki"
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE5rpMMLWs8oQXYtg9wXuvsb70O0vtPX+KEK1KiJAZVO dominic@ninhursag"
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJvjSAq4gAGNM7Jp12rdTZ9uVTVd9iD2anhzRmFLmOoK dominic@macbook"
		];
		packages = with pkgs; [
			tree
			git
			bind
			curl
		];
	};

	users.users.root.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzGL9KhRd2lKNuTZq1cK+4bkioGBkaMetfbzf/uuqTj dominic@enki"
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE5rpMMLWs8oQXYtg9wXuvsb70O0vtPX+KEK1KiJAZVO dominic@ninhursag"
	];

	hardware.enableRedistributableFirmware = true;
	networking = {
		interfaces = {
			eth0.useDHCP = true;
			wlan0.useDHCP = true;
		};
		supplicant.wlan0.configFile.path = "/etc/wpa_supplicant.conf";
	};

	networking = {
		domain = "internal.frogamic.website";
		firewall.allowedTCPPorts = [ 80 443 ];
	};

	services.nginx = {
		enable = true;
		recommendedProxySettings = true;
		virtualHosts."${config.networking.hostName}.${config.networking.domain}".locations."/" = {
			return = "302 http://${config.networking.hostName}.${config.networking.domain}/octoprint$request_uri";
		};
	};

	system.stateVersion = "21.05"; # Did you read the comment?
}
