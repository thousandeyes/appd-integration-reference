#!/usr/bin/env python3
#
# teappd-monitor.py - a Python script for querying ThousandEyes test metrics, transforming metrics JSON payload, and pushing to AppD.
# 

import os, time, sys, base64, json,requests
from datetime import datetime

te_apiURL = 'https://api.thousandeyes.com'
te_apiVersion = 'v6'
te_fullApiURL = te_apiURL + '/' + te_apiVersion + '/'

# Python Wrapper for ThousandEyes API
class TeApi:
    def __init__(self, username, authToken, accountName, params={}):
        self.te_user=username
        self.te_authToken=authToken
        self.te_params=params
        self.te_params.update({'aid' : self.getAccountId(accountName)})

    def getRequestHeaders(self):
        authorization = None
        auth_string = self.te_user + ':' + self.te_authToken
        authorization = (base64.b64encode(auth_string.encode('ascii'))).decode('ascii')
        return {'accept':'application/json', 'content-type':'application/json', 'Authorization':'Basic {}'.format(authorization) }

    def get (self, apiPath) :
        api_url = te_fullApiURL + apiPath
        request_headers = self.getRequestHeaders()
        params = self.te_params

        #print ("API: " + api_url)
        api_response = requests.get(api_url, headers=request_headers) if params is None else requests.get(api_url, headers=request_headers, params=params)
        #print (api_response)
        return api_response.json()

    def getAccounts (self):
        return self.get('account-groups')

    def getAccountId (self, accountName):
        accounts = self.getAccounts()['accountGroups']
        return next((a['aid'] for a in accounts if a['accountGroupName'] == accountName), None)
        
    def getTests (self):
        return self.get('tests')

    def getTestDetails (self, testId): 
        return self.get('tests/' + testId)

    def getAgentDetails (self, agentId): 
        return self.get('agents/' + agentId)

    def getTestNetData(self, testId):
        return self.get('net/metrics/' + str(int(testId)))

    def getTestBgpData(self, testId):
        return self.get('net/bgp-metrics/' + str(int(testId)))
        
    def getTestPageloadData(self, testId):
        return self.get('web/page-load/' + str(int(testId)))
    
    def getTestHttpData (self, testId) :
        return self.get('web/http-server/' + str(int(testId)))

    def getTestSummaryPathTrace(self, testId):
        return self.get('net/path-vis/' + str(int(testId)))

    def getTestDetailedPathTrace(self, testId, agentId, roundId):
        return self.get('net/path-vis/' + str(int(testId)) + "/" + str(int(agentId)) + "/" + str(int(roundId)))

# Helper function for updating the aggregated JSON metrics data
def update_dict (dictionary, key, data):
    if key in dictionary : 
        if type(dictionary[key]) is list : dictionary[key].extend(data)
        else : dictionary[key].update(data)
    else :
        dictionary[key] = data

# Query agent details, including agent label. In addition, if label name is the form of a JSON element ("<tag>: <value>") 
# then convert the label to a <key>:<value> tag as well. Passed agenddata object is updated with agent details and label/tag info.
def query_agent_details (teApi, agentdata):
    agentdata.update (teApi.getAgentDetails (str(agentdata['agentId']))['agents'][0])
    agentdata['tags'] = {}
    for group in (group for group in agentdata['groups'] if group['groupId'] > 0):
        agentdata['tags'].update({ group['name'].split(': ')[0] : group['name'].split(': ')[1] }) if ':' in group['name']  else agentdata['tags'].update({ group['name'] : group['name'] })


    # "application": "string", 
    # "tier": "string", 
    # Convention: testname = <application>-<tier>
    # Example: adcapital-frontend

def query_latest_data(username, authtoken, accountname, testname):
    try :
        aggdata = {}
        teApi = TeApi(username, authtoken, accountname)
        tests = teApi.getTests()['test']
        test = next((t for t in tests if t['testName'] == testname), None)
        testDetails = teApi.getTestDetails (str(test['testId']))['test'][0]
        # print (json.dumps(testDetails['agents']))
        # Aggregate Test Labels and Tags. If label name is the form of a JSON element ("<tag>: <value>") then aggregate into "tags"
        # testDetails['tags'] = {}
        # testDetails['groups'] = {}
        # for group in (group for group in testDetails['groups'] if group['groupId'] > 0):
        #     testDetails['tags'].update({ group['name'].split(': ')[0] : group['name'].split(': ')[1] }) if ':' in group['name']  else testDetails['tags'].update({ group['name'] : group['name'] })
        appinfo=testname.split('-')
        if (len(appinfo) < 3) : 
            appinfo.extend((3-len(appinfo)) * [None])

        for agentdata in testDetails['agents']:

            # TODO: Iterate over json schema to force conformity

            key = testname + " - " + agentdata['agentName']

            # Uncomment this to get full agent details, including tags/labels
            #query_agent_details (teApi, agentdata)

            # update_dict(agentdata, 'groups', testDetails['groups'])
            # update_dict(agentdata, 'tags', testDetails['tags'])

            update_dict(aggdata, key, {'testName':testname})
            update_dict(aggdata, key, {'app':appinfo[0]})
            update_dict(aggdata, key, {'tier':appinfo[1]})
            update_dict(aggdata, key, {'node':appinfo[2]})

            update_dict(aggdata, key, {'agentName':agentdata['agentName']})

            update_dict(aggdata, key, {'date':''}) # force date to be third element in object.

            # Use 'target' instead of 'url' and 'server', 'serverIp'
            if 'url' in test: update_dict(aggdata, key, {'target':testDetails['url']})
            if 'server' in test: update_dict(aggdata, key, {'target':testDetails['server']})
            if 'serverIp' in test: update_dict(aggdata, key, {'target':testDetails['serverIp']})

            # ensure these metrics are always present in the JSON object:

            update_dict(aggdata, key, {'connectTime':''}) 
            update_dict(aggdata, key, {'errorDetails':''})
            update_dict(aggdata, key, {'receiveTime':''}) 
            update_dict(aggdata, key, {'responseTime':''})
            #update_dict(aggdata, key, {'throughput':''})

            if test['type'] == 'page-load' or (test['type'] == 'web-transactions') :
                testdata = teApi.getTestPageloadData(test['testId'])
                if testdata :
                    for agentdata1 in testdata['web']['pageLoad'] :
                        key = testname + " - " + agentdata1['agentName'] 
                        update_dict(aggdata, key, agentdata1)
                        update_dict(aggdata, key, {'target':testdata['web']['test']['url']})

            if (test['type'] == 'page-load') or (test['type'] == 'web-transactions') or (test['type'] == 'http-server') :
                httpdata = teApi.getTestHttpData(test['testId'])
                if httpdata :
                    for agentdata2 in httpdata['web']['httpServer'] :
                        key = testname + " - " + agentdata2['agentName'] 
                        update_dict(aggdata, key, agentdata2)

            if (test['type'] == 'page-load') or (test['type'] == 'web-transactions') or (test['type'] == 'http-server') or (test['type'] == 'agent-to-server') :
                networkdata = teApi.getTestNetData(test['testId'])
                if networkdata:
                    for agentdata3 in networkdata['net']['metrics'] :
                        key = testname + " - " + agentdata3['agentName'] 
                        # Convert date time to ISO 
                        agentdata3['date'] = datetime.strptime (agentdata3['date'], '%Y-%m-%d %H:%M:%S').isoformat()
                        update_dict(aggdata, key, agentdata3)
            else :
                print (json.dumps({"error": "Test " + testname + " (" + test['type'] + ") is not a Pageload, HTTP, or Network test"}))



    except Exception as e:
        print (json.dumps({"error": "Could not load test {} from account {}. (Exception: {})".format(testname, accountname, e)}))
        #print (json.dumps())
        
    
    #print (json.dumps(aggdata))
    return aggdata


if __name__ == '__main__':
    if len(sys.argv) < 5:
        print (json.dumps({"Usage": "te-monitor <account name> <login email> <api token> <testname 1> <testname N>"}))
    
    accountgroup = sys.argv[1]
    username = sys.argv[2]
    authtoken = sys.argv[3]
    tests = sys.argv[4:len(sys.argv)]
    targeturl = "https://new-feature-testing.appspot.com/tepush"

    testdata = []
    schemaname = "thousandeyes"
    schema=""

    # https://docs.appdynamics.com/display/PRO45/Analytics+Events+API
    with open('schema.json') as f_schema:
        schema = json.loads(f_schema.read())

    metrics={}
    with open('metrics.json') as f_metrics:
        metrics = json.loads(f_metrics.read())


    with open('connection.json') as f:
        connectionInfo = json.loads(f.read())
        try :
            os.system('curl -s -X POST "' + connectionInfo['analytics-api'] + '/events/schema/' + schemaname + '" \
            -H"X-Events-API-AccountName:' + connectionInfo['account-id'] + '" \
            -H"X-Events-API-Key:' + connectionInfo['api-key'] + '" -H"Content-type: application/vnd.appd.events+json;v=2" \
            -d \'{"schema" : ' + json.dumps(schema) + '} \' &>/dev/null')

        # PATCH http://analytics.api.example.com/events/schema/{schemaName}
        # X-Events-API-AccountName:<global_account_name>
        # X-Events-API-Key:<api_key>
        except :
            print ()

    for test in tests :
        # aggregate test data across all tests as an array of flattened test metric objects
        testdata.extend(list((query_latest_data (username, authtoken, accountgroup, test)).values()))
    
    print ("\n\n")
    #print (json.dumps(testdata))
    for testround in testdata :
        for metric in metrics :
            if metric in testround and testround[metric] != "":
                print ("name=Custom Metrics|{0}|{1}|{2}, value={3}".format(testround['testName'], testround['agentName'].replace(',', ' '), metrics[metric], testround[metric]))

    # Uncomment following to also push to Analytics API:
    #     post = "curl -s -X POST \"{0}/events/publish/{1}\" -H\"X-Events-API-AccountName: {2}\" -H\"X-Events-API-Key: {3}\" -H\"Content-type: application/vnd.appd.events+json;v=2\" -d \'[{4}]\'".format(
    #         connectionInfo['analytics-api'],
    #         schemaname, 
    #         connectionInfo['account-id'],
    #         connectionInfo['api-key'],
    #         json.dumps(testround))
    #     os.system (post)

