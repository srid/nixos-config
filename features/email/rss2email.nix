{ pkgs, ... }: {
  services.rss2email = {
    enable = true;
    to = "srid@srid.ca";
    feeds = {
      "r-haskell".url = "https://www.reddit.com/r/haskell/top/.rss?t=week";
    };
  };
}
