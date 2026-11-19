{
    pkgs,
    inputs,
    ...
}:
{
    home.packages =
        with pkgs;
        let
            llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
        in
        [
            codex
            claude-code
            libnotify # Provides notify-send for pi-ping when its tmux session is detached.
            llm-agents.claude-desktop
            llm-agents.chatgpt
        ];

    programs = {
        pi-coding-agent =
            let
                pi-claude-bridge = pkgs.buildNpmPackage {
                    pname = "pi-claude-bridge";
                    version = "0.9.3";

                    src = pkgs.fetchFromGitHub {
                        owner = "elidickinson";
                        repo = "pi-claude-bridge";
                        rev = "0b41f78189de09c6da6baf3acc0f604b089f08fb";
                        hash = "sha256-8asHumCj7UrQsa3Niogq4U1RAuqt2OEIBirQyHtKNJE=";
                    };

                    npmDepsHash = "sha256-C6feY0M1znfiGeHheaNN1jlbmBM7DOPscpA+TNdNNqQ=";

                    dontNpmBuild = true;
                    npmFlags = [
                        "--omit=dev"
                        "--omit=peer"
                        "--omit=optional"
                    ];

                    postPatch = ''
                        substituteInPlace src/config.ts \
                            --replace-fail 'provider: { ...global.provider },' \
                            'provider: { pathToClaudeCodeExecutable: "${pkgs.lib.getExe pkgs.claude-code}", ...global.provider },'
                    '';

                    meta = {
                        description = "Pi extension providing Claude Code models via the Claude Agent SDK";
                        homepage = "https://github.com/elidickinson/pi-claude-bridge";
                        license = pkgs.lib.licenses.mit;
                    };
                };
                pi-ping = pkgs.fetchFromGitHub {
                    owner = "Bukutsu";
                    repo = "pi-ping";
                    rev = "fe0ccf1697621df837f0358e0b7c1550f39997e7"; # v1.3.6
                    hash = "sha256-ErhhKaU6cb+lFRpYQJB8DsStwtebw9nCVdmAbWt191E=";
                };
                pi-openai-service-tier = pkgs.fetchFromGitHub {
                    owner = "anirudhmehra";
                    repo = "pi-openai-service-tier";
                    rev = "6e7f0d7e4cc2fa3172a3f96759d2768b954eb30f";
                    hash = "sha256-+1nU3VvCiv899f7ghw6kk8I6NCBdLq2xtlUTzqS1Smc=";
                };
            in
            {
                enable = true;
                settings = {
                    defaultProvider = "openai";
                    defaultModel = "gpt-6.2-astra";
                    defaultThinkingLevel = "xhigh";
                    tuiMode = "regular";
                    extensions = [
                        "${./workspace-mcp.ts}"
                    ];
                    skills = [
                        "${./skills/workspace-resources}"
                    ];
                    packages = [
                        "${pi-ping}"
                        "${pi-openai-service-tier}"
                        "${pi-claude-bridge}/lib/node_modules/pi-claude-bridge"
                    ];
                };
            };
    };
}
