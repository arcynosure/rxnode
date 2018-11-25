#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  ./testAPIs.sh -l golang|node"
  echo "    -l <language> - chaincode language (defaults to \"golang\")"
}
# Language defaults to "golang"
LANGUAGE="golang"

# Parse commandline args
while getopts "h?l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
  esac
done

##set chaincode path
function setChaincodePath(){
	LANGUAGE=`echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]'`
	case "$LANGUAGE" in
		"golang")
		CC_SRC_PATH="github.com/example_cc/go"
		;;
		"node")
		CC_SRC_PATH="$PWD/artifacts/src/github.com/example_cc/node"
		;;
		*) printf "\n ------ Language $LANGUAGE is not supported yet ------\n"$
		exit 1
	esac
}

setChaincodePath

echo "POST request Enroll on Org1  ..."
echo
ORG1_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Jim&orgName=Org1')
echo $ORG1_TOKEN
ORG1_TOKEN=$(echo $ORG1_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG1 token is $ORG1_TOKEN"
echo
echo "POST request Enroll on Org2 ..."
echo
ORG2_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Barry&orgName=Org2')
echo $ORG2_TOKEN
ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG2 token is $ORG2_TOKEN"
echo
echo "POST request Enroll on Org3  ..."
echo
ORG3_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Tittu&orgName=Org3')
echo $ORG3_TOKEN
ORG3_TOKEN=$(echo $ORG3_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG3 token is $ORG3_TOKEN"
echo
echo
echo "POST request Create channel  ..."
echo
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"channelName":"rxmed",
	"channelConfigPath":"../artifacts/channel/channel.tx"
}'
echo
echo
sleep 5
echo "POST request Join channel on Org1"
echo
curl -s -X POST \
  http://localhost:4000/channels/rxmed/peers \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.rxmed.com","peer1.org1.rxmed.com","peer2.org1.rxmed.com","peer3.org1.rxmed.com"]
}'
echo
echo

echo "POST request Join channel on Org2"
echo
curl -s -X POST \
  http://localhost:4000/channels/rxmed/peers \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org2.rxmed.com","peer1.org2.rxmed.com","peer2.org2.rxmed.com","peer3.org2.rxmed.com"]
}'
echo
echo

echo "POST request Join channel on Org3"
echo
curl -s -X POST \
  http://localhost:4000/channels/rxmed/peers \
  -H "authorization: Bearer $ORG3_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org3.rxmed.com","peer1.org3.rxmed.com","peer2.org3.rxmed.com","peer3.org3.rxmed.com"]
}'
echo
echo

echo "POST request Update anchor peers on Org1"
echo
curl -s -X POST \
  http://localhost:4000/channels/rxmed/anchorpeers \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"configUpdatePath":"../artifacts/channel/Org1MSPanchors.tx"
}'
echo
echo

echo "POST request Update anchor peers on Org2"
echo
curl -s -X POST \
  http://localhost:4000/channels/rxmed/anchorpeers \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"configUpdatePath":"../artifacts/channel/Org2MSPanchors.tx"
}'
echo
echo

echo "POST request Update anchor peers on Org3"
echo
curl -s -X POST \
  http://localhost:4000/channels/rxmed/anchorpeers \
  -H "authorization: Bearer $ORG3_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"configUpdatePath":"../artifacts/channel/Org3MSPanchors.tx"
}'
echo
echo

echo "POST Install chaincode on Org1"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org1.rxmed.com\",\"peer1.org1.rxmed.com\",\"peer2.org1.rxmed.com\",\"peer3.org1.rxmed.com\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org2"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org2.rxmed.com\",\"peer1.org2.rxmed.com\",\"peer2.org2.rxmed.com\",\"peer3.org2.rxmed.com\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org3"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG3_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org3.rxmed.com\",\"peer1.org3.rxmed.com\",\"peer2.org3.rxmed.com\",\"peer3.org3.rxmed.com\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST instantiate chaincode on Org1"
echo
curl -s -X POST \
  http://localhost:4000/channels/rxmed/chaincodes \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"mycc\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"fcn\":\"init\"
}"
echo
echo

echo "POST invoke chaincode on peers of Org1 and Org2 and Org3"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/rxmed/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.rxmed.com","peer0.org2.rxmed.com","peer0.org3.rxmed.com"],
	"fcn":"createDoctor",
	"args":["DOC4","DOCID4","ANAS KOSP", "PMI433", "HOSP4"]
}')
 echo "Transaction ID is $TRX_ID"

 echo "POST invoke chaincode on peers of Org1 and Org2 and Org3"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/rxmed/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.rxmed.com","peer0.org2.rxmed.com","peer0.org3.rxmed.com"],
	"fcn":"createPatient",
	"args":["PAT4","PATID4","AAAA QQQQ", "22/34/1978", "AB+"]
}')
 echo "Transaction ID is $TRX_ID"
# echo
# echo

# echo "GET query chaincode on peer1 of Org1 for Query DOC1"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/rxmed/chaincodes/mycc?peer=peer0.org1.rxmed.com&fcn=query&args=%5B%22DOC1%22%5D" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo

echo "GET query Block by blockNumber"
echo
curl -s -X GET \
  "http://localhost:4000/channels/rxmed/blocks/1?peer=peer0.org1.rxmed.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Transaction by TransactionID"
echo
curl -s -X GET http://localhost:4000/channels/rxmed/transactions/$TRX_ID?peer=peer0.org1.rxmed.com \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

# ############################################################################
# ### TODO: What to pass to fetch the Block information
# ############################################################################
# #echo "GET query Block by Hash"
# #echo
# #hash=????
# #curl -s -X GET \
# #  "http://localhost:4000/channels/channel/blocks?hash=$hash&peer=peer1" \
# #  -H "authorization: Bearer $ORG1_TOKEN" \
# #  -H "cache-control: no-cache" \
# #  -H "content-type: application/json" \
# #  -H "x-access-token: $ORG1_TOKEN"
# #echo
# #echo

echo "GET query ChainInfo"
echo
curl -s -X GET \
  "http://localhost:4000/channels/rxmed?peer=peer0.org1.rxmed.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Installed chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/chaincodes?peer=peer0.org1.rxmed.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Instantiated chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/channels/rxmed/chaincodes?peer=peer0.org1.rxmed.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Channels"
echo
curl -s -X GET \
  "http://localhost:4000/channels?peer=peer0.org1.rxmed.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo


# echo "Total execution time : $(($(date +%s)-starttime)) secs ..."


echo
echo
echo "GET query chaincode on peer0 of Org1 for Query DOC1"
echo
curl -s -X GET \
  "http://localhost:4000/channels/rxmed/chaincodes/mycc?peer=peer0.org1.rxmed.com&fcn=query&args=%5B%22DOC1%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo
echo "GET query chaincode on peer1 of Org2 for Query DOC4"
echo
curl -s -X GET \
  "http://localhost:4000/channels/rxmed/chaincodes/mycc?peer=peer1.org2.rxmed.com&fcn=query&args=%5B%22DOC4%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo
echo "GET query chaincode on peer1 of Org2 for Query PAT1"
echo
curl -s -X GET \
  "http://localhost:4000/channels/rxmed/chaincodes/mycc?peer=peer1.org2.rxmed.com&fcn=query&args=%5B%22PAT1%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo
echo "GET query chaincode on peer1 of Org3 for Query DOC4"
echo
curl -s -X GET \
  "http://localhost:4000/channels/rxmed/chaincodes/mycc?peer=peer1.org3.rxmed.com&fcn=query&args=%5B%22DOC4%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo


#echo "POST invoke chaincode on peers of Org1 and Org2"
#echo
#TRX_ID=$(curl -s -X POST \
#  http://localhost:4000/channels/mychannel/chaincodes/mycc \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "content-type: application/json" \
#  -d '{
#	"peers": ["peer0.org1.example.com","peer0.org2.example.com"],
#	"fcn":"move",
#	"args":["a","b","10"]
#}')
#echo "Transaction ID is $TRX_ID"
#echo
#echo

#echo "GET query chaincode on peer1 of Org1"
#echo
#curl -s -X GET \
#  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22a%22%5D" \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "content-type: application/json"
#echo
#echo

#echo "GET query Block by blockNumber"
#echo
#BLOCK_INFO=$(curl -s -X GET \
#  "http://localhost:4000/channels/mychannel/blocks/1?peer=peer0.org1.example.com" \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "content-type: application/json")
#echo $BLOCK_INFO
# Assign previvious block hash to HASH
#HASH=$(echo $BLOCK_INFO | jq -r ".header.previous_hash")
#echo

#echo "GET query Transaction by TransactionID"
#echo
#curl -s -X GET http://localhost:4000/channels/mychannel/transactions/$TRX_ID?peer=peer0.org1.example.com \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "content-type: application/json"
#echo
#echo


#echo "GET query Block by Hash - Hash is $HASH"
#echo
#curl -s -X GET \
#  "http://localhost:4000/channels/mychannel/blocks?hash=$HASH&peer=peer0.org1.example.com" \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "cache-control: no-cache" \
#  -H "content-type: application/json" \
#  -H "x-access-token: $ORG1_TOKEN"
#echo
#echo

#echo "GET query ChainInfo"
#echo
#curl -s -X GET \
#  "http://localhost:4000/channels/mychannel?peer=peer0.org1.example.com" \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "content-type: application/json"
#echo
#echo

#echo "GET query Installed chaincodes"
#echo
#curl -s -X GET \
#  "http://localhost:4000/chaincodes?peer=peer0.org1.example.com" \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "content-type: application/json"
#echo
#echo

#echo "GET query Instantiated chaincodes"
#echo
#curl -s -X GET \
#  "http://localhost:4000/channels/mychannel/chaincodes?peer=peer0.org1.example.com" \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "content-type: application/json"
#echo
#echo

#echo "GET query Channels"
#echo
#curl -s -X GET \
#  "http://localhost:4000/channels?peer=peer0.org1.example.com" \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "content-type: application/json"
#echo
#echo


echo
echo
echo "GET query chaincode on peer1 of Org1 for Query All Records"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer1.org1.example.com&fcn=queryAll" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"

echo
echo
echo "GET query chaincode on peer1 of Org1 for Query History of DOC0"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer1.org1.example.com&fcn=queryHistory&args=%5B%22DOC0%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"

echo
echo
echo "Invoke query chaincode on peer0 of Org1 and 2 for Delete DOC2 - Doctor"
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer0.org2.example.com"],
	"fcn":"delete",
	"args":["DOC2"]
}')
echo "Transaction ID is $TRX_ID"

echo
echo "GET query chaincode on peer1 of Org1 for Query History of DOC2 to check status of isDelete flag"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer1.org1.example.com&fcn=queryHistory&args=%5B%22DOC2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"

echo "Total execution time : $(($(date +%s)-starttime)) secs ..."