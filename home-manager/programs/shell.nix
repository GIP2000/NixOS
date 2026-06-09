{pkgs, ...}: {
    home.packages = with pkgs; [
        kitty
        zsh-powerlevel10k
        bat
        wl-clipboard
        unzip
        (writeShellApplication {
            name = "tmux-sessionizer";
            runtimeInputs = [fzf];
            text = ''
                if [[ $# -eq 2 ]]; then
                    selected=$1
                else
                    result=$(  { find ~/ -mindepth 1 -maxdepth 2 -type d ! -regex '.*\..*'; find ~/Documents/dev -mindepth 1 -maxdepth 1 -type d; } | fzf --delimiter '/' --with-nth=-1 --print-query || true)
                fi

                query=$(sed -n '1p' <<< "''${result:-}")
                selected=$(sed -n '2p' <<< "''${result:-}")

                if [[ -z "''${selected:-}" ]]; then
                    if [[ -z "''${query:-}" ]]; then
                        printf "No query provided, aborting\n"
                        exit 1
                    fi

                    selected="$HOME/Documents/dev/$query"
                    mkdir -p "$selected"
                fi

                selected_name=$(basename "$selected" | tr . _)
                tmux_running=$(pgrep tmux)

                if [[ -z ''${TMUX:-} ]] && [[ -z "''${tmux_running:-}" ]]; then
                    tmux new-session -s "$selected_name" -c "$selected"
                    exit 0
                fi

                if ! tmux has-session -t="$selected_name" 2> /dev/null; then
                    tmux new-session -ds "$selected_name" -c "$selected"
                fi

                if [[ "''${TMUX:-}" == "" ]]; then
                    tmux attach-session -t "$selected_name"
                else
                    tmux switch-client -t "$selected_name"
                fi
            '';
        })
    ];
    programs = {
        git = {
            enable = true;
            settings = {
                user = {
                    name = "Gregory Presser";
                    email = "gpress2222@gmail.com";
                };

                safe.directory = "/etc/nixos";
                push.autoSetupRemote = true;
                init.defaultBranch = "main";
            };
        };

        ghostty = {
            enable = true;
            settings = {
                font-size = 20;

                window-padding-x = 0;
                window-padding-y = 0;
                window-padding-balance = true;
            };
        };

        direnv = {
            enable = true;
            nix-direnv.enable = true;
            enableZshIntegration = true;
            stdlib = ''
                use flake
            '';
        };
        zsh = {
            enable = true;
            zplug = {
                enable = true;
                plugins = [
                    {
                        name = "romkatv/powerlevel10k";
                        tags = [
                            "as:theme"
                            "depth:1"
                        ];
                    }
                    {name = "zsh-users/zsh-autosuggestions";}
                ];
            };
            shellAliases = {
                vim = "nvim";
                ts = "tmux-sessionizer";
            };
            initContent = ''
                [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
                            export DIRENV_LOG_FORMAT="%s"
                            export DIRENV_CONFIG="$HOME/.config/direnv"
            '';
        };
        tmux = {
            enable = true;
            extraConfig = ''
                set-option -g default-shell ${pkgs.zsh}/bin/zsh
                set-option -g default-command ${pkgs.zsh}/bin/zsh
                set-option -g default-terminal "screen-256color"

                set -g history-limit 10000

                setw -g mouse on

                set-window-option -g mode-keys vi

                bind h select-pane -L
                bind j select-pane -D
                bind k select-pane -U
                bind l select-pane -R

                bind v split-window -h
                bind w split-window -v

                bind -T copy-mode-vi v send -X begin-selection
                bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
                bind P paste-buffer
                bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

                bind-key f display-popup -E "tmux-sessionizer"
            '';
        };
    };
}
