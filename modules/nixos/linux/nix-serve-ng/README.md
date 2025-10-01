# nix-serve-ng with Cloudflare Tunnel

NixOS module that sets up a Nix binary cache server using `nix-serve-ng` and exposes it through a Cloudflare tunnel.

## Features

- Runs `nix-serve-ng` to serve Nix store paths over HTTP
- Automatically configures Cloudflare tunnel for secure external access
- Signs cache content with a private key for verification
- Integrated with agenix for secure secret management

## Configuration

```nix
services.nix-serve-ng-cf = {
  enable = true;
  port = 5000;  # Local port (default: 5000)
  secretKeyPath = "nix-serve-cache-key.pem";  # Relative to secrets/
  
  cloudflare = {
    tunnelId = "your-tunnel-id";
    credentialsPath = "cloudflared-nix-cache.json";  # Relative to secrets/
    domain = "cache.example.com";
  };
};
```

## Setup Steps

1. **Generate cache signing key**:
   ```bash
   nix-store --generate-binary-cache-key cache.example.com cache-priv-key.pem cache-pub-key.pem
   ```
   Keep `cache-pub-key.pem` for clients. The private key will be encrypted with agenix.

2. **Authenticate with Cloudflare** (first time only):
   ```bash
   nix run nixpkgs#cloudflared -- tunnel login
   ```
   This opens a browser to authenticate and downloads a certificate to `~/.cloudflared/cert.pem`.

3. **Create Cloudflare tunnel**:
   ```bash
   nix run nixpkgs#cloudflared -- tunnel create nix-cache
   ```
   This creates a tunnel and generates credentials in `~/.cloudflared/`.
   Note the tunnel ID from the output.

4. **Encrypt secrets with agenix**:
   ```bash
   # Encrypt the cache signing key
   agenix -e secrets/nix-serve-cache-key.pem.age
   # Paste the contents of cache-priv-key.pem, save and exit
   
   # Encrypt the Cloudflare credentials
   agenix -e secrets/cloudflared-nix-cache.json.age
   # Paste the contents of ~/.cloudflared/<tunnel-id>.json, save and exit
   ```

5. **Configure the module** with your tunnel ID and domain (see Configuration above).

6. **Add DNS record** in Cloudflare dashboard:
   - Type: CNAME
   - Name: your subdomain (e.g., `cache`)
   - Target: `<tunnel-id>.cfargotunnel.com`

7. **Test the cache**:
   ```bash
   # Test that nix-serve-ng is responding
   curl https://cache.example.com/nix-cache-info
   ```
   You should see output like:
   ```
   StoreDir: /nix/store
   WantMassQuery: 1
   Priority: 30
   ```

## Using the Cache

On client machines, add to `/etc/nixos/configuration.nix`:

```nix
nix.settings = {
  substituters = [ "https://cache.example.com" ];
  trusted-public-keys = [ "cache.example.com:base64-encoded-public-key" ];
};
```

The public key content is in `cache-pub-key.pem` generated in step 1.

## Options

- **`enable`**: Enable the nix-serve-ng with Cloudflare tunnel service
- **`port`**: Local port for nix-serve-ng (default: 5000)
- **`secretKeyPath`**: Path to encrypted cache signing key relative to `secrets/` (default: "nix-serve-cache-key.pem")
- **`cloudflare.tunnelId`**: Your Cloudflare tunnel ID
- **`cloudflare.credentialsPath`**: Path to encrypted tunnel credentials relative to `secrets/` (default: "cloudflared-nix-cache.json")
- **`cloudflare.domain`**: Public domain name for the cache
