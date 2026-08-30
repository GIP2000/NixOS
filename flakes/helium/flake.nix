# flake.nix
{
    description = "Helium Browser";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = {
        self,
        nixpkgs,
    }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs {inherit system;};
        version = "0.16.2.1";
        hash = "sha256-gAg4BpJyhwpvT8nq3wF8CBn32Jq/YHEXCAsHnUv3wBc=";
    in {
        mkWebApp = {
            name,
            desktopName,
            icon,
            comment,
            categories,
            url,
            extra_args ? [],
        }: let
            helium-browser-pkg = self.packages.${system}.helium-browser;
            helium-browser-path = "${helium-browser-pkg}/bin/helium-browser";
            script = pkgs.writeShellApplication {
                name = name;
                runtimeInputs = [helium-browser-pkg];
                text = ''
                    ${helium-browser-path} --app=${url}
                '';
            };
        in
            pkgs.symlinkJoin {
                name = name;
                paths = [
                    script
                    (pkgs.makeDesktopItem {
                        name = name;
                        desktopName = desktopName;
                        exec = "${script}/bin/${name} ${builtins.concatStringsSep " " (extra_args ++ ["%U"])}";
                        icon = icon;
                        comment = comment;
                        categories = categories;
                    })
                ];
            };

        packages.${system} = {
            helium-whatsapp = self.mkWebApp {
                name = "helium-whatsapp";
                url = "https://web.whatsapp.com/";
                desktopName = "WhatsApp";
                icon = "whatsapp";
                comment = "WhatsApp Web running through helium browser";
                categories = ["Network" "InstantMessaging"];
            };
            helium-browser = pkgs.stdenv.mkDerivation {
                pname = "helium-browser";
                inherit version;

                src = pkgs.fetchurl {
                    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64_linux.tar.xz";
                    sha256 = hash;
                };

                buildInputs = with pkgs; [
                    # Core
                    gtk3
                    glib
                    dbus
                    atk
                    cairo
                    pango
                    gdk-pixbuf
                    # Wayland (Chromium supports both)
                    wayland
                    libxkbcommon
                    # GPU / media
                    egl-wayland
                    libGL
                    mesa
                    libva # hardware video acceleration
                    pipewire # screen sharing / WebRTC
                    # Audio
                    alsa-lib
                    # Fonts / rendering
                    freetype
                    fontconfig
                    # Sandbox
                    libcap
                    # nss for TLS
                    nss
                    nspr
                    # expat, cups (Chromium links these)
                    expat
                    cups
                ];

                nativeBuildInputs = with pkgs; [
                    autoPatchelfHook
                    makeWrapper
                ];

                autoPatchelfIgnoreMissingDeps = [
                    "libQt5Core.so.5"
                    "libQt5Gui.so.5"
                    "libQt5Widgets.so.5"
                    "libQt6Core.so.6"
                    "libQt6Gui.so.6"
                    "libQt6Widgets.so.6"
                ];

                sourceRoot = ".";

                installPhase = ''
                    mkdir -p $out/lib/helium $out/bin $out/share/applications

                    cp -r helium-${version}-x86_64_linux/* $out/lib/helium/

                    ln -s $out/lib/helium/helium $out/bin/helium-browser

                    cat > $out/share/applications/helium-browser.desktop << EOF
                    [Desktop Entry]
                    Name=Helium
                    Comment=Private, fast, and honest web browser
                    Exec=$out/bin/helium-browser %U
                    Icon=$out/lib/helium/product_logo_256.png
                    Type=Application
                    Categories=Network;WebBrowser;
                    MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
                    EOF
                '';

                # Chromium-based browsers need these env vars to work well
                postFixup = ''
                    wrapProgram $out/bin/helium-browser \
                      --set CHROME_DEVEL_SANDBOX /run/wrappers/bin/chrome-sandbox \
                      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath (with pkgs; [
                        libGL
                        egl-wayland
                        mesa
                        vulkan-loader
                        pipewire
                        libdrm
                    ])}" \
                    --add-flags "--ignore-gpu-blocklist" \
                    --add-flags "--enable-gpu-rasterization" \
                    --add-flags "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,UseOzonePlatform,WebRTCPipeWireCapturer" \
                    --add-flags "--ozone-platform=wayland"
                '';

                meta = with pkgs.lib; {
                    description = "Private, fast Chromium-based browser by Imput";
                    homepage = "https://helium.computer";
                    license = licenses.gpl3;
                    platforms = ["x86_64-linux" "aarch64-linux"];
                };
            };
        };

        apps.${system}.helium-browser = {
            type = "app";
            program = "${self.packages.${system}.helium-browser}/bin/helium-browser";
        };

        defaultPackage.${system} = self.packages.${system}.helium-browser;
    };
}
