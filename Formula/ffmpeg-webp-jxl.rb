class FfmpegWebpJxl < Formula
  desc "Play, record, convert, and stream audio and video (ffmpeg plus libwebp & libjxl)"
  homepage "https://ffmpeg.org/"
  # Keep url/sha256 in sync with homebrew-core's ffmpeg formula:
  # https://github.com/Homebrew/homebrew-core/blob/main/Formula/f/ffmpeg.rb
  url "https://ffmpeg.org/releases/ffmpeg-9.0.2.tar.xz"
  sha256 "8c3850283eb25fa026482078a04051e0be17347b09ef81a0849bec15a96e002e"
  # None of these parts are used by default, you have to explicitly pass `--enable-gpl`
  # to configure to activate them. In this case, FFmpeg's license changes to GPL v2+.
  # Passing `--enable-version3` changes the license to GPL v3+.
  license "GPL-3.0-or-later"
  head "https://github.com/FFmpeg/FFmpeg.git", branch: "master"

  # Track upstream releases through homebrew-core's ffmpeg formula.
  livecheck do
    formula "ffmpeg"
  end

  # Same dependencies as homebrew-core's ffmpeg ...
  depends_on "pkgconf" => :build
  depends_on "dav1d"
  depends_on "jpeg-xl"
  depends_on "lame"
  depends_on "libvmaf"
  depends_on "libvpx"
  depends_on "openssl@4"
  depends_on "opus"
  depends_on "sdl2-compat"
  depends_on "svt-av1"
  depends_on "webp"
  depends_on "x264"
  depends_on "x265"
  depends_on "xz"

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"

  on_linux do
    depends_on "alsa-lib"
    depends_on "libxcb"
    depends_on "zlib-ng-compat"
  end

  on_intel do
    depends_on "nasm" => :build
  end

  conflicts_with "ffmpeg", because: "both install the same ffmpeg binaries and libraries"

  deny_network_access!

  def install
    # The new linker leads to duplicate symbol issue https://github.com/homebrew-ffmpeg/homebrew-ffmpeg/issues/140
    ENV.append "LDFLAGS", "-Wl,-ld_classic" if DevelopmentTools.ld64_version.between?("1015.7", "1022.1")

    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-pthreads
      --enable-version3
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --enable-ffplay
      --enable-gpl
      --enable-libsvtav1
      --enable-libopus
      --enable-libx264
      --enable-libmp3lame
      --enable-libdav1d
      --enable-libvmaf
      --enable-libvpx
      --enable-libx265
      --enable-openssl
      --enable-libjxl
      --enable-libwebp
    ]

    # Needs corefoundation, coremedia, corevideo
    args += %w[--enable-videotoolbox --enable-audiotoolbox] if OS.mac?
    args << "--enable-neon" if Hardware::CPU.arm?

    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools
    system "make", "alltools"
    bin.install (buildpath/"tools").children.select { |f| f.file? && f.executable? }
    pkgshare.install buildpath/"tools/python"
  end

  def caveats
    <<~EOS
      This is a custom ffmpeg build: homebrew-core's ffmpeg plus libwebp and libjxl.
      It conflicts with the `ffmpeg` formula, so uninstall that first.
    EOS
  end

  test do
    # Create a 5 second test MP4
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=5", mp4out
    assert_path_exists mp4out, "Failed to create video.mp4!"

    # The libraries this formula adds must be compiled in and actually work
    encoders = shell_output("#{bin}/ffmpeg -hide_banner -encoders")
    assert_match "libwebp", encoders
    assert_match "libjxl", encoders

    webpout = testpath/"frame.webp"
    system bin/"ffmpeg", "-i", mp4out, "-frames:v", "1", "-c:v", "libwebp", webpout
    assert_path_exists webpout, "Failed to create frame.webp!"

    jxlout = testpath/"frame.jxl"
    system bin/"ffmpeg", "-i", mp4out, "-frames:v", "1", "-c:v", "libjxl", jxlout
    assert_path_exists jxlout, "Failed to create frame.jxl!"
  end
end
