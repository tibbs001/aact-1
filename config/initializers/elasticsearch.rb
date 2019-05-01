if !ENV['ELASTICSEARCH_URL'].nil?
  url = ENV['ELASTICSEARCH_URL']
else
  url = 'http://localhost:9200'
end
Elasticsearch::Model.client = Elasticsearch::Client.new url: url
Searchkick.client = Elasticsearch::Client.new(hosts: url, retry_on_failure: true, transport_options: {request: {timeout: 250}})
