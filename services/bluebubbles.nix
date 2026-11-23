{
    inputs,
    lib,
    config,
    ...
}: let
    server = inputs.bluebubbles-server.packages.aarch64-darwin.bluebubbles-server;
    appDir = "${config.home.homeDirectory}/Applications";
in {
    home.packages = [server];

    home.activation.installBlueBubbles = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p "${appDir}"
        if [ -d "${appDir}/BlueBubbles.app" ]; then
          chmod -R u+w "${appDir}/BlueBubbles.app"
          rm -rf "${appDir}/BlueBubbles.app"
        fi
        /usr/bin/ditto "${server}/Applications/BlueBubbles.app" "${appDir}/BlueBubbles.app"
        chmod -R u+w "${appDir}/BlueBubbles.app"
        /usr/bin/xattr -cr "${appDir}/BlueBubbles.app"
        /usr/bin/codesign --force --deep --sign - "${appDir}/BlueBubbles.app"
    '';

    launchd.agents.bluebubbles = {
        enable = true;
        config = {
            ProgramArguments = ["${appDir}/BlueBubbles.app/Contents/MacOS/BlueBubbles"];
            RunAtLoad = true;
            KeepAlive = true;
            StandardOutPath = "/tmp/bluebubbles.out.log";
            StandardErrorPath = "/tmp/bluebubbles.err.log";
        };
    };
}
