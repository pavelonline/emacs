{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "sqls";
  version = "0.2.19";
  src = fetchFromGitHub {
    owner = "lighttiger2505";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-XxENOtzJT0QMGixUjkiPNaF4hwKjIZhgoXC5NhO+3tc=";
  };
  vendorSha256 = "sha256-nxHkd31th8x4xKX8H3KSus4MPgz8tEXGB0ZIq8C2h40=";
}
