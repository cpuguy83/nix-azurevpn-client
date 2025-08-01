{ pkgs, lib, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "microsoft-azurevpnclient";
  version = "3.0.0";

  src = pkgs.fetchurl {
    url = "https://packages.microsoft.com/ubuntu/22.04/prod/pool/main/m/microsoft-azurevpnclient/microsoft-azurevpnclient_3.0.0_amd64.deb";
    sha256 = "0yspjkyfkw6iam8s7spbfk582ghhcndb46q5l7cp9lyi6c23cpcy";
  };

  nativeBuildInputs = with pkgs; [
    dpkg
    autoPatchelfHook
    wrapGAppsHook
  ];

  buildInputs = with pkgs; [
    atk
    glib
    gtk3
    pango
    cairo
    libepoxy
    fontconfig
    freetype
    harfbuzz
    libsecret
    gcc
    stdenv.cc.cc.lib

    # Additional required libs
    libcap
    curl
    sqlite
    openssl_3
    systemd
    zlib
    zenity
  ];

  unpackPhase = ''
    mkdir extract-root
    dpkg-deb -x $src extract-root
  '';

  installPhase = ''
    # create output directory
    install -d $out/opt/microsoft/microsoft-azurevpnclient

    cp -r extract-root/opt/microsoft/microsoft-azurevpnclient/* $out/opt/microsoft/microsoft-azurevpnclient/

    paths=${lib.makeLibraryPath (with pkgs; [
      gtk3 glib gcc stdenv.cc.cc.lib libsecret pango atk cairo libepoxy fontconfig freetype harfbuzz
    ])}

    binPaths=${lib.makeBinPath (with pkgs;[
      zenity
      xdg-utils
      gtk3
      glib
      libsecret
    ])}

    patchelf --set-rpath "$paths:$out/opt/microsoft/microsoft-azurevpnclient/lib" \
      $out/opt/microsoft/microsoft-azurevpnclient/microsoft-azurevpnclient

    makeWrapper $out/opt/microsoft/microsoft-azurevpnclient/microsoft-azurevpnclient \
      $out/bin/azurevpnclient \
      --set LD_LIBRARY_PATH "$paths:$out/opt/microsoft/microsoft-azurevpnclient/lib" \
      --prefix PATH : "$binPaths"

    install -Dm644 extract-root/usr/share/icons/microsoft-azurevpnclient.png \
      $out/share/icons/hicolor/512x512/apps/azurevpnclient.png

    # Install .desktop file
    install -Dm644 /dev/stdin $out/share/applications/azurevpnclient.desktop <<EOF
[Desktop Entry]
Name=Azure VPN Client
Exec=azurevpnclient
Icon=azurevpnclient
Type=Application
Categories=Network;
StartupNotify=true
EOF
  '';


  meta = with lib; {
    description = "Microsoft Azure VPN Client for Linux (GUI)";
    homepage = "https://learn.microsoft.com/en-us/azure/vpn-gateway/openvpn-azure-ad-client";
    platforms = platforms.linux;
    license = licenses.unfree; # it's Microsoft software
  };
}
