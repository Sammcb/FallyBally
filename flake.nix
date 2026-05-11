{
	description = "Fally Bally app";

	inputs = {
		# Commit does not correspond to a tag.
		# Updating to latest commit generally follows unstable branch.
		nixpkgs.url = "github:NixOS/nixpkgs/f0a103ea5f8ba2ce197fd57e3ca6deff9a54260c";
		# Commit does not correspond to a tag.
		flake-parts.url = "github:hercules-ci/flake-parts/0678d8986be1661af6bb555f3489f2fdfc31f6ff";
		flake-checker = {
			# Commit corresponds to tag v0.2.11.
			url = "github:DeterminateSystems/flake-checker/1d9e9f37224ff2904b7dbca5cad576725ee814e5";
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
