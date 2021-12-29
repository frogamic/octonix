{ printer, sudo }: { config, lib, pkgs, ... }: let
	mkSudoCmd = cmd: {
		command = lib.removePrefix "${sudo} " (builtins.head (lib.splitString "|" cmd));
		options = [ "NOPASSWD" ];
	};
in {
	imports = [
		(import ./octoplugins.nix {inherit mkSudoCmd printer sudo;})
	];
	services.octoprint = {
		enable = true;
		extraConfig = {
			serial = {
				autoconnect = true;
				baudrate = 250000;
				exclusive = true;
				port = "/dev/${printer.name}";
				additionalPorts = [ "/dev/${printer.name}" ];
				placklistedPorts = [ "/dev/tty*" ];
			};
			server.commands = {
				serverRestartCommand = "${sudo} ${pkgs.systemd}/bin/systemctl restart octoprint.service";
				systemRestartCommand = "${sudo} ${pkgs.systemd}/bin/systemctl reboot";
				systemShutdownCommand = "${sudo} ${pkgs.systemd}/bin/systemctl poweroff";
			};
			webcam.webcamEnabled = false;
		};
	};

	# Allow octoprint to restart itself and the pi
	security.sudo.extraRules = [
		{
			users = [ config.services.octoprint.user ];
			commands = builtins.map mkSudoCmd [
				config.services.octoprint.extraConfig.server.commands.serverRestartCommand
				config.services.octoprint.extraConfig.server.commands.systemRestartCommand
				config.services.octoprint.extraConfig.server.commands.systemShutdownCommand
			];
		}
	];

	services.nginx = {
		upstreams.octoprint.servers."127.0.0.1:${builtins.toString config.services.octoprint.port}" = {};
		virtualHosts."${config.networking.hostName}.${config.networking.domain}".locations."/octoprint/" = {
			proxyPass = "http://octoprint/";
			proxyWebsockets = true;
			extraConfig = ''
				client_max_body_size 100M;
				proxy_set_header X-Script-Name /octoprint;
				proxy_set_header X-Scheme $scheme;
			'';
		};
	};
}
