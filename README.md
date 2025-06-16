<div align="center">
	<p>
		<img alt="Thoughtworks Logo" src="https://raw.githubusercontent.com/twplatformlabs/static/master/psk_banner.png" width=800 />
		<h3>psk-platform-on-cluster-observability-demo</h3>
	</p>
</div>

On-cluster, all-in-one observability demo. This is not a production or platform-oriented configuration and is intented only to provide a simulated observability service for developing starter kits or testing integration patterns.  

**Includes**

* prometheus
* alertmanager
* grafana

**Maintainers**  

Access to the Prometheus and Alertmanager UI is managed using oauth2-proxy services running on the cluster. The proxy uses the pskctl Auth0 IDP integration to enable only members of the twplatformlabs `platform` team access.

Grafana has a built-in oauth2/oidc integration for GitHub, which is similarly used to provide UI access to platform team members.

Prometheus does not support EFS pvcs. As this is just a non-prod demo to enable other experimental resoures to develop against the obs endpoints, we are using EFS anyway and have set the following pod deployment conditions to prevent the otherwise crash response to WAL issues:  

```yaml
  extraArgs:
    storage.tsdb.min-block-duration: 15m # during a restart, a max 15m of prometheus data will be lost
    storage.tsdb.max-block-duration: 15m
  lifecycle:
    postStart:
      exec:
        command: ["bash", "-c", "rm -rf /data/wal"] # WAL block files deleted startup to prevent pod failure
```