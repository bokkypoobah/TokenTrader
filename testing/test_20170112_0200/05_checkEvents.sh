#!/bin/bash
# --------------------------------------------------------------------
# Testing Contracts At https://github.com/bokkypoobah/TokenTrader
# for https://cryptoderivatives.market/
#
# Checking Generated Events
#
# (c) BokkyPooBah 2017. The MIT licence.
# --------------------------------------------------------------------

GETHATTACHPOINT=`grep IPCFILE settings.txt | sed "s/^.*=//"`
PASSWORD=`grep PASSWORD settings.txt | sed "s/^.*=//"`

TEMPOUTFILE=`grep TEMPOUTFILE settings.txt | sed "s/^.*=//"`
EVENTRESULTFILE=`grep EVENTRESULTFILE settings.txt | sed "s/^.*=//"`

TOKENDATAFILE=`grep TOKENDATA settings.txt | sed "s/^.*=//"`
TOKENADDRESSA=`grep tokenAddressA $TOKENDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENADDRESSB=`grep tokenAddressB $TOKENDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENADDRESSC=`grep tokenAddressC $TOKENDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENABI=`grep tokenABI $TOKENDATAFILE  | tail -n 1 | sed "s/^.*=//"`

FACTORYDATAFILE=`grep FACTORYDATAFILE settings.txt | sed "s/^.*=//"`
TOKENTRADERFACTORYADDRESS=`grep ^tokenTraderFactoryAddress $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENTRADERFACTORYABI=`grep ^tokenTraderFactoryABI $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENTRADERADDRESS=`grep ^tokenTraderAddress $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENTRADERABI=`grep ^tokenTraderABI $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENSELLERFACTORYADDRESS=`grep tokenSellerFactoryAddress $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENSELLERFACTORYABI=`grep tokenSellerFactoryABI $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENSELLERADDRESS=`grep tokenSellerAddress $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENSELLERABI=`grep tokenSellerABI $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
GNTTOKENTRADERFACTORYADDRESS=`grep gntTokenTraderFactoryAddress $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
GNTTOKENTRADERFACTORYABI=`grep gntTokenTraderFactoryABI $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
GNTTOKENTRADERADDRESS=`grep gntTokenTraderAddress $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`
GNTTOKENTRADERABI=`grep gntTokenTraderABI $FACTORYDATAFILE  | tail -n 1 | sed "s/^.*=//"`

printf "Connecting to geth on endpoint '$GETHATTACHPOINT'\n" | tee $TEMPOUTFILE
printf "TokenA address '$TOKENADDRESSA'\n" | tee -a $TEMPOUTFILE
printf "TokenB address '$TOKENADDRESSB'\n" | tee -a $TEMPOUTFILE
printf "TokenC address '$TOKENADDRESSC'\n" | tee -a $TEMPOUTFILE
printf "Token ABI '$TOKENABI'\n" | tee -a $TEMPOUTFILE
printf "TokenTraderFactory address '$TOKENTRADERFACTORYADDRESS'\n" | tee -a $TEMPOUTFILE
printf "TokenTraderFactory ABI '$TOKENTRADERFACTORYABI'\n" | tee -a $TEMPOUTFILE
printf "TokenTrader address '$TOKENTRADERADDRESS'\n" | tee -a $TEMPOUTFILE
printf "TokenTrader ABI '$TOKENTRADERABI'\n" | tee -a $TEMPOUTFILE
printf "TokenSellerFactory address '$TOKENSELLERFACTORYADDRESS'\n" | tee -a $TEMPOUTFILE
printf "TokenSellerFactory ABI '$TOKENSELLERFACTORYABI'\n" | tee -a $TEMPOUTFILE
printf "TokenSeller address '$TOKENSELLERADDRESS'\n" | tee -a $TEMPOUTFILE
printf "TokenSeller ABI '$TOKENSELLERABI'\n" | tee -a $TEMPOUTFILE
printf "GNTTokenTraderFactory address '$GNTTOKENTRADERFACTORYADDRESS'\n" | tee -a $TEMPOUTFILE
printf "GNTTokenTraderFactory ABI '$GNTTOKENTRADERFACTORYABI'\n" | tee -a $TEMPOUTFILE
printf "GNTTokenTrader address '$GNTTOKENTRADERADDRESS'\n" | tee -a $TEMPOUTFILE
printf "GNTTokenTrader ABI '$GNTTOKENTRADERABI'\n" | tee -a $TEMPOUTFILE
printf "EventResult '$EVENTRESULTFILE'\n" | tee -a $TEMPOUTFILE

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEMPOUTFILE

var token = web3.eth.contract($TOKENABI).at("$TOKENADDRESS");
var tokenTraderFactory = web3.eth.contract($TOKENTRADERFACTORYABI).at("$TOKENTRADERFACTORYADDRESS");
var tokenTrader = web3.eth.contract($TOKENTRADERABI).at("$TOKENTRADERADDRESS");
var tokenSellerFactory = web3.eth.contract($TOKENSELLERFACTORYABI).at("$TOKENSELLERFACTORYADDRESS");
var tokenSeller = web3.eth.contract($TOKENSELLERABI).at("$TOKENSELLERADDRESS");
var gntTokenTraderFactory = web3.eth.contract($GNTTOKENTRADERFACTORYABI).at("$GNTTOKENTRADERFACTORYADDRESS");
var gntTokenTrader = web3.eth.contract($GNTTOKENTRADERABI).at("$GNTTOKENTRADERADDRESS");

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

var accounts = [eth.accounts[0], eth.accounts[1], "$TOKENADDRESSA", "$TOKENADDRESSB", "$TOKENADDRESSC", "$TOKENTRADERADDRESS", "$TOKENSELLERADDRESS", "$GNTTOKENTRADERADDRESS"];
var accountName = {};
accountName[eth.accounts[0]] = "Account #0";
accountName[eth.accounts[1]] = "Account #1";
accountName["$TOKENADDRESSA"] = "ERC20A";
accountName["$TOKENADDRESSB"] = "ERC20B";
accountName["$TOKENADDRESSC"] = "ERC20C";
accountName["$TOKENTRADERFACTORYADDRESS"] = "TokenTraderFactory";
accountName["$TOKENTRADERADDRESS"] = "TokenTrader b1.1,s1.2";
accountName["$TOKENSELLERFACTORYADDRESS"] = "TokenSellerFactory";
accountName["$TOKENSELLERADDRESS"] = "TokenSeller s1.2";
accountName["$GNTTOKENTRADERFACTORYADDRESS"] = "GNTTokenTraderFactory";
accountName["$GNTTOKENTRADERADDRESS"] = "GNTTokenTrader s1.3";

function printBalances(accounts) {
  var i = 0;
  console.log("RESULT: # Account                                                   EtherBalance               TokenABalance               TokenBBalance               TokenCBalance Name");
  accounts.forEach(function(e) {
    var etherBalance = web3.fromWei(eth.getBalance(e), "ether");
    var tokenABalance = web3.fromWei(tokenA.balanceOf(e), "ether");
    var tokenBBalance = web3.fromWei(tokenB.balanceOf(e), "ether");
    var tokenCBalance = web3.fromWei(tokenC.balanceOf(e), "ether");
    console.log("RESULT: " + i + " " + e  + " " + pad(etherBalance) + " " + pad(tokenABalance) + " " + pad(tokenBBalance) + " " + pad(tokenCBalance) + " " + accountName[e]);
    i++;
  });
}

function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed + " cost=" + tx.gasPrice.mulß(txReceipt.gasUsed).div(1e18) +
    " block=" + txReceipt.blockNumber + " txId=" + txId);
}

printBalances(accounts);

console.log("RESULT: Factory Events");
var filter = web3.eth.filter({ address: ["$TOKENTRADERFACTORYADDRESS", "$TOKENSELLERFACTORYADDRESS", "$GNTTOKENTRADERFACTORYADDRESS", "$TOKENTRADERADDRESS", "$TOKENSELLERADDRESS", "$GNTTOKENTRADERADDRESS"], fromBlock: 0, toBlock: "latest" });
var i = 0;
filter.watch(function (error, result) {
  console.log("RESULT: Filter " + i++ + ": " + JSON.stringify(result));
});
filter.stopWatching();

// Check TokenTrader Events
console.log("RESULT: TokenTrader ActivatedEvent");
var tokenTraderActivatedEvent = tokenTrader.ActivatedEvent({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenTraderActivatedEvent.watch(function (error, result) {
  console.log("RESULT: tokenTraderActivatedEvent " + i++ + ": " + JSON.stringify(result));
});
tokenTraderActivatedEvent.stopWatching();

console.log("RESULT: TokenTrader MakerDepositedEther");
var tokenTraderMakerDepositedEther = tokenTrader.MakerDepositedEther({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenTraderMakerDepositedEther.watch(function (error, result) {
  console.log("RESULT: tokenTraderMakerDepositedEther " + i++ + ": " + JSON.stringify(result));
});
tokenTraderMakerDepositedEther.stopWatching();

console.log("RESULT: TokenTrader MakerWithdrewAsset");
var tokenTraderMakerWithdrewAsset = tokenTrader.MakerWithdrewAsset({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenTraderMakerWithdrewAsset.watch(function (error, result) {
  console.log("RESULT: tokenTraderMakerWithdrewAsset " + i++ + ": " + JSON.stringify(result));
});
tokenTraderMakerWithdrewAsset.stopWatching();

console.log("RESULT: TokenTrader MakerWithdrewEther");
var tokenTraderMakerWithdrewEther = tokenTrader.MakerWithdrewEther({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenTraderMakerWithdrewEther.watch(function (error, result) {
  console.log("RESULT: tokenTraderMakerWithdrewEther " + i++ + ": " + JSON.stringify(result));
});
tokenTraderMakerWithdrewEther.stopWatching();

console.log("RESULT: TokenTrader TakerBoughtAsset");
var tokenTraderTakerBoughtAsset = tokenTrader.TakerBoughtAsset({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenTraderTakerBoughtAsset.watch(function (error, result) {
  console.log("RESULT: tokenTraderTakerBoughtAsset " + i++ + ": " + JSON.stringify(result));
});
tokenTraderTakerBoughtAsset.stopWatching();

console.log("RESULT: TokenTrader TakerSoldAsset");
var tokenTraderTakerSoldAsset = tokenTrader.TakerSoldAsset({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenTraderTakerSoldAsset.watch(function (error, result) {
  console.log("RESULT: tokenTraderTakerSoldAsset " + i++ + ": " + JSON.stringify(result));
});
tokenTraderTakerSoldAsset.stopWatching();

// Check TokenSeller Events
console.log("RESULT: TokenSeller ActivatedEvent");
var tokenSellerActivatedEvent = tokenTrader.ActivatedEvent({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenSellerActivatedEvent.watch(function (error, result) {
  console.log("RESULT: tokenSellerActivatedEvent " + i++ + ": " + JSON.stringify(result));
});
tokenSellerActivatedEvent.stopWatching();

console.log("RESULT: TokenSeller MakerWithdrewAsset");
var tokenSellerMakerWithdrewAsset = tokenTrader.MakerWithdrewAsset({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenSellerMakerWithdrewAsset.watch(function (error, result) {
  console.log("RESULT: tokenSellerMakerWithdrewAsset " + i++ + ": " + JSON.stringify(result));
});
tokenSellerMakerWithdrewAsset.stopWatching();

console.log("RESULT: TokenSeller MakerWithdrewEther");
var tokenSellerMakerWithdrewEther = tokenTrader.MakerWithdrewEther({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenSellerMakerWithdrewEther.watch(function (error, result) {
  console.log("RESULT: tokenSellerMakerWithdrewEther " + i++ + ": " + JSON.stringify(result));
});
tokenSellerMakerWithdrewEther.stopWatching();

console.log("RESULT: TokenSeller TakerBoughtAsset");
var tokenSellerTakerBoughtAsset = tokenTrader.TakerBoughtAsset({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
tokenSellerTakerBoughtAsset.watch(function (error, result) {
  console.log("RESULT: tokenSellerTakerBoughtAsset " + i++ + ": " + JSON.stringify(result));
});
tokenSellerMakerWithdrewEther.stopWatching();

exit;

EOF

grep "RESULT: " $TEMPOUTFILE | sed "s/RESULT: //" > $EVENTRESULTFILE
cat $EVENTRESULTFILE
