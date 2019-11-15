#!/bin/bash

. ./1-vnet.sh
. ./2-workspace.sh
. ./windowspreview-registration.sh
. ./3-aks.sh
. ./windowspreview-nodepool.sh
. ./4-aks-ipaddress.sh
. ./5-trafficmanager.sh
. ./6-dns.sh