#!/bin/bash
# 
# NOTE: The `Test` and `Account Group` are defined in `config.json`
# 
# The `Application`, `Tier`, and `Node` MUST be specified as metadata in the `Description` section of your ThousandEyes test. Metadata is json format:
# { 
#     "appd_application":"<appd application name>", 
#     "appd_tier":"<appd application tier>", 
#     "appd_node":"<appd tier node>"
# }
./monitor.py