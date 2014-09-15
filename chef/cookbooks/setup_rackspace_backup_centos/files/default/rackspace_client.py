import urllib2
import json


class RackspaceAPIClient():
    def __init__(self, username, apiKey):
        self.username = username
        self.apiKey = apiKey

        self.response = None
        self.access_token_id = None
        self.token_response = None

        self.acquire_token()

    def acquire_token(self):
        token_url = "https://identity.api.rackspacecloud.com/v2.0/tokens"

        values = {"auth": {"RAX-KSKEY:apiKeyCredentials": {
            "username": self.username,
            "apiKey": self.apiKey
        }}}

        headers = {"Content-Type": "application/json"}

        self.token_response = self.call(token_url, json.dumps(values), headers)
        self.access_token_id = self.token_response["access"]["token"]["id"]

    def get_endpoint_for(self, name):
        catalog = self.token_response["access"]["serviceCatalog"]

        for resource in catalog:
            if resource["name"] == name:
                return resource["endpoints"][0]["publicURL"]

    def get(self, url):
        headers_backup = {"X-Auth-Project-Id": "nova-production",
                          "X-Auth-Token": self.access_token_id}

        self.response = self.call(url, None, headers_backup)


    def post(self, url, values):
        data = json.dumps(values)
        headers = {"Content-Type": "application/json", "X-Auth-Project-Id": "nova-production",
                    "X-Auth-Token": self.access_token_id}

        self.response = self.call(url, data, headers)


    def call(self, url, data, headers):

        headers["Accept"] = "application/json"
        headers["User-Agent"] = "python-novaclient"

        request = urllib2.Request(url, data, headers)
        response = urllib2.urlopen(request)
        self.response = json.loads(response.read())
        return self.response

    def get_response(self):
        return self.response
