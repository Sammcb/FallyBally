{
	description = "Fally Bally app";

	inputs = {
		# Commit does not correspond to a tag.
		# Updating to latest commit generally follows unstable branch.
		nixpkgs.url = "github:NixOS/nixpkgs/030a23777772752542b0cba04ae37878997ebe50";
		# Commit does not correspond to a tag.
		flake-parts.url = "github:hercules-ci/flake-parts/f7c1a2d347e4c52d5fb8d10cb4d94b5884e546fb";
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
