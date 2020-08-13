#!/bin/bash
# 
# NOTE: The AppDynamics `Application`, `Tier`, and `Node` MUST be specified as metadata in the `Description` section of your ThousandEyes test. Metadata is json format:
# { 
#     "appd_application":"<appd application name>", 
#     "appd_tier":"<appd application tier>", 
#     "appd_node":"<appd tier node>"
# }
# ./teappd-monitor.py "<account group>" "<testa>"