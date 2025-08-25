let
  redditTop = subreddit: limit: period:
    "https://www.reddit.com/r/${subreddit}/top/.rss?t=${period}&limit=${toString limit}";
in
{
  # actualism
  vineeto-discourse.url = "https://discuss.actualism.online/u/vineeto/activity.rss";

  # general tech news
  hackernews-best.url = "https://hnrss.org/best?points=50";
  notebookcheck.url = "https://www.notebookcheck.net/RSS-Feed-Notebook-Reviews.8156.0.html";

  # reddit
  haskell-reddit-top.url = redditTop "haskell" 5 "day";
  nixos-reddit-top.url = redditTop "nixos" 5 "day";

  # woke drama
  nixos-drupol-discourse-ukraine.url = "https://discourse.nixos.org/t/proposal-update-the-nixos-logo-for-ukrainian-flag-day-23-august/68375.rss";
}
