default['write_http']['AWS_integration'] = true
# We're trying to move away from being locked into the proprietary SignalFx metrics
# product, and open up options to send our metrics anywhere.
#
# To do this we're running OpenTelemetry on Kubernetes that accepts CollectD
# metrics and exports them to SignalFx, so in the future we could flip where they're
# exported to.
#
# This also means that we only need to manage the SignalFx API key on the
# Kubernetes deployment of OpenTelemetry rather than keep it up to date on
# every server
if node.chef_environment.downcase == "prod"
  default['write_http']['Ingest_host'] = 'http://opentelemetry-collector.app.hudl.com:8081'
else
  default['write_http']['Ingest_host'] = 'http://opentelemetry.app.thorhudl.com:8081'
end
default['write_http']['API_TOKEN'] = ''

default['collectd_version'] = 'latest'

default['SignalFx']['collectd']['interval'] = 10
default['SignalFx']['collectd']['timeout'] = 2
default['SignalFx']['collectd']['FQDNLookup'] = true

default['SignalFx']['collectd']['logfile']['LogLevel'] = 'info'
default['SignalFx']['collectd']['logfile']['File'] = '/var/log/collectd.log'
default['SignalFx']['collectd']['logfile']['PrintSeverity'] = false

# set this to true to enable the dogstatsd compatible statsd listener
default['SignalFx']['collectd']['enable_statsd'] = false
default['SignalFx']['collectd']['statsd_port'] = 8125

default['SignalFx']['collectd']['protocols']['values'] = [
  "Icmp:InDestUnreachs",
  "Tcp:CurrEstab",
  "Tcp:OutSegs",
  "Tcp:RetransSegs",
  "TcpExt:DelayedACKs",
  "TcpExt:DelayedACKs",
  "/Tcp:.*Opens/",
  "/^TcpExt:.*Octets/",
]
