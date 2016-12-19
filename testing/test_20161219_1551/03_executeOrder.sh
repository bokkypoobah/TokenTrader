#!/bin/bash

INPUTFILE=executeOrder.in
OUTPUTFILE=executeOrder.out

GETHATTACHPOINT=`grep IPCFILE settings.txt | sed "s/^.*=//"`
PASSWORD=`grep PASSWORD settings.txt | sed "s/^.*=//"`

TEMPOUTFILE=`grep TEMPOUTFILE settings.txt | sed "s/^.*=//"`
EXECUTIONRESULTFILE=`grep EXECUTIONRESULTFILE settings.txt | sed "s/^.*=//"`

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

personal.unlockAccount(eth.accounts[0], "$PASSWORD", 100000);
personal.unlockAccount(eth.accounts[1], "$PASSWORD", 100000);

// ---------- Testing Taker selling of tokens ----------
// Maker deactivating buy
var tokenTraderDeactivateBuyTxId = tokenTrader.activate(false, true, {from: eth.accounts[0], to: "$TOKENTRADERADDRESS", gas: 300000});
console.log("tokenTraderDeactivateBuyTxId=" + tokenTraderDeactivateBuyTxId);
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderDeactivateBuyTxId", tokenTraderDeactivateBuyTxId);

console.log("RESULT: Approving 200 tokens from eth.accounts[1] to contract " + "$TOKENTRADERADDRESS");
var tokenApproveTxId = token.approve("$TOKENTRADERADDRESS", 200e18, {from: eth.accounts[1], to: "$TOKENADDRESS", value: 0, gas: 300000});
while (txpool.status.pending > 0) {
}
printTxData("tokenApproveTxId", tokenApproveTxId);

console.log("RESULT: Sending 90 tokens from eth.accounts[1] to contract " + "$TOKENTRADERADDRESS");
var tokenTraderSellTokenTxId = tokenTrader.takerSellAsset(90e18, {from: eth.accounts[1], to: "$TOKENTRADERADDRESS", value: 0, gas: 300000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderSellTokenTxId", tokenTraderSellTokenTxId);
console.log("RESULT: Expecting no change in balances except for a bit of gas from eth.accounts[1]");
printBalances(accounts);

// Maker reactivating buy - Buying at buyPrice=110000 per 100000 units = 1.1 ETH per token
var tokenTraderActivateBuyTxId = tokenTrader.activate(true, true, {from: eth.accounts[0], to: "$TOKENTRADERADDRESS", gas: 300000});
console.log("tokenTraderActivateBuyTxId=" + tokenTraderActivateBuyTxId);
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderActivateBuyTxId", tokenTraderActivateBuyTxId);
console.log("RESULT: Sending 90 tokens from eth.accounts[1] to contract " + "$TOKENTRADERADDRESS");
var tokenTraderSellTokenTxId = tokenTrader.sell(90e18, {from: eth.accounts[1], to: "$TOKENTRADERADDRESS", value: 0, gas: 300000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderSellTokenTxId", tokenTraderSellTokenTxId);
console.log("RESULT: Expecting change in eth.accounts[1] and TokenTrader balances");
printBalances(accounts);

// Taker selling with limited ETH in contract
console.log("RESULT: Sending 90 tokens from eth.accounts[1] to contract " + "$TOKENTRADERADDRESS" + " but only 1 ETH remaining to pay for tokens");
var tokenTraderSellTokenTxId = tokenTrader.takerSellAsset(90e18, {from: eth.accounts[1], to: "$TOKENTRADERADDRESS", value: 0, gas: 300000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderSellTokenTxId", tokenTraderSellTokenTxId);
console.log("RESULT: Expecting change in eth.accounts[1] and TokenTrader balances");
printBalances(accounts);

// ---------- Testing Taker buying of tokens ----------
// Maker deactivating sell
var tokenTraderDeactivateSellTxId = tokenTrader.activate(true, false, {from: eth.accounts[0], to: "$TOKENTRADERADDRESS", gas: 300000});
console.log("tokenTraderDeactivateSellTxId=" + tokenTraderDeactivateSellTxId);
var tokenSellerDeactivateSellTxId = tokenSeller.activate(false, {from: eth.accounts[0], to: "$TOKENSELLERADDRESS", gas: 300000});
console.log("tokenSellerDeactivateSellTxId=" + tokenSellerDeactivateSellTxId);
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderDeactivateSellTxId", tokenTraderDeactivateSellTxId);
printTxData("tokenSellerDeactivateSellTxId", tokenSellerDeactivateSellTxId);

var tokenTraderBuyTokenTxId = eth.sendTransaction({from: eth.accounts[1], to: "$TOKENTRADERADDRESS", value: web3.toWei(100, "ether"), gas: 100000});
var tokenSellerBuyTokenTxId = eth.sendTransaction({from: eth.accounts[1], to: "$TOKENSELLERADDRESS", value: web3.toWei(100, "ether"), gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderBuyTokenTxId", tokenTraderBuyTokenTxId);
printTxData("tokenSellerBuyTokenTxId", tokenSellerBuyTokenTxId);

console.log("RESULT: Expecting no change in balances except for a bit of gas from eth.accounts[1]");
printBalances(accounts);

// Maker activating sell - Selling at sellPrice=120000 per 100000 units = 1.2 ETH per token
var tokenTraderActivateSellTxId = tokenTrader.activate(true, true, {from: eth.accounts[0], to: "$TOKENTRADERADDRESS", gas: 300000});
console.log("tokenTraderActivateSellTxId=" + tokenTraderActivateSellTxId);
var tokenSellerActivateSellTxId = tokenSeller.activate(true, {from: eth.accounts[0], to: "$TOKENTRADERADDRESS", gas: 300000});
console.log("tokenSellerActivateSellTxId=" + tokenSellerActivateSellTxId);
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderActivateSellTxId", tokenTraderActivateSellTxId);
printTxData("tokenSellerActivateSellTxId", tokenSellerActivateSellTxId);

var tokenTraderBuyTokenTxId = eth.sendTransaction({from: eth.accounts[1], to: "$TOKENTRADERADDRESS", value: web3.toWei(100, "ether"), gas: 100000});
var tokenSellerBuyTokenTxId = eth.sendTransaction({from: eth.accounts[1], to: "$TOKENSELLERADDRESS", value: web3.toWei(100, "ether"), gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderBuyTokenTxId", tokenTraderBuyTokenTxId);
printTxData("tokenSellerBuyTokenTxId", tokenSellerBuyTokenTxId);

console.log("RESULT: Expecting change in eth.accounts[1] plus decrease in TokenTrader and TokenSeller balances");
printBalances(accounts);

var tokenTraderBuyTokenTxId = eth.sendTransaction({from: eth.accounts[1], to: "$TOKENTRADERADDRESS", value: web3.toWei(200, "ether"), gas: 100000});
var tokenSellerBuyTokenTxId = eth.sendTransaction({from: eth.accounts[1], to: "$TOKENSELLERADDRESS", value: web3.toWei(200, "ether"), gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderBuyTokenTxId", tokenTraderBuyTokenTxId);
printTxData("tokenSellerBuyTokenTxId", tokenSellerBuyTokenTxId);

console.log("RESULT: Expecting change in eth.accounts[1] plus decrease in TokenTrader and TokenSeller balances, but limited tokens left");
printBalances(accounts);

// Maker send tokens to trader contracts, then withdraw these tokens and ETH
console.log("RESULT: Transferring 30 ETH and 30 tokens to tokenTrader and tokenSeller");
var tokenTraderAddEtherTxId = eth.sendTransaction({from: eth.accounts[0], to: "$TOKENTRADERADDRESS", value: web3.toWei(30, "ether"), gas: 100000});
var tokenSellerAddEtherTxId = eth.sendTransaction({from: eth.accounts[0], to: "$TOKENSELLERADDRESS", value: web3.toWei(30, "ether"), gas: 100000});
var traderTransferTokenTxId = token.transfer("$TOKENTRADERADDRESS", 30e18, {from: eth.accounts[0], gas: 100000});
var sellerTransferTokenTxId = token.transfer("$TOKENSELLERADDRESS", 30e18, {from: eth.accounts[0], gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderAddEtherTxId", tokenTraderAddEtherTxId);
printTxData("tokenSellerAddEtherTxId", tokenSellerAddEtherTxId);
printTxData("traderTransferTokenTxId", traderTransferTokenTxId);
printTxData("sellerTransferTokenTxId", sellerTransferTokenTxId);
console.log("RESULT: Expecting change in eth.accounts[0] tokens plus 30 tokens in TokenTrader and TokenSeller");
printBalances(accounts);

// ---------- Testing Maker withdrawing asset and ETH ----------
var tokenTraderWithdrawEtherTxId = tokenTrader.makerWithdrawEther(5e18, {from: eth.accounts[0], gas: 300000});
var tokenTraderWithdrawAssetTxId = tokenTrader.makerWithdrawAsset(5e18, {from: eth.accounts[0], gas: 300000});
var tokenSellerWithdrawEtherTxId = tokenSeller.makerWithdrawEther(5e18, {from: eth.accounts[0], gas: 300000});
var tokenSellerWithdrawAssetTxId = tokenSeller.makerWithdrawAsset(5e18, {from: eth.accounts[0], gas: 300000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderWithdrawEtherTxId", tokenTraderWithdrawEtherTxId);
printTxData("tokenTraderWithdrawAssetTxId", tokenTraderWithdrawAssetTxId);
printTxData("tokenSellerWithdrawEtherTxId", tokenSellerWithdrawEtherTxId);
printTxData("tokenSellerWithdrawAssetTxId", tokenSellerWithdrawAssetTxId);
console.log("RESULT: Expecting increase of 10 ETH and 10 tokens in eth.accounts[0] tokens and decrease of 5 ETH and 5 tokens in TokenTrader and TokenSeller");
printBalances(accounts);

exit;

EOF

grep "RESULT: " $TEMPOUTFILE | sed "s/RESULT: //" > $EXECUTIONRESULTFILE
cat $EXECUTIONRESULTFILE
