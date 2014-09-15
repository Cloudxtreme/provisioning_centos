require "json"
require "net/http"
require "uri"

def get_agent_id machine, client
    user_agents_url = "#{client.get_endpoint_for 'cloudBackup'}/user/agents"

    response = client.get user_agents_url

    for agent in response
        if agent["MachineName"] == machine
            return agent["MachineAgentId"]
        end
    end
    return nil
end

class RackspaceAPIClient
    def initialize username, apiKey
        @username = username
        @apiKey = apiKey
        @access_token_id = acquire_token
    end
    
    def acquire_token
        token_url = "https://identity.api.rackspacecloud.com/v2.0/tokens"

        values = {"auth"=> {"RAX-KSKEY:apiKeyCredentials"=> {
            "username"=> @username,
            "apiKey"=> @apiKey
        }}}

        @token_response = post token_url, values
        @token_response["access"]["token"]["id"]
    end

    def post url, data, headers={}
        headers = {"Content-Type" => "application/json"}
        uri = URI.parse url
        req = Net::HTTP::Post.new uri.path
        call url, data, headers, req, uri
    end

    def get url, data={}, headers={}
        uri = URI.parse(url)
        req = Net::HTTP::Get.new uri.path
        call url, data, headers, req, uri
    end

    def delete url, data={}, headers={}
        headers = {"Content-Type" => "application/json"}
        uri = URI.parse url
        req = Net::HTTP::Delete.new uri.path
        call url, data, headers, req, uri
    end

    def call url, data, headers, req, uri
        headers["Accept"] = "application/json"
        headers["User-Agent"] = "fog/1.12.1"
        headers["X-Auth-Token"] = @access_token_id unless @access_token_id.nil?

        uri.port = Net::HTTP.https_default_port()
        http = Net::HTTP.new(uri.hostname, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        req.initialize_http_header headers
        req.body = data.to_json
        resp = http.request req
        
        resp.body.nil? ? nil : JSON.parse(resp.body)
    end

    def get_endpoint_for name
        catalog = @token_response["access"]["serviceCatalog"]

        for resource in catalog
            if resource["name"] == name
                return resource["endpoints"][0]["publicURL"]
            end
        end
    end
end

client = RackspaceAPIClient.new(ARGV[0], ARGV[1])

backup_url = client.get_endpoint_for "cloudBackup"
machine = ARGV[2]
agent_id = get_agent_id machine, client
values = { "MachineAgentId" => agent_id }
client.post "#{backup_url}/agent/delete", values
