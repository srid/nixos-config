{ writeShellApplication, ffmpeg-full, ... }:

writeShellApplication {
  name = "compress-video";
  meta.description = ''
    Compress a video file for sharing (e.g., Slack's 1GB limit).
    Usage: compress-video input.mov [target_size_mb]
    Default target size is 900MB.
  '';
  runtimeInputs = [ ffmpeg-full ];
  text = ''
    input="$1"
    target_mb="''${2:-900}"

    if [ -z "$input" ]; then
      echo "Usage: compress-video <input> [target_size_mb]"
      exit 1
    fi

    output="''${input%.*}-compressed.mp4"

    # Get duration in seconds
    duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$input")
    duration_int="''${duration%%.*}"

    # Calculate target bitrate (bits/sec) = target_bytes * 8 / duration
    # Reserve ~128kbps for audio
    audio_bitrate=128
    total_bitrate=$(( (target_mb * 8192) / duration_int ))
    video_bitrate=$(( total_bitrate - audio_bitrate ))

    if [ "$video_bitrate" -lt 500 ]; then
      echo "Warning: video is too long for target size. Bitrate would be very low."
      echo "Consider a smaller target or trimming the video."
      video_bitrate=500
    fi

    echo "Input:  $input"
    echo "Output: $output"
    echo "Duration: ''${duration_int}s"
    echo "Target: ''${target_mb}MB → video bitrate: ''${video_bitrate}k"

    ffmpeg -i "$input" \
      -c:v libx264 -b:v "''${video_bitrate}k" \
      -c:a aac -b:a "''${audio_bitrate}k" \
      -movflags +faststart \
      "$output"

    input_size=$(stat --printf="%s" "$input" 2>/dev/null || stat -f "%z" "$input")
    output_size=$(stat --printf="%s" "$output" 2>/dev/null || stat -f "%z" "$output")
    echo ""
    echo "Done: $(( input_size / 1048576 ))MB → $(( output_size / 1048576 ))MB"
  '';
}
