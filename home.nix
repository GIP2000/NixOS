{
    config,
    pkgs,
    inputs,
    ...
}: {
    imports = [
        inputs.nvf.homeManagerModules.default
        inputs.zen-browser.homeModules.default
    ];

    home = {
        username = "gip";
        homeDirectory = "/home/gip";
        stateVersion = "25.11";
        packages = with pkgs; [
            discord
            spotify
            firefox
            zsh-powerlevel10k
            alsa-utils
            ripgrep
            wl-clipboard
            bat
            (writeShellApplication {
                name = "tmux-sessionizer";
                runtimeInputs = [fzf];
                text = ''
                    if [[ $# -eq 1 ]]; then
                        selected=$1
                    else
                        selected=$(  (find ~/Documents/dev -mindepth 1 -maxdepth 1 -type d; echo "/etc/nixos") | fzf)
                    fi

                    if [[ -z $selected ]]; then
                        exit 0
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
    };

    wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        extraConfig = ''
            exec-once = waybar
            input {
                repeat_delay = 150
                repeat_rate  = 25
            }
        '';
        settings = {
            animations = {
                enabled = true;
                animation = [
                    "workspaces, 0, 0, deafult"
                ];
            };

            workspace = [
                "1, name: Scratch 1"
                "2, name: Scratch 2"
                "3, name: Scratch 3"
                "4, name: Scratch 4"
                "5, name: Scratch 5"
                "6, name: Scratch 6"
                "7, name: Scratch 7"
                "8, name: Scratch 8"
                "9, name: Scratch 9"
                "10, name:Terminal"
                "11, name:Web"
                "12, name:Messaging"
                "13, name:Music"

                # smart gap
                "w[tv1], gapsout:0, gapsin:0"
                "w[f1], gapsout:0, gapsin:0"
            ];

            "$mod" = "SUPER";
            "$wmod" = "ALT";
            bind = [
                "$mod, Q, killactive"
                "$mod, B, exec, zen-beta"
                "$mod, T, exec, ghostty"

                #Focus
                "$wmod, j, movefocus, d"
                "$wmod, k, movefocus, u"
                "$wmod, h, movefocus, l"
                "$wmod, l, movefocus, r"

                #Move
                "$wmod SHIFT, j, movewindow, d"
                "$wmod SHIFT, k, movewindow, u"
                "$wmod SHIFT, h, movewindow, l"
                "$wmod SHIFT, l, movewindow, r"

                # Workspaces
                "$wmod, 1, workspace,  1"
                "$wmod, 2, workspace,  2"
                "$wmod, 3, workspace,  3"
                "$wmod, 4, workspace,  4"
                "$wmod, 5, workspace,  5"
                "$wmod, 6, workspace,  6"
                "$wmod, 7, workspace,  7"
                "$wmod, 8, workspace,  8"
                "$wmod, 9, workspace,  9"
                "$wmod, a, workspace, 10"
                "$wmod, s, workspace, 11"
                "$wmod, d, workspace, 12"
                "$wmod, r, workspace, 13"

                # Workspaces move
                "$wmod SHIFT, 1, movetoworkspace,  1"
                "$wmod SHIFT, 2, movetoworkspace,  2"
                "$wmod SHIFT, 3, movetoworkspace,  3"
                "$wmod SHIFT, 4, movetoworkspace,  4"
                "$wmod SHIFT, 5, movetoworkspace,  5"
                "$wmod SHIFT, 6, movetoworkspace,  6"
                "$wmod SHIFT, 7, movetoworkspace,  7"
                "$wmod SHIFT, 8, movetoworkspace,  8"
                "$wmod SHIFT, 9, movetoworkspace,  9"
                "$wmod SHIFT, a, movetoworkspace, 10"
                "$wmod SHIFT, s, movetoworkspace, 11"
                "$wmod SHIFT, d, movetoworkspace, 12"
                "$wmod SHIFT, r, movetoworkspace, 13"
            ];
        };
    };

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
            };
        };

        waybar = {
            enable = true;
            style = ''
                * {
                    font-family: JetBrainsMono Nerd Font Propo;
                    font-size: 1.32375rem;
                    font-weight: bold;
                    border: none;
                    outline: none;
                    box-shadow: none;
                    text-shadow: none;
                }
            '';
            settings = {
                mainBar = {
                    layer = "top";
                    position = "top";
                    height = 30;
                    modules-left = [
                        "hyprland/window"
                        "hyprland/workspaces"
                    ];
                    modules-center = [
                        "clock"
                    ];
                    modules-right = [
                        "network"
                    ];

                    "hyprland/window" = {
                        format = "{initialTitle}";
                        max-length = 80;
                        icon = true;
                        icon-size = 24;
                    };

                    "hyprland/workspaces" = {
                        disable-scroll = true;
                        all-outputs = false;
                        format = "{icon}";
                        format-icons = {
                            default = "󰜌";
                            active = "󰜋";
                        };
                        persistent-workspaces = {
                            "10" = [];
                            "11" = [];
                            "12" = [];
                            "13" = [];
                        };
                    };

                    network = {
                        tooltip = true;
                        format = "{icon}";
                        format-wifi = "{icon}";
                        format-icons = {
                            default = [
                                "󰤯"
                                "󰤟"
                                "󰤢"
                                "󰤥"
                                "󰤨"
                            ];
                        };
                        format-ethernet = "󰤨";
                        format-disconnected = "󰤫";
                        format-disabled = "󰤮";
                        tooltip-format-wifi = "󰤥 {essid} ({signalStrength}%)";
                        tooltip-format-ethernet = " {ifname}";
                        tooltip-format-disconnected = "󰤦 Verbindung getrennt!";
                        tooltip-format-disabled = "󰤦 Verbindung ausgeschalten!";
                        on-click = "hyprctl dispatch exec '[float; size 879 879] kitty nmtui'";
                        on-click-right = "setsid ~/.config/swaync/scripts/netzwerk.sh";
                    };
                    clock = {
                        timezone = "America/New_York";
                        tooltip-format = "<big>{:L%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
                        format = " {:%I:%M %p}";
                        format-alt = "󰸗 {:L%a %d.%m.%y}";
                        calendar = {
                            mode = "year";
                            mode-mon-col = 3;
                            weeks-pos = "right";
                            on-scroll = 1;
                            format = {
                                months = "<span><b>{}</b></span>";
                                days = "<span><b>{}</b></span>";
                                weeks = "<span><b>W{}</b></span>";
                                weekdays = "<span><b>{}</b></span>";
                                today = "<span><b><u>{}</u></b></span>";
                            };
                        };
                    };
                };
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

                         bind -T copy-mode-vi v send -X begin-selection
                         bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
                         bind P paste-buffer
                         bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

                         bind-key f display-popup -E "tmux-sessionizer"
            '';
        };
        nvf = {
            enable = true;

            settings.vim = let
                bind = mode: key: action: {
                    inherit mode key action;
                };
                nnoremap = bind "n";
                vnoremap = bind "v";
                xnoremap = bind "x";
                inoremap = bind "i";
            in {
                lsp = {
                    enable = true;
                    formatOnSave = true;
                    mappings = {
                        hover = "K";
                        goToDefinition = "gd";
                        listImplementations = "gi";
                        openDiagnosticFloat = "<leader>ld";
                        nextDiagnostic = "[d";
                        previousDiagnostic = "]d";
                        codeAction = "<leader>la";
                        listReferences = "gr";
                        renameSymbol = "<leader>lr";
                        signatureHelp = "<leader>ls";
                    };
                };

                autocomplete.nvim-cmp = {
                    enable = true;
                    sourcePlugins = ["cmp-nvim-lsp"];
                };

                comments.comment-nvim = {
                    enable = true;
                    mappings = {
                        toggleCurrentLine = "<leader>/";
                        toggleSelectedLine = "<leader>/";
                    };
                };

                syntaxHighlighting = true;
                treesitter = {
                    enable = true;
                    fold = false;
                    highlight.enable = true;
                    indent.enable = true;
                    grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
                };

                languages = {
                    enableTreesitter = true;
                    enableFormat = true;
                    rust = {
                        enable = true;
                        lsp = {
                            package = ["rust-analyzer"];
                            opts = ''
                                ['rust-analyzer'] = {
                                    cargo = {
                                        allFeatures = true,
                                    },
                                    checkOnSave = true,
                                    procMacro = {
                                        enable = true,
                                    },
                                },
                            '';
                        };
                    };
                    ts.enable = true;
                    nix.enable = true;
                };

                git.vim-fugitive.enable = true;
                utility.oil-nvim.enable = true;
                utility.undotree.enable = true;
                visuals.nvim-web-devicons.enable = true;
                visuals.rainbow-delimiters.enable = true;
                telescope = {
                    enable = true;
                    mappings = {
                        liveGrep = "<leader>fw";
                        diagnostics = "<leader>fd";
                    };
                };
                navigation.harpoon = {
                    enable = true;

                    setupOpts = {
                        sync_on_ui_close = true;
                    };

                    mappings = {
                        markFile = "<leader>j";
                        listMarks = "<leader>h";

                        file1 = "<leader>a";
                        file2 = "<leader>s";
                        file3 = "<leader>d";
                        file4 = "<leader>r";
                    };
                };

                statusline.lualine = {
                    enable = true;
                };

                globals = {
                    mapleader = " ";
                };

                theme = {
                    enable = true;
                    name = "catppuccin";
                    style = "auto";
                };

                keymaps = [
                    (nnoremap "j" "gj")
                    (nnoremap "gj" "j")
                    (vnoremap "gj" "j")
                    (
                        (vnoremap "j" "mode() ==# 'v' ? 'gj' : 'j'")
                        // {
                            expr = true;
                            noremap = false;
                            silent = false;
                        }
                    )

                    (nnoremap "k" "gk")
                    (nnoremap "gk" "k")
                    (vnoremap "gk" "k")
                    (
                        (vnoremap "k" "mode() ==# 'v' ? 'gk' : 'k'")
                        // {
                            expr = true;
                            noremap = false;
                            silent = false;
                        }
                    )

                    (nnoremap "<leader>c" ":q<CR>")

                    (nnoremap "<C-h>" "<C-w>h")
                    (nnoremap "<C-l>" "<C-w>l")

                    (nnoremap "<leader>v" "<C-w>v")

                    (nnoremap "<leader>gs" ":above Git<CR>")

                    (nnoremap "<leader>e" ":Oil<CR>")

                    (nnoremap "<leader>u" ":UndotreeToggle<CR>")
                ];

                options = {
                    number = true;
                    relativenumber = true;

                    errorbells = false;
                    termguicolors = true;
                    scrolloff = 8;
                    signcolumn = "yes";
                    cmdheight = 1;
                    updatetime = 50;

                    tabstop = 4;
                    softtabstop = 4;
                    shiftwidth = 4;
                    expandtab = true;
                    smartindent = true;

                    swapfile = false;
                    backup = false;

                    hlsearch = false;
                    incsearch = true;

                    isfname = "@-@";
                    shortmess = "c";
                };
            };
        };
        zen-browser = {
            enable = true;
            profiles.default = let
                containers = {
                    Personal = {
                        color = "green";
                        icon = "tree";
                        id = 1;
                    };
                    Work = {
                        color = "purple";
                        icon = "briefcase";
                        id = 2;
                    };
                };
                spaces = {
                    Personal = {
                        id = "c467e5f9-681e-48a6-b005-da14fb4fc0dd";
                        container = containers.Personal.id;
                        position = 1000;
                    };
                    Work = {
                        id = "7e5a18fe-1159-4d3b-b5d5-178ccbeb3480";
                        container = containers.Work.id;
                        position = 2000;
                    };
                };
                pins = {
                    mail = {
                        id = "5fc9a6ff-be76-46be-b584-6e1dacac1b2f";
                        container = containers.Personal.id;
                        url = "https://mail.google.com/";
                        isEssential = true;
                        position = 101;
                    };
                    github = {
                        id = "882953cb-6efd-4a5a-95b1-8850a6c963b0";
                        container = containers.Personal.id;
                        url = "https://www.github.com";
                        isEssential = true;
                        position = 102;
                    };
                    youtube = {
                        id = "29a055eb-5f41-4c94-936e-895c2353be1a";
                        container = containers.Personal.id;
                        url = "https://www.youtube.com";
                        isEssential = true;
                        position = 103;
                    };
                    blueksy = {
                        id = "5df643c9-0106-412b-ab57-dd4ff41e9673";
                        container = containers.Personal.id;
                        url = "https://bsky.app/";
                        isEssential = true;
                        position = 104;
                    };
                    cal = {
                        id = "d8c1d132-f6dc-4c3d-981a-8ff8416fc197";
                        container = containers.Personal.id;
                        url = "https://calendar.google.com";
                        isEssential = true;
                        position = 105;
                    };
                };
            in {
                containersForce = true;
                pinsForce = true;
                spacesForce = true;
                inherit containers pins spaces;
                # extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system} [
                #
                # ];
            };
        };
    };
}
