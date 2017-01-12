#!/bin/bash
# --------------------------------------------------------------------
# Testing Contracts At https://github.com/bokkypoobah/TokenTrader
# for https://cryptoderivatives.market/
#
# Testing Other Methods And Conditions
#
# (c) BokkyPooBah 2017. The MIT licence.
# --------------------------------------------------------------------

GETHATTACHPOINT=`grep IPCFILE settings.txt | sed "s/^.*=//"`
PASSWORD=`grep PASSWORD settings.txt | sed "s/^.*=//"`

OTHEROUTPUTFILE=`grep OTHEROUTPUTFILE settings.txt | sed "s/^.*=//"`
OTHERRESULTFILE=`grep OTHERRESULTFILE settings.txt | sed "s/^.*=//"`

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

printf "Connecting to geth on endpoint '$GETHATTACHPOINT'\n" | tee $OTHEROUTPUTFILE
printf "Token address '$TOKENADDRESS'\n" | tee -a $OTHEROUTPUTFILE
printf "Token ABI '$TOKENABI'\n" | tee -a $OTHEROUTPUTFILE
printf "TokenTraderFactory address '$TOKENTRADERFACTORYADDRESS'\n" | tee -a $OTHEROUTPUTFILE
printf "TokenTraderFactory ABI '$TOKENTRADERFACTORYABI'\n" | tee -a $OTHEROUTPUTFILE
printf "TokenTrader address '$TOKENTRADERADDRESS'\n" | tee -a $OTHEROUTPUTFILE
printf "TokenTrader ABI '$TOKENTRADERABI'\n" | tee -a $OTHEROUTPUTFILE
printf "TokenSellerFactory address '$TOKENSELLERFACTORYADDRESS'\n" | tee -a $OTHEROUTPUTFILE
printf "TokenSellerFactory ABI '$TOKENSELLERFACTORYABI'\n" | tee -a $OTHEROUTPUTFILE
printf "TokenSeller address '$TOKENSELLERADDRESS'\n" | tee -a $OTHEROUTPUTFILE
printf "TokenSeller ABI '$TOKENSELLERABI'\n" | tee -a $OTHEROUTPUTFILE
printf "GNTTokenTraderFactory address '$GNTTOKENTRADERFACTORYADDRESS'\n" | tee -a $OTHEROUTPUTFILE
printf "GNTTokenTraderFactory ABI '$GNTTOKENTRADERFACTORYABI'\n" | tee -a $OTHEROUTPUTFILE
printf "GNTTokenTrader address '$GNTTOKENTRADERADDRESS'\n" | tee -a $OTHEROUTPUTFILE
printf "GNTTokenTrader ABI '$GNTTOKENTRADERABI'\n" | tee -a $OTHEROUTPUTFILE

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $OTHEROUTPUTFILE

var tokenA = web3.eth.contract($TOKENABI).at("$TOKENADDRESSA");
var tokenB = web3.eth.contract($TOKENABI).at("$TOKENADDRESSB");
var tokenC = web3.eth.contract($TOKENABI).at("$TOKENADDRESSC");
var tokenTraderFactory = web3.eth.contract($TOKENTRADERFACTORYABI).at("$TOKENTRADERFACTORYADDRESS");
var tokenTrader = web3.eth.contract($TOKENTRADERABI).at("$TOKENTRADERADDRESS");
var tokenSellerFactory = web3.eth.contract($TOKENSELLERFACTORYABI).at("$TOKENSELLERFACTORYADDRESS");
var tokenSeller = web3.eth.contract($TOKENSELLERABI).at("$TOKENSELLERADDRESS");
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

var accounts = [eth.accounts[0], eth.accounts[1], eth.accounts[2], "$TOKENADDRESSA", "$TOKENADDRESSB", "$TOKENADDRESSC", "$TOKENTRADERFACTORYADDRESS", "$TOKENSELLERFACTORYADDRESS", "$GNTTOKENTRADERFACTORYADDRESS", "$TOKENTRADERADDRESS", "$TOKENSELLERADDRESS", "$GNTTOKENTRADERADDRESS"];
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
assertEtherBalance(eth.accounts[1], 96812.8623);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertEtherBalance(eth.accounts[2], 96620.8970);
assertTokenBalance(eth.accounts[2], tokenA, 1300);
assertEtherBalance(tokenTrader.address, 258.0909);
assertTokenBalance(tokenTrader.address, tokenA, 4);
assertEtherBalance(tokenSeller.address, 149);
assertTokenBalance(tokenSeller.address, tokenA, 4);
assertEtherBalance(gntTokenTrader.address, 159);
assertTokenBalance(gntTokenTrader.address, tokenA, 5.9231);
for (var i = 0; i < ACCOUNTS; i++) {
  personal.unlockAccount(eth.accounts[i], "$PASSWORD", 100000);
}

console.log("RESULT: Owner transferring 10 tokenB to tokenTraderFactory and tokenSellerFactory");
var ownerTraderFactoryTransferTokenTxId = tokenB.transfer("$TOKENTRADERFACTORYADDRESS", 10e18, {from: eth.accounts[1], gas: 100000});
var ownerSellerFactoryTransferTokenTxId = tokenB.transfer("$TOKENSELLERFACTORYADDRESS", 10e18, {from: eth.accounts[1], gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("ownerTraderFactoryTransferTokenTxId", ownerTraderFactoryTransferTokenTxId);
printTxData("ownerSellerFactoryTransferTokenTxId", ownerSellerFactoryTransferTokenTxId);
console.log("RESULT: Expecting change in eth.accounts[1] tokens plus 10 tokens in TokenTraderFactory and TokenSellerFactory");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96812.8623);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertTokenBalance(eth.accounts[1], tokenB, 980);
assertEtherBalance(eth.accounts[2], 96620.8970);
assertTokenBalance(eth.accounts[2], tokenA, 1300);
assertTokenBalance(tokenTraderFactory.address, tokenB, 10);
assertTokenBalance(tokenSellerFactory.address, tokenB, 10);
assertEtherBalance(tokenTrader.address, 258.0909);
assertTokenBalance(tokenTrader.address, tokenA, 4);
assertEtherBalance(tokenSeller.address, 149);
assertTokenBalance(tokenSeller.address, tokenA, 4);
assertEtherBalance(gntTokenTrader.address, 159);
assertTokenBalance(gntTokenTrader.address, tokenA, 5.9231);

console.log("RESULT: Owner withdrawing 1 tokenB from tokenTraderFactory and tokenSellerFactory");
var ownerTraderFactoryWithdrawERC20TokenTxId = tokenTraderFactory.ownerWithdrawERC20Token(tokenB.address, 1e18, {from: eth.accounts[1], gas: 100000});
var ownerSellerFactoryWithdrawERC20TokenTxId = tokenSellerFactory.ownerWithdrawERC20Token(tokenB.address, 1e18, {from: eth.accounts[1], gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("ownerTraderFactoryWithdrawERC20TokenTxId", ownerTraderFactoryWithdrawERC20TokenTxId);
printTxData("ownerSellerFactoryWithdrawERC20TokenTxId", ownerSellerFactoryWithdrawERC20TokenTxId);
console.log("RESULT: Expecting change in eth.accounts[1] tokens minus 1 token in TokenTraderFactory and TokenSellerFactory");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96812.8580);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertTokenBalance(eth.accounts[1], tokenB, 982);
assertEtherBalance(eth.accounts[2], 96620.8970);
assertTokenBalance(eth.accounts[2], tokenA, 1300);
assertTokenBalance(tokenTraderFactory.address, tokenB, 9);
assertTokenBalance(tokenSellerFactory.address, tokenB, 9);
assertEtherBalance(tokenTrader.address, 258.0909);
assertTokenBalance(tokenTrader.address, tokenA, 4);
assertEtherBalance(tokenSeller.address, 149);
assertTokenBalance(tokenSeller.address, tokenA, 4);
assertEtherBalance(gntTokenTrader.address, 159);
assertTokenBalance(gntTokenTrader.address, tokenA, 5.9231);

console.log("RESULT: Owner transferring 10 tokenB to tokenTrader, tokenSeller and gntTokenTrader");
var ownerTraderTransferTokenTxId = tokenB.transfer(tokenTrader.address, 10e18, {from: eth.accounts[1], gas: 100000});
var ownerSellerTransferTokenTxId = tokenB.transfer(tokenSeller.address, 10e18, {from: eth.accounts[1], gas: 100000});
var ownerGntTraderTransferTokenTxId = tokenB.transfer(gntTokenTrader.address, 10e18, {from: eth.accounts[1], gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("ownerTraderTransferTokenTxId", ownerTraderTransferTokenTxId);
printTxData("ownerSellerTransferTokenTxId", ownerSellerTransferTokenTxId);
printTxData("ownerGntTraderTransferTokenTxId", ownerGntTraderTransferTokenTxId);
console.log("RESULT: Expecting change in eth.accounts[1] tokens plus 10 tokens in TokenTrader, TokenSeller and GNTTokenTrader");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96812.8550);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertTokenBalance(eth.accounts[1], tokenB, 952);
assertEtherBalance(eth.accounts[2], 96620.8970);
assertTokenBalance(eth.accounts[2], tokenA, 1300);
assertTokenBalance(tokenTraderFactory.address, tokenB, 9);
assertTokenBalance(tokenSellerFactory.address, tokenB, 9);
assertEtherBalance(tokenTrader.address, 258.0909);
assertTokenBalance(tokenTrader.address, tokenA, 4);
assertTokenBalance(tokenTrader.address, tokenB, 10);
assertEtherBalance(tokenSeller.address, 149);
assertTokenBalance(tokenSeller.address, tokenA, 4);
assertTokenBalance(tokenSeller.address, tokenB, 10);
assertEtherBalance(gntTokenTrader.address, 159);
assertTokenBalance(gntTokenTrader.address, tokenA, 5.9231);
assertTokenBalance(gntTokenTrader.address, tokenB, 10);

console.log("RESULT: Owner withdrawing 1 tokenB from tokenTrader, tokenSeller and gntTokenTrader");
var ownerTraderWithdrawERC20TokenTxId = tokenTrader.makerWithdrawERC20Token(tokenB.address, 1e18, {from: eth.accounts[1], gas: 100000});
var ownerSellerWithdrawERC20TokenTxId = tokenSeller.makerWithdrawERC20Token(tokenB.address, 1e18, {from: eth.accounts[1], gas: 100000});
var ownerGntWithdrawERC20TokenTxId = gntTokenTrader.withdrawToken(tokenB.address, 1e18, {from: eth.accounts[1], gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("ownerTraderWithdrawERC20TokenTxId", ownerTraderWithdrawERC20TokenTxId);
printTxData("ownerSellerWithdrawERC20TokenTxId", ownerSellerWithdrawERC20TokenTxId);
printTxData("ownerGntWithdrawERC20TokenTxId", ownerGntWithdrawERC20TokenTxId);
console.log("RESULT: Expecting change in eth.accounts[1] tokens minus 1 token in tokenTrader, tokenSeller and gntTokenTrader");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96812.8527);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertTokenBalance(eth.accounts[1], tokenB, 955);
assertEtherBalance(eth.accounts[2], 96620.8970);
assertTokenBalance(eth.accounts[2], tokenA, 1300);
assertTokenBalance(tokenTraderFactory.address, tokenB, 9);
assertTokenBalance(tokenSellerFactory.address, tokenB, 9);
assertEtherBalance(tokenTrader.address, 258.0909);
assertTokenBalance(tokenTrader.address, tokenA, 4);
assertTokenBalance(tokenTrader.address, tokenB, 9);
assertEtherBalance(tokenSeller.address, 149);
assertTokenBalance(tokenSeller.address, tokenA, 4);
assertTokenBalance(tokenSeller.address, tokenB, 9);
assertEtherBalance(gntTokenTrader.address, 159);
assertTokenBalance(gntTokenTrader.address, tokenA, 5.9231);
assertTokenBalance(gntTokenTrader.address, tokenB, 9);

console.log("RESULT: Testing failure in createTradeContract for Factories. gas==gasUsed");
var createTradeContract1TxId = tokenTraderFactory.createTradeContract("$TOKENADDRESSB", 0, 120000, 100000, true, true, {from: eth.accounts[1], gas: 1000000});
var createTradeContract2TxId = tokenTraderFactory.createTradeContract("$TOKENADDRESSB", 110000, 0, 100000, true, true, {from: eth.accounts[1], gas: 1000000});
var createTradeContract3TxId = tokenTraderFactory.createTradeContract("$TOKENADDRESSB", 120000, 110000, 100000, true, true, {from: eth.accounts[1], gas: 1000000});
var createTradeContract4TxId = tokenTraderFactory.createTradeContract("$TOKENADDRESSB", 110000, 120000, 0, true, true, {from: eth.accounts[1], gas: 1000000});
var createSaleContract1TxId = tokenSellerFactory.createSaleContract("$TOKENADDRESSB", 0, 100000, true, {from: eth.accounts[1], gas: 1000000});
var createSaleContract2TxId = tokenSellerFactory.createSaleContract("$TOKENADDRESSB", 120000, 0, true, {from: eth.accounts[1], gas: 1000000});
var createGNTTradeContract1TxId = gntTokenTraderFactory.createTradeContract("$TOKENADDRESSB", 130000, 0, true, {from: eth.accounts[1], gas: 1000000});
while (txpool.status.pending > 0) {
}
printTxData("createTradeContract1TxId", createTradeContract1TxId);
printTxData("createTradeContract2TxId", createTradeContract2TxId);
printTxData("createTradeContract3TxId", createTradeContract3TxId);
printTxData("createTradeContract4TxId", createTradeContract4TxId);
printTxData("createSaleContract1TxId", createSaleContract1TxId);
printTxData("createSaleContract2TxId", createSaleContract2TxId);
printTxData("createGNTTradeContract1TxId", createGNTTradeContract1TxId);
console.log("RESULT: Expecting small change in eth.accounts[1]");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96812.7127);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertTokenBalance(eth.accounts[1], tokenB, 955);
assertEtherBalance(eth.accounts[2], 96620.8970);
assertTokenBalance(eth.accounts[2], tokenA, 1300);
assertTokenBalance(tokenTraderFactory.address, tokenB, 9);
assertTokenBalance(tokenSellerFactory.address, tokenB, 9);
assertEtherBalance(tokenTrader.address, 258.0909);
assertTokenBalance(tokenTrader.address, tokenA, 4);
assertTokenBalance(tokenTrader.address, tokenB, 9);
assertEtherBalance(tokenSeller.address, 149);
assertTokenBalance(tokenSeller.address, tokenA, 4);
assertTokenBalance(tokenSeller.address, tokenB, 9);
assertEtherBalance(gntTokenTrader.address, 159);
assertTokenBalance(gntTokenTrader.address, tokenA, 5.9231);
assertTokenBalance(gntTokenTrader.address, tokenB, 9);


exit;

EOF

grep "RESULT: " $OTHEROUTPUTFILE | sed "s/RESULT: //" > $OTHERRESULTFILE
cat $OTHERRESULTFILE
