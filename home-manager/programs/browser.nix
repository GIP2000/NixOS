{inputs, ...}: {
    imports = [
        inputs.zen-browser.homeModules.default
    ];

    programs = {
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

                    whatsapp = {
                        id = "9dcde9f9-42f0-4a00-9aee-4bf1327aeb34";
                        container = containers.Personal.id;
                        url = "https://web.whatsapp.com/";
                        isEssential = true;
                        position = 106;
                    };
                };
            in {
                containersForce = false;
                spacesForce = false;
                pinsForce = false;
                inherit containers pins spaces;
                search = {
                    default = "ddg";
                };
            };
        };
    };
}
