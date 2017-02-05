#!/bin/bash
# --------------------------------------------------------------------
# Testing Contracts At https://github.com/bokkypoobah/TokenTrader
# for https://cryptoderivatives.market/
#
# Execute TokenTrader and TokenSeller Methods
#
# (c) BokkyPooBah 2017. The MIT licence.
# --------------------------------------------------------------------

GETHATTACHPOINT=`grep IPCFILE settings.txt | sed "s/^.*=//"`
PASSWORD=`grep PASSWORD settings.txt | sed "s/^.*=//"`

TEMPINFILE=`grep TEMPINFILE settings.txt | sed "s/^.*=//"`
EXECUTIONOUTPUTFILE=`grep EXECUTIONOUTPUTFILE settings.txt | sed "s/^.*=//"`
EXECUTIONRESULTFILE=`grep EXECUTIONRESULTFILE settings.txt | sed "s/^.*=//"`

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

printf "Connecting to geth on endpoint '$GETHATTACHPOINT'\n" | tee $EXECUTIONOUTPUTFILE
printf "Token address '$TOKENADDRESS'\n" | tee -a $EXECUTIONOUTPUTFILE
printf "Token ABI '$TOKENABI'\n" | tee -a $EXECUTIONOUTPUTFILE
printf "TokenTraderFactory address '$TOKENTRADERFACTORYADDRESS'\n" | tee -a $EXECUTIONOUTPUTFILE
printf "TokenTraderFactory ABI '$TOKENTRADERFACTORYABI'\n" | tee -a $EXECUTIONOUTPUTFILE
printf "TokenTrader address '$TOKENTRADERADDRESS'\n" | tee -a $EXECUTIONOUTPUTFILE
printf "TokenTrader ABI '$TOKENTRADERABI'\n" | tee -a $EXECUTIONOUTPUTFILE
printf "var tokenTraderABI = $TOKENTRADERABI;\n" > $TEMPINFILE
printf "TokenSellerFactory address '$TOKENSELLERFACTORYADDRESS'\n" | tee -a $EXECUTIONOUTPUTFILE
printf "TokenSellerFactory ABI '$TOKENSELLERFACTORYABI'\n" | tee -a $EXECUTIONOUTPUTFILE
printf "TokenSeller address '$TOKENSELLERADDRESS'\n" | tee -a $EXECUTIONOUTPUTFILE
printf "TokenSeller ABI '$TOKENSELLERABI'\n" | tee -a $EXECUTIONOUTPUTFILE
printf "var tokenSellerABI = $TOKENSELLERABI;\n" >> $TEMPINFILE
printf "GNTTokenTraderFactory address '$GNTTOKENTRADERFACTORYADDRESS'\n" | tee -a $EXECUTIONOUTPUTFILE
printf "GNTTokenTraderFactory ABI '$GNTTOKENTRADERFACTORYABI'\n" | tee -a $EXECUTIONOUTPUTFILE
printf "GNTTokenTrader address '$GNTTOKENTRADERADDRESS'\n" | tee -a $EXECUTIONOUTPUTFILE
printf "GNTTokenTrader ABI '$GNTTOKENTRADERABI'\n" | tee -a $EXECUTIONOUTPUTFILE

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $EXECUTIONOUTPUTFILE

loadScript("$TEMPINFILE");

var tokenA = web3.eth.contract($TOKENABI).at("$TOKENADDRESSA");
var tokenB = web3.eth.contract($TOKENABI).at("$TOKENADDRESSB");
var tokenC = web3.eth.contract($TOKENABI).at("$TOKENADDRESSC");
var tokenTraderFactory = web3.eth.contract($TOKENTRADERFACTORYABI).at("$TOKENTRADERFACTORYADDRESS");
var tokenTrader = web3.eth.contract(tokenTraderABI).at("$TOKENTRADERADDRESS");
var tokenSellerFactory = web3.eth.contract($TOKENSELLERFACTORYABI).at("$TOKENSELLERFACTORYADDRESS");
var tokenSeller = web3.eth.contract(tokenSellerABI).at("$TOKENSELLERADDRESS");
var gntTokenTraderFactory = web3.eth.contract($GNTTOKENTRADERFACTORYABI).at("$GNTTOKENTRADERFACTORYADDRESS");
var gntTokenTrader = web3.eth.contract($GNTTOKENTRADERABI).at("$GNTTOKENTRADERADDRESS");

var ACCOUNTS = 3;
var EPSILON = 0.01;

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

var accounts = [eth.accounts[0], eth.accounts[1], eth.accounts[2], "$TOKENADDRESSA", "$TOKENADDRESSB", "$TOKENADDRESSC", "$TOKENTRADERADDRESS", "$TOKENSELLERADDRESS", "$GNTTOKENTRADERADDRESS"];
var accountName = {};
accountName[eth.accounts[0]] = "Account #0";
accountName[eth.accounts[1]] = "Account #1";
accountName[eth.accounts[2]] = "Account #2";
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
  console.log("RESULT: accounts: " + JSON.stringify(accounts));
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
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed + " cost=" + tx.gasPrice.mul(txReceipt.gasUsed).div(1e18) +
    " block=" + txReceipt.blockNumber + " txId=" + txId);
}

function assertEtherBalance(account, testBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  var diff = etherBalance.minus(testBalance);
  if (diff >= -EPSILON && diff <= EPSILON) {
    console.log("RESULT: OK " + account + " has expected balance " + testBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + testBalance);
  }
}

function assertTokenBalance(account, token, testBalance) {
  var tokenBalance = token.balanceOf(account).div(1e18);
  var diff = tokenBalance.minus(testBalance);
  if (diff >= -EPSILON && diff <= EPSILON) {
    console.log("RESULT: OK " + account + " has expected " + accountName[token.address] + " token balance " + testBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has " + accountName[token.address] + " token balance " + tokenBalance + " <> expected " + testBalance);
  }
}

printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96899.8298);
assertTokenBalance(eth.accounts[1], tokenA, 700);
assertEtherBalance(eth.accounts[2], 96999.9971);
assertTokenBalance(eth.accounts[2], tokenA, 1000);
assertEtherBalance(tokenTrader.address, 100);
assertTokenBalance(tokenTrader.address, tokenA, 100);
assertEtherBalance(tokenSeller.address, 0);
assertTokenBalance(tokenSeller.address, tokenA, 100);
assertEtherBalance(gntTokenTrader.address, 0);
assertTokenBalance(gntTokenTrader.address, tokenA, 100);

for (var i = 0; i < ACCOUNTS; i++) {
  personal.unlockAccount(eth.accounts[i], "$PASSWORD", 100000);
}

// ---------- Testing Taker selling of tokens ----------
// Maker deactivating buy
console.log("RESULT: Deactivating TokenTrader Buy");
var tokenTraderDeactivateBuyTxId = tokenTrader.activate(false, true, {from: eth.accounts[1], to: "$TOKENTRADERADDRESS", gas: 300000});
console.log("tokenTraderDeactivateBuyTxId=" + tokenTraderDeactivateBuyTxId);
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderDeactivateBuyTxId", tokenTraderDeactivateBuyTxId);

console.log("RESULT: Approving 200 tokens from eth.accounts[2] to contract " + "$TOKENTRADERADDRESS");
var tokenApproveTxId = tokenA.approve("$TOKENTRADERADDRESS", 200e18, {from: eth.accounts[2], to: "$TOKENADDRESS", value: 0, gas: 300000});
while (txpool.status.pending > 0) {
}
printTxData("tokenApproveTxId", tokenApproveTxId);

console.log("RESULT: Sending 90 tokens from eth.accounts[2] to contract " + "$TOKENTRADERADDRESS");
var tokenTraderSellTokenTxId = tokenTrader.takerSellAsset(90e18, {from: eth.accounts[2], to: "$TOKENTRADERADDRESS", value: 0, gas: 300000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderSellTokenTxId", tokenTraderSellTokenTxId);
console.log("RESULT: Expecting no change in balances except for a bit of gas from eth.accounts[2]");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96899.8293);
assertTokenBalance(eth.accounts[1], tokenA, 700);
assertEtherBalance(eth.accounts[2], 96999.9958);
assertTokenBalance(eth.accounts[2], tokenA, 1000);
assertEtherBalance(tokenTrader.address, 100);
assertTokenBalance(tokenTrader.address, tokenA, 100);
assertEtherBalance(tokenSeller.address, 0);
assertTokenBalance(tokenSeller.address, tokenA, 100);
assertEtherBalance(gntTokenTrader.address, 0);
assertTokenBalance(gntTokenTrader.address, tokenA, 100);

// Maker reactivating buy - Buying at buyPrice=110000 per 100000 units = 1.1 ETH per token
console.log("RESULT: Activating TokenTrader Buy (Sell active)");
var tokenTraderActivateBuyTxId = tokenTrader.activate(true, true, {from: eth.accounts[1], to: "$TOKENTRADERADDRESS", gas: 300000});
console.log("tokenTraderActivateBuyTxId=" + tokenTraderActivateBuyTxId);
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderActivateBuyTxId", tokenTraderActivateBuyTxId);
console.log("RESULT: Taker Selling - Sending 90 tokens (exchange for 99 ETH) from eth.accounts[2] to contract " + "$TOKENTRADERADDRESS");
var tokenTraderSellTokenTxId = tokenTrader.takerSellAsset(90e18, {from: eth.accounts[2], to: "$TOKENTRADERADDRESS", value: 0, gas: 300000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderSellTokenTxId", tokenTraderSellTokenTxId);
console.log("RESULT: Expecting change in eth.accounts[2] and TokenTrader balances");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96899.8287);
assertTokenBalance(eth.accounts[1], tokenA, 700);
assertEtherBalance(eth.accounts[2], 97098.9948);
assertTokenBalance(eth.accounts[2], tokenA, 910);
assertEtherBalance(tokenTrader.address, 1);
assertTokenBalance(tokenTrader.address, tokenA, 190);
assertEtherBalance(tokenSeller.address, 0);
assertTokenBalance(tokenSeller.address, tokenA, 100);
assertEtherBalance(gntTokenTrader.address, 0);
assertTokenBalance(gntTokenTrader.address, tokenA, 100);

// Taker selling with limited ETH in contract
console.log("RESULT: Taker Selling - Sending 90 tokens (exchange for 99 ETH) from eth.accounts[2] to contract " + "$TOKENTRADERADDRESS" + " but only 1 ETH remaining to pay for tokens (exchange for 0.909090909090900000 tokens");
var tokenTraderSellTokenTxId = tokenTrader.takerSellAsset(90e18, {from: eth.accounts[2], to: "$TOKENTRADERADDRESS", value: 0, gas: 300000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderSellTokenTxId", tokenTraderSellTokenTxId);
console.log("RESULT: Expecting change in eth.accounts[2] and TokenTrader balances");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96899.8287);
assertTokenBalance(eth.accounts[1], tokenA, 700);
assertEtherBalance(eth.accounts[2], 97099.9938);
assertTokenBalance(eth.accounts[2], tokenA, 909.0909);
assertEtherBalance(tokenTrader.address, 0);
assertTokenBalance(tokenTrader.address, tokenA, 190.9091);
assertEtherBalance(tokenSeller.address, 0);
assertTokenBalance(tokenSeller.address, tokenA, 100);
assertEtherBalance(gntTokenTrader.address, 0);
assertTokenBalance(gntTokenTrader.address, tokenA, 100);

// ---------- Testing Taker buying of tokens ----------
// Maker deactivating sell
console.log("RESULT: Deactivating TokenTrader Sell");
var tokenTraderDeactivateSellTxId = tokenTrader.activate(true, false, {from: eth.accounts[1], to: "$TOKENTRADERADDRESS", gas: 300000});
console.log("tokenTraderDeactivateSellTxId=" + tokenTraderDeactivateSellTxId);
console.log("RESULT: Deactivating TokenSeller Sell");
var tokenSellerDeactivateSellTxId = tokenSeller.activate(false, {from: eth.accounts[1], to: "$TOKENSELLERADDRESS", gas: 300000});
console.log("tokenSellerDeactivateSellTxId=" + tokenSellerDeactivateSellTxId);
console.log("RESULT: Deactivating GNTTokenTrader Sell");
var gntTokenTraderDeactivateSellTxId = gntTokenTrader.activate(false, {from: eth.accounts[1], to: "$GNTTOKENTRADERADDRESS", gas: 300000});
console.log("gntTokenTraderDeactivateSellTxId=" + gntTokenTraderDeactivateSellTxId);
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderDeactivateSellTxId", tokenTraderDeactivateSellTxId);
printTxData("tokenSellerDeactivateSellTxId", tokenSellerDeactivateSellTxId);
printTxData("gntTokenTraderDeactivateSellTxId", gntTokenTraderDeactivateSellTxId);

var tokenTraderBuyTokenTxId = eth.sendTransaction({from: eth.accounts[2], to: "$TOKENTRADERADDRESS", value: web3.toWei(100, "ether"), gas: 100000});
var tokenSellerBuyTokenTxId = eth.sendTransaction({from: eth.accounts[2], to: "$TOKENSELLERADDRESS", value: web3.toWei(100, "ether"), gas: 100000});
var gntTokenTraderBuyTokenTxId = eth.sendTransaction({from: eth.accounts[2], to: "$GNTTOKENTRADERADDRESS", value: web3.toWei(100, "ether"), gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderBuyTokenTxId", tokenTraderBuyTokenTxId);
printTxData("tokenSellerBuyTokenTxId", tokenSellerBuyTokenTxId);
printTxData("gntTokenTraderBuyTokenTxId", gntTokenTraderBuyTokenTxId);

console.log("RESULT: Expecting no change in balances except for a bit of gas from eth.accounts[1] (deactivate) and eth.accounts[2] (trading inactive)");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96899.8276);
assertTokenBalance(eth.accounts[1], tokenA, 700);
assertEtherBalance(eth.accounts[2], 97099.9921);
assertTokenBalance(eth.accounts[2], tokenA, 909.0909);
assertEtherBalance(tokenTrader.address, 0);
assertTokenBalance(tokenTrader.address, tokenA, 190.9091);
assertEtherBalance(tokenSeller.address, 0);
assertTokenBalance(tokenSeller.address, tokenA, 100);
assertEtherBalance(gntTokenTrader.address, 0);
assertTokenBalance(gntTokenTrader.address, tokenA, 100);

// Maker activating sell - Selling at sellPrice=120000 per 100000 units = 1.2 ETH per token
console.log("RESULT: Activating TokenTrader Sell (Buy active)");
var tokenTraderActivateSellTxId = tokenTrader.activate(true, true, {from: eth.accounts[1], to: "$TOKENTRADERADDRESS", gas: 300000});
console.log("tokenTraderActivateSellTxId=" + tokenTraderActivateSellTxId);
console.log("RESULT: Activating TokenSeller Sell");
var tokenSellerActivateSellTxId = tokenSeller.activate(true, {from: eth.accounts[1], to: "$TOKENTRADERADDRESS", gas: 300000});
console.log("tokenSellerActivateSellTxId=" + tokenSellerActivateSellTxId);
console.log("RESULT: Activating GNTTokenTrader Sell (Buy active)");
var gntTokenTraderActivateSellTxId = gntTokenTrader.activate(true, {from: eth.accounts[1], to: "$GNTTOKENTRADERADDRESS", gas: 300000});
console.log("gntTokenTraderActivateSellTxId=" + gntTokenTraderActivateSellTxId);
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderActivateSellTxId", tokenTraderActivateSellTxId);
printTxData("tokenSellerActivateSellTxId", tokenSellerActivateSellTxId);
printTxData("gntTokenTraderActivateSellTxId", gntTokenTraderActivateSellTxId);

var tokenTraderBuyTokenTxId = eth.sendTransaction({from: eth.accounts[2], to: "$TOKENTRADERADDRESS", value: web3.toWei(100, "ether"), gas: 100000});
var tokenSellerBuyTokenTxId = eth.sendTransaction({from: eth.accounts[2], to: "$TOKENSELLERADDRESS", value: web3.toWei(100, "ether"), gas: 100000});
var gntTokenTraderBuyTokenTxId = eth.sendTransaction({from: eth.accounts[2], to: "$GNTTOKENTRADERADDRESS", value: web3.toWei(100, "ether"), gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderBuyTokenTxId", tokenTraderBuyTokenTxId);
printTxData("tokenSellerBuyTokenTxId", tokenSellerBuyTokenTxId);
printTxData("gntTokenTraderBuyTokenTxId", gntTokenTraderBuyTokenTxId);

console.log("RESULT: Expecting change in eth.accounts[1] (activating), eth.accounts[2] (-300 ETH for 200/1.2 + 100/1.3 tokens) plus decrease in TokenTrader, TokenSeller and GNTTokenTraderbalances");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96899.8253);
assertTokenBalance(eth.accounts[1], tokenA, 700);
assertEtherBalance(eth.accounts[2], 96799.9898);
assertTokenBalance(eth.accounts[2], tokenA, 1152.6806);
assertEtherBalance(tokenTrader.address, 100);
assertTokenBalance(tokenTrader.address, tokenA, 107.5758);
assertEtherBalance(tokenSeller.address, 100);
assertTokenBalance(tokenSeller.address, tokenA, 16.6667);
assertEtherBalance(gntTokenTrader.address, 100);
assertTokenBalance(gntTokenTrader.address, tokenA, 23.0769);

var tokenTraderBuyTokenTxId = eth.sendTransaction({from: eth.accounts[2], to: "$TOKENTRADERADDRESS", value: web3.toWei(200, "ether"), gas: 100000});
var tokenSellerBuyTokenTxId = eth.sendTransaction({from: eth.accounts[2], to: "$TOKENSELLERADDRESS", value: web3.toWei(200, "ether"), gas: 100000});
var gntTokenTraderBuyTokenTxId = eth.sendTransaction({from: eth.accounts[2], to: "$GNTTOKENTRADERADDRESS", value: web3.toWei(200, "ether"), gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderBuyTokenTxId", tokenTraderBuyTokenTxId);
printTxData("tokenSellerBuyTokenTxId", tokenSellerBuyTokenTxId);
printTxData("gntTokenTraderBuyTokenTxId", gntTokenTraderBuyTokenTxId);

console.log("RESULT: Expecting change in eth.accounts[2] plus decrease in TokenTrader, TokenSeller and GNTTokenTrader balances, but limited tokens left");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96899.8253);
assertTokenBalance(eth.accounts[1], tokenA, 700);
assertEtherBalance(eth.accounts[2], 96620.8972);
assertTokenBalance(eth.accounts[2], tokenA, 1300);
assertEtherBalance(tokenTrader.address, 229.0909);
assertTokenBalance(tokenTrader.address, tokenA, 0);
assertEtherBalance(tokenSeller.address, 120);
assertTokenBalance(tokenSeller.address, tokenA, 0);
assertEtherBalance(gntTokenTrader.address, 130);
assertTokenBalance(gntTokenTrader.address, tokenA, 0);

console.log("RESULT: Maker transferring 30 tokens to tokenTrader, tokenSeller and gntTokenTrader");
var traderTransferTokenTxId = tokenA.transfer("$TOKENTRADERADDRESS", 30e18, {from: eth.accounts[1], gas: 100000});
var sellerTransferTokenTxId = tokenA.transfer("$TOKENSELLERADDRESS", 30e18, {from: eth.accounts[1], gas: 100000});
var gntTraderTransferTokenTxId = tokenA.transfer("$GNTTOKENTRADERADDRESS", 30e18, {from: eth.accounts[1], gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("traderTransferTokenTxId", traderTransferTokenTxId);
printTxData("sellerTransferTokenTxId", sellerTransferTokenTxId);
printTxData("gntTraderTransferTokenTxId", gntTraderTransferTokenTxId);
console.log("RESULT: Expecting change in eth.accounts[1] tokens plus 30 tokens in TokenTrader, TokenSeller and GNTTokenTrader");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96899.8222);
assertTokenBalance(eth.accounts[1], tokenA, 610);
assertEtherBalance(eth.accounts[2], 96620.8972);
assertTokenBalance(eth.accounts[2], tokenA, 1300);
assertEtherBalance(tokenTrader.address, 229.0909);
assertTokenBalance(tokenTrader.address, tokenA, 30);
assertEtherBalance(tokenSeller.address, 120);
assertTokenBalance(tokenSeller.address, tokenA, 30);
assertEtherBalance(gntTokenTrader.address, 130);
assertTokenBalance(gntTokenTrader.address, tokenA, 30);

// Maker send tokens to trader contracts, then withdraw these tokens and ETH
console.log("RESULT: Maker transferring 30 ETH to tokenTrader, tokenSeller and gntTokenTrader. This will buy tokens");
var tokenTraderAddEtherTxId = eth.sendTransaction({from: eth.accounts[1], to: "$TOKENTRADERADDRESS", value: web3.toWei(30, "ether"), gas: 100000});
var tokenSellerAddEtherTxId = eth.sendTransaction({from: eth.accounts[1], to: "$TOKENSELLERADDRESS", value: web3.toWei(30, "ether"), gas: 100000});
var gntTokenTraderAddEtherTxId = eth.sendTransaction({from: eth.accounts[1], to: "$GNTTOKENTRADERADDRESS", value: web3.toWei(30, "ether"), gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderAddEtherTxId", tokenTraderAddEtherTxId);
printTxData("tokenSellerAddEtherTxId", tokenSellerAddEtherTxId);
printTxData("gntTokenTraderAddEtherTxId", gntTokenTraderAddEtherTxId);
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96809.8200);
assertTokenBalance(eth.accounts[1], tokenA, 683.0769);
assertEtherBalance(eth.accounts[2], 96620.8972);
assertTokenBalance(eth.accounts[2], tokenA, 1300);
assertEtherBalance(tokenTrader.address, 259.0909);
assertTokenBalance(tokenTrader.address, tokenA, 5);
assertEtherBalance(tokenSeller.address, 150);
assertTokenBalance(tokenSeller.address, tokenA, 5);
assertEtherBalance(gntTokenTrader.address, 160);
assertTokenBalance(gntTokenTrader.address, tokenA, 6.9231);

// ---------- Testing Maker withdrawing asset and ETH ----------
var tokenTraderWithdrawEtherTxId1 = tokenTrader.makerWithdrawEther(1e18, {from: eth.accounts[1], gas: 300000});
var tokenTraderWithdrawAssetTxId1 = tokenTrader.makerWithdrawAsset(1e18, {from: eth.accounts[1], gas: 300000});
var tokenSellerWithdrawEtherTxId1 = tokenSeller.makerWithdrawEther(1e18, {from: eth.accounts[1], gas: 300000});
var tokenSellerWithdrawAssetTxId1 = tokenSeller.makerWithdrawAsset(1e18, {from: eth.accounts[1], gas: 300000});
var gntTokenTraderWithdrawEtherTxId1 = gntTokenTrader.withdraw(1e18, {from: eth.accounts[1], gas: 300000});
var gntTokenTraderWithdrawAssetTxId1 = gntTokenTrader.withdrawAsset(1e18, {from: eth.accounts[1], gas: 300000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderWithdrawEtherTxId1", tokenTraderWithdrawEtherTxId1);
printTxData("tokenTraderWithdrawAssetTxId1", tokenTraderWithdrawAssetTxId1);
printTxData("tokenSellerWithdrawEtherTxId1", tokenSellerWithdrawEtherTxId1);
printTxData("tokenSellerWithdrawAssetTxId1", tokenSellerWithdrawAssetTxId1);
printTxData("gntTokenTraderWithdrawEtherTxId1", gntTokenTraderWithdrawEtherTxId1);
printTxData("gntTokenTraderWithdrawAssetTxId1", gntTokenTraderWithdrawAssetTxId1);
console.log("RESULT: Expecting increase of 1 ETH and 1 tokens in eth.accounts[1] tokens and decrease of 1 ETH and 1 tokens in TokenTrader, TokenSeller and GNTTOkenTrader");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96812.8160);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertEtherBalance(eth.accounts[2], 96620.8972);
assertTokenBalance(eth.accounts[2], tokenA, 1300);
assertEtherBalance(tokenTrader.address, 258.0909);
assertTokenBalance(tokenTrader.address, tokenA, 4);
assertEtherBalance(tokenSeller.address, 149);
assertTokenBalance(tokenSeller.address, tokenA, 4);
assertEtherBalance(gntTokenTrader.address, 159);
assertTokenBalance(gntTokenTrader.address, tokenA, 5.9231);

var tokenTraderWithdrawEtherTxId2 = tokenTrader.makerWithdrawEther(5e20, {from: eth.accounts[1], gas: 300000});
var tokenTraderWithdrawAssetTxId2 = tokenTrader.makerWithdrawAsset(5e20, {from: eth.accounts[1], gas: 300000});
var tokenSellerWithdrawEtherTxId2 = tokenSeller.makerWithdrawEther(5e20, {from: eth.accounts[1], gas: 300000});
var tokenSellerWithdrawAssetTxId2 = tokenSeller.makerWithdrawAsset(5e20, {from: eth.accounts[1], gas: 300000});
var gntTokenTraderWithdrawEtherTxId2 = gntTokenTrader.withdraw(5e20, {from: eth.accounts[1], gas: 300000});
var gntTokenTraderWithdrawAssetTxId2 = gntTokenTrader.withdrawAsset(5e20, {from: eth.accounts[1], gas: 300000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderWithdrawEtherTxId2", tokenTraderWithdrawEtherTxId2);
printTxData("tokenTraderWithdrawAssetTxId2", tokenTraderWithdrawAssetTxId2);
printTxData("tokenSellerWithdrawEtherTxId2", tokenSellerWithdrawEtherTxId2);
printTxData("tokenSellerWithdrawAssetTxId2", tokenSellerWithdrawAssetTxId2);
printTxData("gntTokenTraderWithdrawEtherTxId2", gntTokenTraderWithdrawEtherTxId2);
printTxData("gntTokenTraderWithdrawAssetTxId2", gntTokenTraderWithdrawAssetTxId2);
console.log("RESULT: Expecting failure to increase of 500ETH and 500 tokens in eth.accounts[1] tokens and decrease of 5 ETH and 5 tokens in TokenTrader, TokenSeller and GNTTOkenTrader");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96812.8132);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertEtherBalance(eth.accounts[2], 96620.8970);
assertTokenBalance(eth.accounts[2], tokenA, 1300);
assertEtherBalance(tokenTrader.address, 258.0909);
assertTokenBalance(tokenTrader.address, tokenA, 4);
assertEtherBalance(tokenSeller.address, 149);
assertTokenBalance(tokenSeller.address, tokenA, 4);
assertEtherBalance(gntTokenTrader.address, 159);
assertTokenBalance(gntTokenTrader.address, tokenA, 5.9231);

exit;

EOF

grep "RESULT: " $EXECUTIONOUTPUTFILE | sed "s/RESULT: //" > $EXECUTIONRESULTFILE
cat $EXECUTIONRESULTFILE
