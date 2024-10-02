{ lib
, stdenv
, fetchFromGitHub
, bash
, git
}:

stdenv.mkDerivation {
  pname = "git-squash";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "sheerun";
    repo = "git-squash";
    rev = "master";
    sha256 = "sha256-yvufKIwjP7VcIzLi8mE228hN4jmaqk90c8oxJtkXEP8=";
  };

  nativeBuildInputs = [ bash git ];

  installPhase = ''
    mkdir -p $out/bin
    cp git-squash $out/bin/git-squash
    chmod +x $out/bin/git-squash
  '';

  meta = with lib; {
    description = "A Git command for squashing commits";
    homepage = "https://github.com/sheerun/git-squash";
    license = licenses.mit; # Adjust if the actual license is different
    platforms = platforms.all;
    maintainers = [ ]; # You can add maintainers if needed
  };
}
