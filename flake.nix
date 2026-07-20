{
	description = "Fally Bally app";

	inputs = {
		# Commit does not correspond to a tag.
		# Updating to latest commit generally follows unstable branch.
		nixpkgs.url = "github:NixOS/nixpkgs/7c24fefe6c95bf92e591260d817bec87b44c885d";
		# Commit does not correspond to a tag.
		flake-parts.url = "github:hercules-ci/flake-parts/8b9498dace8a531cef6972cadcd042591fbc49ad";
		flake-checker = {
			# Commit corresponds to tag v0.2.13.
			url = "github:DeterminateSystems/flake-checker/ec67ebf5b7a666b3509006c3e2ce5e7dfbcaaf38";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs@{self, nixpkgs, flake-parts, flake-checker}: flake-parts.lib.mkFlake {inherit inputs;} {
		systems = ["aarch64-darwin" "aarch64-linux" "x86_64-linux"];
		perSystem = {pkgs, system, ...}:
			let
				flakeCheckerPackage = flake-checker.packages.${system}.default;
			in {
				devShells.default = pkgs.mkShellNoCC {
					nativeBuildInputs = [flakeCheckerPackage] ++ (with pkgs; [editorconfig-checker zizmor trufflehog]);
				};

				devShells.lintWorkflows = pkgs.mkShellNoCC {
					nativeBuildInputs = with pkgs; [zizmor];
				};

				devShells.lintEditorconfig = pkgs.mkShellNoCC {
					nativeBuildInputs = with pkgs; [editorconfig-checker];
				};

				devShells.scanSecrets = pkgs.mkShellNoCC {
					nativeBuildInputs = with pkgs; [trufflehog];
				};
			};
	};
}
