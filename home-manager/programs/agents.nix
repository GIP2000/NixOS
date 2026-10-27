{
    pkgs,
    inputs,
    ...
}: {
    home.packages = with pkgs; [
        codex
        claude-code
        inputs.codex-gui.packages.${pkgs.system}.default
    ];

    programs = {
        pi-coding-agent = let
            pi-openai-service-tier = pkgs.fetchFromGitHub {
                owner = "anirudhmehra";
                repo = "pi-openai-service-tier";
                rev = "6e7f0d7e4cc2fa3172a3f96759d2768b954eb30f";
                hash = "sha256-+1nU3VvCiv899f7ghw6kk8I6NCBdLq2xtlUTzqS1Smc=";
            };
        in {
            enable = true;
            settings = {
                defaultProvider = "openai-codex";
                defaultModel = "gpt-6-astra";
                defaultThinkingLevel = "xhigh";
                tuiMode = "regular";
                packages = [
                    "${pi-openai-service-tier}"
                ];
            };
        };
    };
}
