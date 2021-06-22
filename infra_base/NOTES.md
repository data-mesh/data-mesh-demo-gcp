On destroy the default network cannot be deleted because 
    we suspect the jupter notebook consuming from a buck created a compute VM
    the firewall for default-allow-https uses it
    the firewall for default-allow-http uses it
On destroy terraform delete the infra service account storage.admin role before successfully destroy the storage bucket
