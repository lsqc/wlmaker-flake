{
  description = "wlmaker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    wlmaker = {
      url = "git+https://github.com/phkaeser/wlmaker?ref=refs/tags/v0.8.1&submodules=1";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      self,
      ...
    }@inputs:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      nativeBuildInputs = with pkgs; [
        bison
        cmake
        doxygen
        flex
        git
        pkg-config
        makeWrapper
        plantuml
      ];

      buildInputs = with pkgs; [
        cairo
        libconfig
        libdrm
        librsvg
        libsysprof-capture
        libxcb
        libxdmcp
        libxdg_basedir
        libxkbcommon
        ncurses
        pixman
        wayland
        wayland-protocols
        wayland-scanner
        wlroots_0_20
        xcbutilwm
        xwayland
      ];
    in
    {
      packages.x86_64-linux.default = pkgs.stdenv.mkDerivation {

        inherit nativeBuildInputs;
        inherit buildInputs;

        pname = "wlmaker";
        version = "0.8.1";

        src = inputs.wlmaker;

        dontUseCmakeConfigure = true;

        env = {
          NIX_CFLAGS_COMPILE = " -I${pkgs.libdrm.dev}/include/libdrm ";
        };

        configurePhase = ''
          runHook preConfigure
          cmake -DCMAKE_INSTALL_PREFIX="$out" -B build
          runHook postConfigure

        '';

        buildPhase = ''
          runHook preBuild
          cmake --build build
          mkdir -p $out/share
          cp -r share/wlmaker $out/share/
          runHook postBuild
        '';

        installPhase = ''

          runHook preInstall
          cmake --install build
          wrapProgram $out/bin/wlmaker --prefix XDG_DATA_DIRS : $out/share

          runHook postInstall
        '';
      };

      devShells.default = pkgs.mkShell {
        inherit nativeBuildInputs;
        inherit buildInputs;

        shellHook = ''
          export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE"
          exec ${pkgs.lib.getExe pkgs.nushell}

        '';
      };
    };
}
