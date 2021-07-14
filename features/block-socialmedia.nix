{ pkgs, ... }:

{
  networking.extraHosts =
    ''
      127.0.0.1 reddit.com
      127.0.0.1 www.reddit.com
      127.0.0.1 old.reddit.com
      127.0.0.1 www.old.reddit.com
      127.0.0.1 np.reddit.com

      127.0.0.1 news.ycombinator.com
      127.0.0.1 hckrnews.com

      127.0.0.1 lobste.rs
      127.0.0.1 www.lobste.rs

      127.0.0.1 twitter.com
      127.0.0.1 www.twitter.com
      127.0.0.1 mobile.twitter.com

      127.0.0.1 facebook.com
      127.0.0.1 www.facebook.com

      #127.0.0.1 app.slack.com
      #127.0.0.1 discord.com
    '';
}
