self: super:

{
  roon-server = super.roon-server.overrideAttrs (old: rec {
    version = "100700537";
    src = super.fetchurl {
      url = "http://download.roonlabs.com/updates/stable/RoonServer_linuxx64_${version}.tar.bz2";
      sha256 = "07b84ab738120e49e362a25b637d4293594d8d3dc8e6be428c5a0cb01a2e9b64";
    };
  });
}
