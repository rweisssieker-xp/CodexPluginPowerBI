# Privacy

The plugin works on local files, local Power BI Desktop XMLA/ADOMD endpoints, and optional user-supplied Fabric snapshot inputs.

Fabric live v1 is read-only and token-file based. The plugin does not perform an implicit sign-in flow, does not create tokens, and does not write token values to generated findings. Fabric REST access is limited to GET requests; unsafe methods are blocked and reported as `BlockedUnsafeMethod`.

It does not publish reports, promote content, trigger refreshes, rebind artifacts, delete assets, change endorsements, refresh credentials, or upload model data by itself. Generated files and Fabric snapshots are written to local output folders selected by the user.
