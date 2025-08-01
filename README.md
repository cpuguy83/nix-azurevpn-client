#  Azure VPN Nixos flake

This flake provides a module to configure the Azure VPN client on Nixos.
The underlying package is derived from the deb package published to
packages.microsoft.com and should be considered "unfree" software.

## Usage

Add the flake to your inputs:

```nix
{
  inputs.azurevpnclient.url = "github:cpuguy83/nix-azurevpn-client";
}
```

Then add the module to your configuration:

```nix
{
  imports = [
    inputs.azure-vpn.nixosModules.azurevpnclient
  ];
}
```

And finally set:

```nix
programs.azurevpnclient.enable = true;
```

This will:

- Install the Azure VPN client package.
- Configure the Azure VPN client binary to enable the CAP_NET_ADMIN capability,
  which is required for the client to function properly.
- Ensure that systemd-resolvd is used for DNS resolution.
- Add a polkit policy to allow users in the (default) `wheel` group to make changes
  to DNS configuration. Users must be in this group for the Azure VPN client to
  function properly.

## Options

Set a custom package source:

```nix
{
  programs.azurevpnclient.package = myCustomPackage;
}
```


Change the default group for polkit:

```nix
{
  programs.azurevpnclient.polkitGroup = "myCustomGroup";
}
```
