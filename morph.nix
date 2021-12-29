{
	nammu = {
		imports = [ ./configuration.nix ];
		nixpkgs = rec {
			system = "aarch64-linux";
			pkgs = import <nixpkgs> { inherit system; };
		};
		deployment = {
			tags = [
				"on-premise"
				"prod"
				"maker"
			];
			secrets = {
				wifi = {
					source = "secrets/wifi.conf";
					destination = "/etc/wpa_supplicant.conf";
					owner = {
						user = "root";
						group = "root";
					};
				};
			};
		};
	};
}
