let
  redditTop = subreddit: limit: period: {
    url = "https://www.reddit.com/r/${subreddit}/top/.rss?t=${period}&limit=${toString limit}";
  };
in
{
  nixos-logo-proposal = {
    url = "https://discourse.nixos.org/t/proposal-update-the-nixos-logo-for-ukrainian-flag-day-23-august/68375.rss";
  };
  hackernews-best = {
    url = "https://hnrss.org/best?points=50"; # Posts with 50+ points
  };
  haskell-reddit-top = redditTop "haskell" 5 "day";
  nixos-reddit-top = redditTop "nixos" 5 "day";
}
