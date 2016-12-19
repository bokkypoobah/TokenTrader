#!/bin/bash

INPUTFILE=executeOrder.in
OUTPUTFILE=executeOrder.out

GETHATTACHPOINT=`grep IPCFILE settings.txt | sed "s/^.*=//"`
PASSWORD=`grep PASSWORD settings.txt | sed "s/^.*=//"`

TEMPOUTFILE=`grep TEMPOUTFILE settings.txt | sed "s/^.*=//"`
EVENTRESULTFILE=`grep EVENTRESULTFILE settings.txt | sed "s/^.*=//"`

TOKENDATAFILE=`grep TOKENDATA settings.txt | sed "s/^.*=//"`
TOKENADDRESS=`grep tokenAddress $TOKENDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENABI=`grep tokenABI $TOKENDATAFILE  | tail -n 1 | sed "s/^.*=//"`

FACTORYDATAFILE=`grep FACTORYDATAFILE settings.txt | sed "s/^.*=//"`
TOKENTRADERFACTORYADDRESS=`grep tokenTraderFactoryAddress $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENTRADERFACTORYABI=`grep tokenTraderFactoryABI $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENTRADERADDRESS=`grep tokenTraderAddress $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENTRADERABI=`grep tokenTraderABI $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENSELLERFACTORYADDRESS=`grep tokenSellerFactoryAddress $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENSELLERFACTORYABI=`grep tokenSellerFactoryABI $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENSELLERADDRESS=`grep tokenSellerAddress $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENSELLERABI=`grep tokenSellerABI $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`

printf "Connecting to geth on endpoint '$GETHATTACHPOINT'\n" | tee $TEMPOUTFILE
printf "Token address '$TOKENADDRESS'\n" | tee -a $TEMPOUTFILE
printf "Token ABI '$TOKENABI'\n" | tee -a $TEMPOUTFILE
printf "TokenTraderFactory address '$TOKENTRADERFACTORYADDRESS'\n" | tee -a $TEMPOUTFILE
printf "TokenTraderFactory ABI '$TOKENTRADERFACTORYABI'\n" | tee -a $TEMPOUTFILE
printf "TokenTrader address '$TOKENTRADERADDRESS'\n" | tee -a $TEMPOUTFILE
printf "TokenTrader ABI '$TOKENTRADERABI'\n" | tee -a $TEMPOUTFILE
printf "TokenSellerFactory address '$TOKENSELLERFACTORYADDRESS'\n" | tee -a $TEMPOUTFILE
printf "TokenSellerFactory ABI '$TOKENSELLERFACTORYABI'\n" | tee -a $TEMPOUTFILE
printf "TokenSeller address '$TOKENSELLERADDRESS'\n" | tee -a $TEMPOUTFILE
printf "TokenSeller ABI '$TOKENSELLERABI'\n" | tee -a $TEMPOUTFILE
printf "EventResult '$EVENTRESULTFILE'\n" | tee -a $TEMPOUTFILE

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEMPOUTFILE

var token = web3.eth.contract($TOKENABI).at("$TOKENADDRESS");
var tokenTraderFactory = web3.eth.contract($TOKENTRADERFACTORYABI).at("$TOKENTRADERFACTORYADDRESS");
var tokenTrader = web3.eth.contract($TOKENTRADERABI).at("$TOKENTRADERADDRESS");
var tokenSellerFactory = web3.eth.contract($TOKENSELLERFACTORYABI).at("$TOKENSELLERFACTORYADDRESS");
var tokenSeller = web3.eth.contract($TOKENSELLERABI).at("$TOKENSELLERADDRESS");

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

var accounts = [eth.accounts[0], eth.accounts[1], "$TOKENADDRESS", "$TOKENTRADERADDRESS", "$TOKENSELLERADDRESS"];
var accountName = {};
accountName[eth.accounts[0]] = "Account #0";
accountName[eth.accounts[1]] = "Account #1";
accountName["$TOKENADDRESS"] = "Token";
accountName["$TOKENTRADERFACTORYADDRESS"] = "TokenTraderFactory";
accountName["$TOKENTRADERADDRESS"] = "TokenTrader";
accountName["$TOKENSELLERFACTORYADDRESS"] = "TokenSellerFactory";
accountName["$TOKENSELLERADDRESS"] = "TokenSeller";

// call printBalances([eth.accounts[0], eth.accounts[1], "aaaa...", "bbb..."])
function printBalances(accounts) {
  var i = 0;
  console.log("RESULT: # Account                                                   EtherBalance                TokenBalance Name");
  accounts.forEach(function(e) {
    var etherBalance = web3.fromWei(eth.getBalance(e), "ether");
    var tokenBalance = web3.fromWei(token.balanceOf(e), "ether");
    console.log("RESULT: " + i + " " + e  + " " + pad(etherBalance) + " " + pad(tokenBalance) + " " + accountName[e]);
    i++;
  });
}

function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed);
}

printBalances(accounts);

var filter = web3.eth.filter({ address: ["$TOKENTRADERFACTORYADDRESS", "$TOKENSELLERFACTORYADDRESS", "$TOKENTRADERADDRESS", "$TOKENSELLERADDRESS"], fromBlock: 0, toBlock: "latest" });
var i = 0;
filter.watch(function (error, result) {
  console.log("RESULT: Filter " + i++ + ": " + JSON.stringify(result));
});
filter.stopWatching();

// Check TokenTrader Events
var tokenTraderActivatedEvent = tokenTrader.ActivatedEvent({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenTraderActivatedEvent.watch(function (error, result) {
  console.log("RESULT: " + i++ + ": " + JSON.stringify(result));
});
tokenTraderActivatedEvent.stopWatching();

var tokenTraderMakerDepositedEther = tokenTrader.MakerDepositedEther({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenTraderMakerDepositedEther.watch(function (error, result) {
  console.log("RESULT: " + i++ + ": " + JSON.stringify(result));
});
tokenTraderMakerDepositedEther.stopWatching();

var tokenTraderMakerWithdrewAsset = tokenTrader.MakerWithdrewAsset({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenTraderMakerWithdrewAsset.watch(function (error, result) {
  console.log("RESULT: " + i++ + ": " + JSON.stringify(result));
});
tokenTraderMakerWithdrewAsset.stopWatching();

var tokenTraderMakerWithdrewEther = tokenTrader.MakerWithdrewEther({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenTraderMakerWithdrewEther.watch(function (error, result) {
  console.log("RESULT: " + i++ + ": " + JSON.stringify(result));
});
tokenTraderMakerWithdrewEther.stopWatching();

var tokenTraderTakerBoughtAsset = tokenTrader.TakerBoughtAsset({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenTraderTakerBoughtAsset.watch(function (error, result) {
  console.log("RESULT: " + i++ + ": " + JSON.stringify(result));
});
tokenTraderTakerBoughtAsset.stopWatching();

var tokenTraderTakerSoldAsset = tokenTrader.TakerSoldAsset({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenTraderTakerSoldAsset.watch(function (error, result) {
  console.log("RESULT: " + i++ + ": " + JSON.stringify(result));
});
tokenTraderTakerSoldAsset.stopWatching();

// Check TokenSeller Events
var tokenSellerActivatedEvent = tokenTrader.ActivatedEvent({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenSellerActivatedEvent.watch(function (error, result) {
  console.log("RESULT: " + i++ + ": " + JSON.stringify(result));
});
tokenSellerActivatedEvent.stopWatching();

// Check TokenSeller Events
var tokenSellerMakerWithdrewAsset = tokenTrader.MakerWithdrewAsset({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenSellerMakerWithdrewAsset.watch(function (error, result) {
  console.log("RESULT: " + i++ + ": " + JSON.stringify(result));
});
tokenSellerMakerWithdrewAsset.stopWatching();

var tokenSellerMakerWithdrewEther = tokenTrader.MakerWithdrewEther({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenSellerMakerWithdrewEther.watch(function (error, result) {
  console.log("RESULT: " + i++ + ": " + JSON.stringify(result));
});
tokenSellerMakerWithdrewEther.stopWatching();

var tokenSellerTakerBoughtAsset = tokenTrader.TakerBoughtAsset({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenSellerTakerBoughtAsset.watch(function (error, result) {
  console.log("RESULT: " + i++ + ": " + JSON.stringify(result));
});
tokenSellerMakerWithdrewEther.stopWatching();

exit;

EOF

grep "RESULT: " $TEMPOUTFILE | sed "s/RESULT: //" > $EVENTRESULTFILE
cat $EVENTRESULTFILE
