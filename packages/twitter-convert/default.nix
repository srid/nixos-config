{ writeShellApplication, ffmpeg-full, ... }:

# Some useful resources for this undocumented shit:
# - https://stackoverflow.com/q/59056863/55246
# - https://gist.github.com/nikhan/26ddd9c4e99bbf209dd7
writeShellApplication {
  name = "twitter-convert";
  runtimeInputs = [ ffmpeg-full ];
  meta.description = ''
    Convert a video for uploading to X / Twitter.

    You may need a Basic or Premium tier to upload longer videos.
  '';
  text = ''
    export ARSCRIPT="${./ffmpeg_ar}"
    ${./ffmpeg_twitter} "$1"
  '';
}
