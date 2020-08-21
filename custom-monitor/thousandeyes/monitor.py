#!/usr/bin/env python3
#
# teappd-monitor.py - a Python script for querying ThousandEyes test metrics, transforming metrics JSON payload, and pushing to AppD.
# 
# References:
# 
# https://docs.appdynamics.com/display/PRO45/Analytics+Events+API

import os, time, sys, base64, json,requests
from datetime import datetime
from unidecode import unidecode

te_apiURL = 'https://api.thousandeyes.com'
te_apiVersion = 'v6'
te_fullApiURL = te_apiURL + '/' + te_apiVersion + '/'

ANALYTICS_API="https://analytics.api.appdynamics.com"

LOGFILE = "monitor.log" # or /dev/null
ENABLE_LOGGING = True
DEFAULT_METRIC_TEMPLATE = "name=Custom Metrics|{tier}|{agent}|{metricname},value={metricvalue}"
DEFAULT_SCHEMA_NAME = "thousandeyes"
ANALYTICS_ENABLED = True

CONFIG_FILE = "config.json"
SCHEMA_FILE = "schema.json"
METRICS_FILE= "metrics.json"


# For analysis purposes - counts the number of metrics reported by ThousandEyes API query per agent per test round 
AGENT_METRIC_COUNT_PER_TESTROUND = {}

# Wrapper class for ThousandEyes API
class TeApi:
    def __init__(self, username, authToken, accountName=None, params={}):
        self.te_user=username
        self.te_authToken=authToken
        self.te_params=params
        if accountName : self.te_params.update({'aid' : self.getAccountId(accountName)})

    def getRequestHeaders(self):
        authorization = None
        auth_string = self.te_user + ':' + self.te_authToken
        authorization = (base64.b64encode(auth_string.encode('ascii'))).decode('ascii')
        return {'accept':'application/json', 'content-type':'application/json', 'Authorization':'Basic {}'.format(authorization) }

    def get (self, apiPath) :
        api_url = te_fullApiURL + apiPath
        request_headers = self.getRequestHeaders()
        params = self.te_params
        api_response = requests.get(api_url, headers=request_headers) if params is None else requests.get(api_url, headers=request_headers, params=params)
        return api_response.json()

    def getFullUrl (self, fullUrl) :
        api_url = fullUrl
        request_headers = self.getRequestHeaders()
        params = self.te_params
        api_response = requests.get(api_url, headers=request_headers) if params is None else requests.get(api_url, headers=request_headers, params=params)
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


# Extract app, tier, and node from test metadata OR test name
#
# metadata json schema:
# { "appd_application":"<appd application name>", "appd_tier":"<appd application tier>", "appd_node":"<appd tier node>" }
# 
# OR
#
# Convention: testname = <application>-<tier>
def extractTestMetadata(testDetails):
    try:
        metadata=json.loads(testDetails['description'])
        appinfo=dict (zip (['app','tier','node'], [metadata['appd_application'],metadata['appd_tier'],metadata['appd_node']]))
    except:
        appinfo=dict (zip (['app','tier','node'], zip(testDetails['testName'].split('-'))))
        
    if (len(appinfo) < 3) : 
        appinfo.extend((3-len(appinfo)) * [None])

    return appinfo

# Helper function for updating dict; checks for key and also supports updating lists by extending
def update_dict (dictionary, key, data):
    if key in dictionary : 
        if type(dictionary[key]) is list : dictionary[key].extend(data)
        else : dictionary[key].update(data)
    else :
        dictionary[key] = data

# Helper function for updating the aggregated data
# agentTestData == (eg.) testdata['web']['pageLoad']
def update_aggregated_metrics (aggdata, agentTestData, testDetails, appinfo):
    for agentdata in agentTestData :
        key = testDetails['testName'] + "-" + agentdata['agentName'] + "-" + str(agentdata['roundId'])

        # Reformat 'date' to ISO
        agentdata['date'] = datetime.strptime (agentdata['date'], '%Y-%m-%d %H:%M:%S').isoformat()
        update_dict(aggdata, key, {'roundId':''}) 
        update_dict(aggdata, key, {'testName':testDetails['testName']})
        update_dict(aggdata, key, {'agentName':''})
        update_dict(aggdata, key, {'date':''}) 
        update_dict(aggdata, key, {'app':appinfo['app']})
        update_dict(aggdata, key, {'tier':appinfo['tier']})
        update_dict(aggdata, key, {'node':appinfo['node']})
        if 'url' in testDetails: update_dict(aggdata, key, {'target':testDetails['url']})
        if 'server' in testDetails: update_dict(aggdata, key, {'target':testDetails['server']})
        update_dict(aggdata, key, agentdata)


def print_custom_metrics (testround, metrics, metric_template):
    for metric in metrics :
        if metric in testround and testround[metric] and testround[metric] != "":
            if isinstance(testround[metric], float): testround[metric] = int(testround[metric])
            
            # app, tier, agent, metricname, metricvalue - match template
            app = testround['app']
            tier = testround['tier']
            agent = unidecode(testround['agentName'].replace(',', ' '))
            metricname = metrics[metric]
            metricvalue = testround[metric]
            metric_count_key=str(testround['roundId'])+"-"+agent
            AGENT_METRIC_COUNT_PER_TESTROUND[metric_count_key]=AGENT_METRIC_COUNT_PER_TESTROUND[metric_count_key]+1 if metric_count_key in AGENT_METRIC_COUNT_PER_TESTROUND else 1
                        
            metric=eval('f\''+ metric_template +'\'')
            print (metric)
            if ENABLE_LOGGING: os.system("echo \"{0}-{1}\" >> {2}".format(testround['roundId'], metric, LOGFILE))


def post_analytics_schema(schemaname, schema, connectionInfo) :
    if connectionInfo['account-id'] and connectionInfo['api-key'] :
        try :
            post = 'curl -s -X POST "' + connectionInfo['analytics-api'] + '/events/schema/' + schemaname + '" \
            -H"X-Events-API-AccountName:' + connectionInfo['account-id'] + '" \
            -H"X-Events-API-Key:' + connectionInfo['api-key'] + '" -H"Content-type: application/vnd.appd.events+json;v=2" \
            -d \'{"schema" : ' + json.dumps(schema) + '} \' >>' + LOGFILE + ' 2>>' + LOGFILE
            os.system(post)
        except :
            pass

def post_analytics_metric(testround, schemaname, connectionInfo) :
    try:
        post = "curl -s -X POST \"{0}/events/publish/{1}\" -H\"X-Events-API-AccountName: {2}\" -H\"X-Events-API-Key: {3}\" -H\"Content-type: application/vnd.appd.events+json;v=2\" -d \'[{4}]\' >> {5} 2>>{5}".format(
            connectionInfo['analytics-api'],
            schemaname, 
            connectionInfo['account-id'],
            connectionInfo['api-key'],
            json.dumps(testround),
            LOGFILE)
        os.system (post)
    except Exception as e:
        # TODO: Print error to separate log file. Stderr will corrupt Custom Metrics
        pass

# Query agent details, including agent label. In addition, if label name is the form of a JSON element ("<tag>: <value>") 
# then convert the label to a <key>:<value> tag as well. Passed agenddata object is updated with agent details and label/tag info.
def query_agent_details (teApi, agentdata):
    agentdata.update (teApi.getAgentDetails (str(agentdata['agentId']))['agents'][0])
    agentdata['tags'] = {}
    for group in (group for group in agentdata['groups'] if group['groupId'] > 0):
        agentdata['tags'].update({ group['name'].split(': ')[0] : group['name'].split(': ')[1] }) if ':' in group['name']  else agentdata['tags'].update({ group['name'] : group['name'] })


def query_latest_data (username, authtoken, accountname, testname, window_seconds = None):
    try :
        aggdata = {}
        params={'window':window_seconds} if window_seconds else {}
        teApi = TeApi(username, authtoken, accountname, params)
        tests = teApi.getTests()['test']
        test = next((t for t in tests if t['testName'] == testname), None)
        testDetails = teApi.getTestDetails (str(test['testId']))['test'][0]

        appinfo = extractTestMetadata(testDetails)

        for agentdata in testDetails['agents']:
            testdata = teApi.getTestPageloadData(test['testId'])
            if testdata :
                update_aggregated_metrics (aggdata, testdata['web']['pageLoad'], testDetails, appinfo)
                try:
                    while testdata['pages']['next']:
                        testdata = TeApi(username, authtoken).getFullUrl(testdata['pages']['next'])
                        if testdata : update_aggregated_metrics (aggdata, testdata['web']['pageLoad'], testDetails, appinfo)
                except:
                    pass

            httpdata = teApi.getTestHttpData(test['testId'])
            if httpdata :
                update_aggregated_metrics (aggdata, httpdata['web']['httpServer'], testDetails, appinfo)
                try:
                    while httpdata['pages']['next']:
                        httpdata = TeApi(username, authtoken).getFullUrl(httpdata['pages']['next'])
                        if httpdata : update_aggregated_metrics (aggdata, httpdata['web']['httpServer'], testDetails, appinfo)
                except:
                    pass

            networkdata = teApi.getTestNetData(test['testId'])
            if networkdata:
                update_aggregated_metrics (aggdata, networkdata['net']['metrics'], testDetails, appinfo)
                try:
                    while networkdata['pages']['next']:
                        networkdata = TeApi(username, authtoken).getFullUrl(networkdata['pages']['next'])
                        if networkdata : update_aggregated_metrics (aggdata, networkdata['net']['metrics'], testDetails, appinfo)
                except:
                    pass

            else :
                print (json.dumps({"error": "Test " + testname + " (" + test['type'] + ") is not a Pageload, HTTP, or Network test"}))
    except Exception as e:
        print (json.dumps({"error": "Could not load test {} from account {}. (Exception: {})".format(testname, accountname, e)}))
        raise e
        
    return aggdata

# Environment variable takes precendence over config file
def get_config_value (configKey, envKey, configInfo, default=None):
    try:
        configValue = os.environ.get(envKey) if os.environ.get(envKey) else configInfo[configKey]
        if configValue is None or configValue == "" : raise Exception("Missing config {0}".format(envKey))
        return configValue.strip('\"')
    except Exception as e:
        if default: return default
        print ("Missing required config entry. Must define '{0}' environment variable or '{1}' in {2}.".format(envKey, configKey, CONFIG_FILE))
        raise e


def load_metrics (metricsFile):
    try :
        with open(metricsFile) as f_metrics:
            return json.loads(f_metrics.read())
    except : 
        print ("Failed to load Custom Metrics definition file {0}.", metricsFile)
        raise e

if __name__ == '__main__':
    connectionInfo = {}
    with open(CONFIG_FILE) as f:
        configInfo = json.loads(f.read())

    username = get_config_value ('te-email', 'TE_EMAIL', configInfo) 
    authtoken = get_config_value ('te-api-key', 'TE_API_KEY', configInfo) 
    accountgroup = get_config_value ('te-accountgroup', 'TE_ACCOUNTGROUP', configInfo) 
    tests = json.loads(os.environ.get("TE_TESTS")) if os.environ.get("TE_TESTS") else configInfo['te-tests']
    metric_template = get_config_value ('metric-template', 'TE_METRIC_TEMPLATE', configInfo, DEFAULT_METRIC_TEMPLATE) 
    period_seconds = int(get_config_value ('metric-period', 'TE_METRIC_PERIOD', configInfo, 60)) 
    schemaname = get_config_value ('schema-name', 'TE_SCHEMA_NAME', configInfo, DEFAULT_SCHEMA_NAME) 

    analyticsInfo = {
        'analytics-api':ANALYTICS_API,
        'account-id':get_config_value ('account-id', 'APPD_GLOBAL_ACCOUNT', configInfo, "x"),
        'api-key':get_config_value ('api-key', 'APPD_API_KEY', configInfo, "x")
    }

    if analyticsInfo['account-id'] == "x" or analyticsInfo['api-key'] == "x" : ANALYTICS_ENABLED = False 

    if ANALYTICS_ENABLED : 
        with open (SCHEMA_FILE) as f_schema :
            schema = json.loads(f_schema.read())

    metrics = load_metrics(METRICS_FILE)

    if ANALYTICS_ENABLED: post_analytics_schema (schemaname, schema, analyticsInfo)

    testdata = []
    
    os.system("'' > {0}".format(LOGFILE))

    while True:
        for test in tests :
            testdata = list((query_latest_data (username, authtoken, accountgroup, test)).values())
            for testround in testdata :
                print_custom_metrics (testround, metrics, metric_template)
                if ANALYTICS_ENABLED: post_analytics_metric (testround, schemaname, analyticsInfo)

        # print(json.dumps(AGENT_METRIC_COUNT_PER_TESTROUND))
        AGENT_METRIC_COUNT_PER_TESTROUND={}
        exit(0)
        # time.sleep(period_seconds)

