{
    pkgs,
    inputs,
    lib,
    ...
}: {
    imports = [
        inputs.nvf.homeManagerModules.default
    ];

    home.packages = [pkgs.ripgrep];
    programs.nvf = {
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
                presets.tailwindcss-language-server.enable = true;
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

                servers = {
                    zls.cmd = lib.mkForce ["zls"];
                    rust-analyzer = {
                        cmd = lib.mkForce ["rust-analyzer"];
                        init_options = ''
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

                rust.enable = true;
                odin.enable = true;
                nix.enable = true;
                tsx = {
                    enable = true;
                    lsp.servers = ["typescript-go"];
                    format = {
                        enable = false;
                        # type = ["biome"];
                    };
                    extraDiagnostics = {
                        enable = true;
                        # types = ["biomejs"];
                    };
                };
                typescript = {
                    enable = true;
                    lsp.servers = ["typescript-go"];
                    # format = {
                    #     enable = true;
                    #     # type = ["biome"];
                    # };
                    extraDiagnostics = {
                        enable = true;
                        # types = ["biomejs"];
                    };
                };
                zig = {
                    enable = true;
                    lsp.servers = ["zls"];
                };
                lua.enable = true;
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
                extensions = [
                    {
                        name = "live_grep_args";
                        packages = [pkgs.vimPlugins.telescope-live-grep-args-nvim];
                        setup = {
                            auto_quoting = true;
                        };
                    }
                ];
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
                (nnoremap "<leader>c" ":q<CR>")

                (nnoremap "<C-h>" "<C-w>h")
                (nnoremap "<C-l>" "<C-w>l")

                (nnoremap "<leader>v" "<C-w>v")

                (nnoremap "<leader>gs" ":above Git<CR>")

                (nnoremap "<leader>e" ":Oil<CR>")

                (nnoremap "<leader>u" ":UndotreeToggle<CR>")

                (nnoremap "<leader>fg" "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
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
}
