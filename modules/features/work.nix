{ inputs, ... }: {
    flake.modules.homeManager.work = { pkgs, ... }: {
        home.packages =
            let
                mkWebApp = inputs.helium.mkWebApp;
            in
            with pkgs;
            [
                slack
                (mkWebApp {
                    name = "helium-notion-work";
                    url = "https://app.notion.com/";
                    desktopName = "Notion Work";
                    icon = "Notion";
                    comment = "Notion note taking applicaiton";
                    categories = [ "Office" ];
                    extra_args = [
                        "--profile-directory=Work"
                    ];
                })
                (mkWebApp {
                    name = "Linear";
                    url = "https://linear.app/";
                    desktopName = "Linear";
                    icon = "Linear";
                    comment = "Linear Tickiting";
                    categories = [ "Office" ];
                })
            ];

    };

}
