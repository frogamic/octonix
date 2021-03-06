{ mkSudoCmd, printer, sudo }: { config, pkgs, ...}: {
	services.octoprint = {
		plugins = plugins: with pkgs; [
			plugins.bedlevelvisualizer
			plugins.marlingcodedocumentation
			plugins.printtimegenius
			plugins.octoprint-dashboard
			plugins.displaylayerprogress
			(plugins.buildPlugin rec {
				pname = "ActiveFiltersExtended";
				version = "0.1.0";
				src = fetchFromGitHub {
					owner = "jneilliii";
					repo = "OctoPrint-${pname}";
					rev = version;
					sha256 = "bkVybMPWyt0mCIBU38XPJkGqBiC03VTgJKkwY/E8Gws=";
				};
			})
			(plugins.buildPlugin rec {
				pname = "macro";
				version = "0.3.2";
				src = fetchFromGitHub {
					owner = "mike1pol";
					repo = "OctoPrint_${pname}";
					rev = version;
					sha256 = "qjKDT/dha4FxwNBCXkGG7vK1FMcVOvSaA9ETfoNNA7s=";
				};
			})
			(plugins.buildPlugin rec {
				pname = "TopTemp";
				version = "0.0.1.7";
				src = fetchFromGitHub {
					owner = "LazeMSS";
					repo = "OctoPrint-${pname}";
					rev = version;
					sha256 = "rOm6qCPQDMwhxdCuVBA4hVqKcwA7crzJ3cu9PgYJ8kA=";
				};
			})
			(plugins.buildPlugin rec {
				pname = "Autoscroll";
				version = "0.0.3";
				src = fetchFromGitHub {
					owner = "MoonshineSG";
					repo = "OctoPrint-${pname}";
					rev = version;
					sha256 = "SJD5aYuxrJLOrs1LybImgYI50dbrVrpMHwPrYjNhYXk=";
				};
			})
			(plugins.buildPlugin rec {
				pname = "UICustomizer";
				version = "0.1.8.1";
				src = fetchFromGitHub {
					owner = "LazeMSS";
					repo = "OctoPrint-${pname}";
					rev = version;
					sha256 = "5Rm56BicC8rKTrsW46kZw4P5qVLHtLDJcN4bwc8Ofck=";
				};
			})
			(plugins.buildPlugin rec {
				pname = "PrettyGCode";
				version = "v1.2.4";
				src = fetchFromGitHub {
					owner = "Kragrathea";
					repo = "OctoPrint-${pname}";
					rev = version;
					sha256 = "q/B2oEy+D6L66HqmMkvKfboN+z3jhTQZqt86WVhC2vQ=";
				};
			})
			(plugins.buildPlugin rec {
				pname = "ExcludeRegionPlugin";
				version = "0.3.0";
				src = fetchFromGitHub {
					owner = "bradcfisher";
					repo = "OctoPrint-${pname}";
					rev = version;
					sha256 = "ARObfzzfWTBi8JPr2mf5kN7R4suFrySOXpbDstpLHPo=";
				};
			})
			(plugins.buildPlugin rec {
				pname = "M73Progress";
				version = "v0.2.1";
				src = fetchFromGitHub {
					owner = "cesarvandevelde";
					repo = "OctoPrint-${pname}";
					rev = version;
					sha256 = "LWCKgGGGK7YQcfTeWDU1BI+pYXoWms1NXtKP/Fvb9S0=";
				};
			})
			(plugins.buildPlugin rec {
				pname = "ActionCommandsPlugin";
				version = "0.5";
				src = fetchFromGitHub {
					owner = "benlye";
					repo = "OctoPrint-${pname}";
					rev = version;
					sha256 = "REXoHBKT1Ri7TnPGmbUTY/r9N5tRBGxxhiKk3ShwJds=";
				};
			})
		];

		extraConfig.plugins = {
			actioncommands."command_definitions" = [
				{
					action = "shutdown";
					command = config.services.octoprint.extraConfig.server.commands.systemShutdownCommand;
					enabled = true;
					type = "system";
				}
			];
			pi_support.vcgencmd_throttle_check_command = "${sudo} ${pkgs.libraspberrypi}/bin/vcgencmd get_throttled";
			toptemp.customMon.cu0.cmd = "${sudo} ${pkgs.libraspberrypi}/bin/vcgencmd measure_temp|cut -d '=' -f2|cut -d\"'\" -f1";
		};
	};

	# Allow plugins to do the needful
	security.sudo.extraRules = [{
		users = [ config.services.octoprint.user ];
		commands = builtins.map mkSudoCmd [
			config.services.octoprint.extraConfig.plugins.pi_support.vcgencmd_throttle_check_command
			config.services.octoprint.extraConfig.plugins.toptemp.customMon.cu0.cmd
		];
	}];
}
