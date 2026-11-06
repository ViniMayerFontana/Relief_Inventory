// No-op Cordis plugin: this bundle carries configuration only. Every row it
// contributes comes from cordis.patch.yml (see package.json "dsh.bundle.patch"),
// and all referenced packages are already mounted by the standard deployment.
export default function noop() {}
