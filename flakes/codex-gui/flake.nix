{
    description = "OpenAI Codex desktop app";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = {
        self,
        nixpkgs,
    }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
        };

        version = "26.908.70816";
        url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${version}_amd64.deb";
        hash = "sha256-EO0MGogLmXXR8YW/eRGn9RTga5hjzU7ZVh1ABjYXyFQ=";
        glibcVersion = pkgs.lib.versions.majorMinor pkgs.glibc.version;

        # The app copies these resources into CODEX_HOME and customizes a few
        # plugin manifests at runtime. Files copied directly from the Nix store
        # retain their read-only mode, so provide a small writable source copy.
        prepareBundledPlugins = pkgs.writeShellScript "chatgpt-prepare-bundled-plugins" ''
            if [ -z "''${CODEX_ELECTRON_BUNDLED_PLUGINS_RESOURCES_PATH:-}" ]; then
                if [ -n "''${XDG_CACHE_HOME:-}" ]; then
                    chatgpt_cache_home="$XDG_CACHE_HOME"
                elif [ -n "''${HOME:-}" ]; then
                    chatgpt_cache_home="$HOME/.cache"
                else
                    echo "chatgpt: HOME or XDG_CACHE_HOME must be set" >&2
                    exit 1
                fi

                chatgpt_resources="$chatgpt_cache_home/chatgpt-nix/${version}/resources"
                chatgpt_marketplace="$chatgpt_resources/plugins/openai-bundled"
                chatgpt_ready="$chatgpt_resources/.ready"

                if [ ! -f "$chatgpt_ready" ]; then
                    ${pkgs.coreutils}/bin/mkdir -p "$chatgpt_marketplace"
                    ${pkgs.coreutils}/bin/cp -a \
                        "$CHATGPT_NIX_PACKAGE_ROOT/lib/chatgpt/resources/plugins/openai-bundled/." \
                        "$chatgpt_marketplace/"
                    ${pkgs.coreutils}/bin/chmod -R u+w "$chatgpt_resources"
                    ${pkgs.coreutils}/bin/touch "$chatgpt_ready"
                fi

                export CODEX_ELECTRON_BUNDLED_PLUGINS_RESOURCES_PATH="$chatgpt_resources"
            fi
        '';

        chatgpt = pkgs.stdenv.mkDerivation {
            pname = "chatgpt";
            inherit version;

            src = pkgs.fetchurl {
                inherit url hash;
                name = "chatgpt_amd64.deb";
            };

            nativeBuildInputs = with pkgs; [
                autoPatchelfHook
                dpkg
                makeWrapper
                wrapGAppsHook3
            ];

            buildInputs = with pkgs; [
                alsa-lib
                at-spi2-atk
                at-spi2-core
                atk
                cairo
                cups
                dbus
                expat
                fontconfig
                freetype
                gdk-pixbuf
                glib
                gtk3
                libdrm
                libgbm
                libnotify
                libsecret
                libusb1
                libxkbcommon
                nspr
                nss
                pango
                stdenv.cc.cc.lib
                systemd
                libx11
                libxcomposite
                libxdamage
                libxext
                libxfixes
                libxrandr
                libxcb
                libxshmfence
            ];

            runtimeDependencies = with pkgs; [
                libGL
                libnotify
                libsecret
                pipewire
                systemd
                vulkan-loader
                wayland
            ];

            autoPatchelfIgnoreMissingDeps = [
                "libQt5Core.so.5"
                "libQt5Gui.so.5"
                "libQt5Widgets.so.5"
                "libQt6Core.so.6"
                "libQt6Gui.so.6"
                "libQt6Widgets.so.6"
                "libc.musl-x86_64.so.1"
            ];

            dontBuild = true;
            dontConfigure = true;
            dontStrip = true;

            unpackPhase = ''
                runHook preUnpack

                dpkg-deb -x "$src" .

                runHook postUnpack
            '';

            installPhase = ''
                runHook preInstall

                mkdir -p "$out"
                mv usr/bin usr/lib usr/share "$out/"

                # detect-libc's process.report probe traps inside this Electron
                # build after patchelf has rewritten the executable. Disable the
                # probe and supply the glibc result its callers need. Every
                # replacement is byte-for-byte the same length so app.asar's
                # file offsets remain valid.
                app_asar="$out/lib/chatgpt/resources/app.asar"
                app_asar_size_before="$(${pkgs.coreutils}/bin/stat -c %s "$app_asar")"
                grep -aFq 'if (isLinux() && process.report) {' \
                    "$app_asar"
                sed -i \
                    's/if (isLinux() \&\& process\.report) {/if (false     \&\& process.report) {/' \
                    "$app_asar"
                sed -i \
                    's|if (report\.header && report\.header\.glibcVersionRuntime) {|if (true/\*__________________________________________\*/) {|' \
                    "$app_asar"
                sed -i \
                    's|return report\.header\.glibcVersionRuntime;|return "${glibcVersion}";/\*_______________________\*/|' \
                    "$app_asar"
                grep -aFq 'if (false     && process.report) {' \
                    "$app_asar"
                grep -aFq 'return "${glibcVersion}";/*_______________________*/' \
                    "$app_asar"
                test "$(${pkgs.coreutils}/bin/stat -c %s "$app_asar")" = \
                    "$app_asar_size_before"

                # Preserve the package's launcher behind a shell wrapper that
                # prepares the writable bundled-plugin resource copy.
                mv "$out/bin/chatgpt" "$out/bin/.chatgpt-deb-launcher"
                makeShellWrapper "$out/bin/.chatgpt-deb-launcher" "$out/bin/chatgpt" \
                    --set CHATGPT_NIX_PACKAGE_ROOT "$out" \
                    --run ". ${prepareBundledPlugins}"

                runHook postInstall
            '';

            preFixup = ''
                gappsWrapperArgs+=(
                    --add-flags "--ozone-platform-hint=auto"
                    --suffix PATH : "${pkgs.lib.makeBinPath (with pkgs; [git xdg-utils])}"
                )
            '';

            meta = with pkgs.lib; {
                description = "OpenAI's desktop app for Codex";
                homepage = "https://developers.openai.com/codex/app";
                license = licenses.unfree;
                mainProgram = "chatgpt";
                platforms = ["x86_64-linux"];
                sourceProvenance = with sourceTypes; [binaryNativeCode];
            };
        };
    in {
        packages.${system} = {
            inherit chatgpt;
            codex-gui = chatgpt;
            default = chatgpt;
        };

        apps.${system} = {
            chatgpt = {
                type = "app";
                program = "${chatgpt}/bin/chatgpt";
            };
            default = self.apps.${system}.chatgpt;
        };
    };
}
