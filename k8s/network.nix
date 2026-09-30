# Host-side complement to app NetworkPolicies, for the default K3s/Flannel CNI.
# Never trust the pod bridges wholesale: global host allowances (SSH, web, etc.)
# must not expose those services to pods. Keep only API/kubelet ports for cluster
# infrastructure; app egress policies deny those too, including the API Service.
# Run before ordinary filter chains, so their ACCEPT rules cannot bypass this guard.
{ ... }:
{
  networking.nftables = {
    enable = true;
    tables.k3s-host-guard = {
      family = "inet";
      content = ''
        chain input {
          type filter hook input priority -10; policy accept;
          iifname { "cni0", "flannel.1" } ct state established,related accept
          iifname { "cni0", "flannel.1" } tcp dport { 6443, 10250 } accept
          iifname { "cni0", "flannel.1" } counter reject with icmpx type admin-prohibited
        }
      '';
    };
  };
  networking.firewall.interfaces = {
    cni0.allowedTCPPorts = [ 6443 10250 ];
    "flannel.1".allowedTCPPorts = [ 6443 10250 ];
  };
}
