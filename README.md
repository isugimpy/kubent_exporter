# kubent_exporter
Simple wrapper around [kubent](https://github.com/doitintl/kube-no-trouble) to export prometheus metrics.  Exposed at the `/metrics` endpoint.

## Configuration
Only two config values are available, the frequency to check values and the port.  These are presented as environment variables.
`KUBENT_EXPORTER_FREQUENCY_MINUTES` - Number of minutes between runs of kubent (default: 5)
`KUBENT_EXPORTER_PORT` - Port to listen to for metrics requests (default: 8000)
