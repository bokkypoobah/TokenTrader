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

TEMPINFILE=`grep TEMPINFILE settings.txt | sed "s/^.*=//"`
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
printf "var tokenSellerABI = $TOKENSELLERABI;\n" >> $TEMPINFILE
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
printf "var tokenTraderABI = $TOKENTRADERABI;\n" > $TEMPINFILE
printf "TokenSellerFactory address '$TOKENSELLERFACTORYADDRESS'\n" | tee -a $OTHEROUTPUTFILE
printf "TokenSellerFactory ABI '$TOKENSELLERFACTORYABI'\n" | tee -a $OTHEROUTPUTFILE
printf "TokenSeller address '$TOKENSELLERADDRESS'\n" | tee -a $OTHEROUTPUTFILE
printf "TokenSeller ABI '$TOKENSELLERABI'\n" | tee -a $OTHEROUTPUTFILE
printf "var tokenSellerABI = $TOKENSELLERABI;\n" >> $TEMPINFILE
printf "GNTTokenTraderFactory address '$GNTTOKENTRADERFACTORYADDRESS'\n" | tee -a $OTHEROUTPUTFILE
printf "GNTTokenTraderFactory ABI '$GNTTOKENTRADERFACTORYABI'\n" | tee -a $OTHEROUTPUTFILE
printf "GNTTokenTrader address '$GNTTOKENTRADERADDRESS'\n" | tee -a $OTHEROUTPUTFILE
printf "GNTTokenTrader ABI '$GNTTOKENTRADERABI'\n" | tee -a $OTHEROUTPUTFILE

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $OTHEROUTPUTFILE

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
assertEtherBalance(eth.accounts[1], 96812.8132);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertEtherBalance(eth.accounts[2], 96620.8972);
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
assertEtherBalance(eth.accounts[1], 96812.8112);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertTokenBalance(eth.accounts[1], tokenB, 980);
assertEtherBalance(eth.accounts[2], 96620.8972);
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
assertEtherBalance(eth.accounts[1], 96812.8096);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertTokenBalance(eth.accounts[1], tokenB, 982);
assertEtherBalance(eth.accounts[2], 96620.8972);
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
assertEtherBalance(eth.accounts[1], 96812.8066);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertTokenBalance(eth.accounts[1], tokenB, 952);
assertEtherBalance(eth.accounts[2], 96620.8972);
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
assertEtherBalance(eth.accounts[1], 96812.8043);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertTokenBalance(eth.accounts[1], tokenB, 955);
assertEtherBalance(eth.accounts[2], 96620.8973);
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
var createTradeContract5TxId = tokenTraderFactory.createTradeContract("0x0", 110000, 120000, 100000, true, true, {from: eth.accounts[1], gas: 1000000});
var createSaleContract1TxId = tokenSellerFactory.createSaleContract("$TOKENADDRESSB", 0, 100000, true, {from: eth.accounts[1], gas: 1000000});
var createSaleContract2TxId = tokenSellerFactory.createSaleContract("$TOKENADDRESSB", 120000, 0, true, {from: eth.accounts[1], gas: 1000000});
var createSaleContract3TxId = tokenSellerFactory.createSaleContract("0x0", 120000, 100000, true, {from: eth.accounts[1], gas: 1000000});
var createGNTTradeContract1TxId = gntTokenTraderFactory.createTradeContract("$TOKENADDRESSB", 130000, 0, true, {from: eth.accounts[1], gas: 1000000});
while (txpool.status.pending > 0) {
}
printTxData("createTradeContract1TxId", createTradeContract1TxId);
printTxData("createTradeContract2TxId", createTradeContract2TxId);
printTxData("createTradeContract3TxId", createTradeContract3TxId);
printTxData("createTradeContract4TxId", createTradeContract4TxId);
printTxData("createTradeContract5TxId", createTradeContract5TxId);
printTxData("createSaleContract1TxId", createSaleContract1TxId);
printTxData("createSaleContract2TxId", createSaleContract2TxId);
printTxData("createSaleContract3TxId", createSaleContract3TxId);
printTxData("createGNTTradeContract1TxId", createGNTTradeContract1TxId);
console.log("RESULT: Expecting small change in eth.accounts[1]");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96812.6243);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertTokenBalance(eth.accounts[1], tokenB, 955);
assertEtherBalance(eth.accounts[2], 96620.8973);
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

// Creating new tokenTrader and tokenSeller - same owner accounts[1] and different owner accounts[2]
var startBlock = eth.getBlock("latest").number;
var sameOwnerTokenTrader = tokenTraderFactory
var createSameOwnerSameAssetTradeContractTxId = tokenTraderFactory.createTradeContract("$TOKENADDRESSA", 130000, 140000, 100000, true, true, {from: eth.accounts[1], gas: 1000000});
var createSameOwnerDiffAssetTradeContractTxId = tokenTraderFactory.createTradeContract("$TOKENADDRESSB", 150000, 160000, 100000, true, true, {from: eth.accounts[1], gas: 1000000});
var createDiffOwnerSameAssetTradeContractTxId = tokenTraderFactory.createTradeContract("$TOKENADDRESSA", 170000, 180000, 100000, true, true, {from: eth.accounts[2], gas: 1000000});
var createSameOwnerSameAssetSaleContractTxId = tokenSellerFactory.createSaleContract("$TOKENADDRESSA", 140000, 100000, true, {from: eth.accounts[1], gas: 1000000});
var createSameOwnerDiffAssetSaleContractTxId = tokenSellerFactory.createSaleContract("$TOKENADDRESSB", 160000, 100000, true, {from: eth.accounts[1], gas: 1000000});
var createDiffOwnerSameAssetSaleContractTxId = tokenSellerFactory.createSaleContract("$TOKENADDRESSA", 180000, 100000, true, {from: eth.accounts[2], gas: 1000000});
while (txpool.status.pending > 0) {
}
var endBlock = eth.getBlock("latest").number;
printTxData("createSameOwnerSameAssetTradeContractTxId", createSameOwnerSameAssetTradeContractTxId);
printTxData("createSameOwnerDiffAssetTradeContractTxId", createSameOwnerDiffAssetTradeContractTxId);
printTxData("createDiffOwnerSameAssetTradeContractTxId", createDiffOwnerSameAssetTradeContractTxId);
printTxData("createSameOwnerSameAssetSaleContractTxId", createSameOwnerSameAssetSaleContractTxId);
printTxData("createSameOwnerDiffAssetSaleContractTxId", createSameOwnerDiffAssetSaleContractTxId);
printTxData("createDiffOwnerSameAssetSaleContractTxId", createDiffOwnerSameAssetSaleContractTxId);

var sameOwnerSameAssetTradeContractAddress = null;
var sameOwnerDiffAssetTradeContractAddress = null;
var diffOwnerSameAssetTradeContractAddress = null;
// Get TokenTrader address
var tradeListingEvent = tokenTraderFactory.TradeListing({}, { fromBlock: startBlock, toBlock: endBlock });
var i = 0;
tradeListingEvent.watch(function (error, result) {
  var transactionHash = result.transactionHash;
  if (transactionHash === createSameOwnerSameAssetTradeContractTxId) {
    sameOwnerSameAssetTradeContractAddress = result.args.tokenTraderAddress;
    accounts.push(sameOwnerSameAssetTradeContractAddress);
    accountName[sameOwnerSameAssetTradeContractAddress] = "TokenTraderSOSA b1.3 s1.4";
    console.log("RESULT: sameOwnerSameAssetTradeContractAddress=" + sameOwnerSameAssetTradeContractAddress);
  } else if (transactionHash === createSameOwnerDiffAssetTradeContractTxId) {
    sameOwnerDiffAssetTradeContractAddress = result.args.tokenTraderAddress;
    accounts.push(sameOwnerDiffAssetTradeContractAddress);
    accountName[sameOwnerDiffAssetTradeContractAddress] = "TokenTraderSODA b1.5 s1.6";
    console.log("RESULT: sameOwnerDiffAssetTradeContractAddress=" + sameOwnerDiffAssetTradeContractAddress);
  } else if (transactionHash === createDiffOwnerSameAssetTradeContractTxId) {
    diffOwnerSameAssetTradeContractAddress = result.args.tokenTraderAddress;
    accounts.push(diffOwnerSameAssetTradeContractAddress);
    accountName[diffOwnerSameAssetTradeContractAddress] = "TokenTraderDOSA b1.7 s1.8";
    console.log("RESULT: diffOwnerSameAssetTradeContractAddress=" + diffOwnerSameAssetTradeContractAddress);
  }
  console.log(i++ + ": " + JSON.stringify(result));
});
tradeListingEvent.stopWatching();

var sameOwnerSameAssetSaleContractAddress = null;
var sameOwnerDiffAssetSaleContractAddress = null;
var diffOwnerSameAssetSaleContractAddress = null;
// Get TokenSeller address
tradeListingEvent = tokenSellerFactory.TradeListing({}, { fromBlock: startBlock, toBlock: endBlock });
i = 0;
tradeListingEvent.watch(function (error, result) {
  var transactionHash = result.transactionHash;
  if (transactionHash === createSameOwnerSameAssetSaleContractTxId) {
    sameOwnerSameAssetSaleContractAddress = result.args.tokenSellerAddress;
    accounts.push(sameOwnerSameAssetSaleContractAddress);
    accountName[sameOwnerSameAssetSaleContractAddress] = "TokenSellerSOSA s1.4";
    console.log("RESULT: sameOwnerSameAssetSaleContractAddress=" + sameOwnerSameAssetSaleContractAddress);
  } else if (transactionHash === createSameOwnerDiffAssetSaleContractTxId) {
    sameOwnerDiffAssetSaleContractAddress = result.args.tokenSellerAddress;
    accounts.push(sameOwnerDiffAssetSaleContractAddress);
    accountName[sameOwnerDiffAssetSaleContractAddress] = "TokenSellerSODA s1.6";
    console.log("RESULT: sameOwnerDiffAssetSaleContractAddress=" + sameOwnerDiffAssetSaleContractAddress);
  } else if (transactionHash === createDiffOwnerSameAssetSaleContractTxId) {
    diffOwnerSameAssetSaleContractAddress = result.args.tokenSellerAddress;
    accounts.push(diffOwnerSameAssetSaleContractAddress);
    accountName[diffOwnerSameAssetSaleContractAddress] = "TokenSellerDOSA s1.8";
    console.log("RESULT: sameOwnerDiffAssetSaleContractAddress=" + sameOwnerDiffAssetSaleContractAddress);
  }
  console.log(i++ + ": " + JSON.stringify(result));
});
tradeListingEvent.stopWatching();

console.log("RESULT: Expecting small change in eth.accounts[1] and eth.accounts[2] and different Trader / Seller accounts created");
printBalances(accounts);

startBlock = eth.getBlock("latest").number;
var tokenTraderTransferAssetSOSATxId = tokenTrader.makerTransferAsset(sameOwnerSameAssetTradeContractAddress, 1e17, {from: eth.accounts[1], gas: 300000});
var tokenTraderTransferEtherSOSATxId = tokenTrader.makerTransferEther(sameOwnerSameAssetTradeContractAddress, 2e17, {from: eth.accounts[1], gas: 300000});
var tokenTraderTransferAssetSODATxId = tokenTrader.makerTransferAsset(sameOwnerDiffAssetTradeContractAddress, 3e17, {from: eth.accounts[1], gas: 300000});
var tokenTraderTransferEtherSODATxId = tokenTrader.makerTransferEther(sameOwnerDiffAssetTradeContractAddress, 4e17, {from: eth.accounts[1], gas: 300000});
var tokenTraderTransferAssetDOSATxId = tokenTrader.makerTransferAsset(diffOwnerSameAssetTradeContractAddress, 5e17, {from: eth.accounts[1], gas: 300000});
var tokenTraderTransferEtherDOSATxId = tokenTrader.makerTransferEther(diffOwnerSameAssetTradeContractAddress, 6e17, {from: eth.accounts[1], gas: 300000});
var tokenTraderTransferAssetERC20xId = tokenTrader.makerTransferAsset(tokenA.address, 7e17, {from: eth.accounts[1], gas: 300000});
var tokenTraderTransferEtherERC20TxId = tokenTrader.makerTransferEther(tokenA.address, 8e17, {from: eth.accounts[1], gas: 300000});
var tokenTraderTransferAssetFactoryxId = tokenTrader.makerTransferAsset(tokenTraderFactory.address, 9e17, {from: eth.accounts[1], gas: 300000});
var tokenTraderTransferEtherFactoryTxId = tokenTrader.makerTransferEther(tokenTraderFactory.address, 10e17, {from: eth.accounts[1], gas: 300000});

var tokenTraderNonOwnerDepositEtherTxId = tokenTrader.makerDepositEther(2e18, {from: eth.accounts[2], gas: 300000});

var tokenSellerTransferAssetSOSATxId = tokenSeller.makerTransferAsset(sameOwnerSameAssetSaleContractAddress, 1e17, {from: eth.accounts[1], gas: 300000});
var tokenSellerTransferAssetSODATxId = tokenSeller.makerTransferAsset(sameOwnerDiffAssetSaleContractAddress, 3e17, {from: eth.accounts[1], gas: 300000});
var tokenSellerTransferAssetDOSATxId = tokenSeller.makerTransferAsset(diffOwnerSameAssetSaleContractAddress, 5e17, {from: eth.accounts[1], gas: 300000});
var tokenSellerTransferERC20TxId = tokenSeller.makerTransferAsset(tokenA.address, 7e17, {from: eth.accounts[1], gas: 300000});
var tokenSellerTransferFactoryTxId = tokenSeller.makerTransferAsset(tokenTraderFactory.address, 8e17, {from: eth.accounts[1], gas: 300000});

while (txpool.status.pending > 0) {
}
endBlock = eth.getBlock("latest").number;
printTxData("tokenTraderTransferAssetSOSATxId", tokenTraderTransferAssetSOSATxId);
printTxData("tokenTraderTransferEtherSOSATxId", tokenTraderTransferEtherSOSATxId);
printTxData("tokenTraderTransferAssetSODATxId", tokenTraderTransferAssetSODATxId);
printTxData("tokenTraderTransferEtherSODATxId", tokenTraderTransferEtherSODATxId);
printTxData("tokenTraderTransferAssetDOSATxId", tokenTraderTransferAssetDOSATxId);
printTxData("tokenTraderTransferEtherDOSATxId", tokenTraderTransferEtherDOSATxId);
printTxData("tokenTraderTransferAssetERC20xId", tokenTraderTransferAssetERC20xId);
printTxData("tokenTraderTransferEtherERC20TxId", tokenTraderTransferEtherERC20TxId);
printTxData("tokenTraderTransferAssetFactoryxId", tokenTraderTransferAssetFactoryxId);
printTxData("tokenTraderTransferEtherFactoryTxId", tokenTraderTransferEtherFactoryTxId);

printTxData("tokenTraderNonOwnerDepositEtherTxId", tokenTraderNonOwnerDepositEtherTxId);

printTxData("tokenSellerTransferAssetSOSATxId", tokenSellerTransferAssetSOSATxId);
printTxData("tokenSellerTransferAssetSODATxId", tokenSellerTransferAssetSODATxId);
printTxData("tokenSellerTransferAssetDOSATxId", tokenSellerTransferAssetDOSATxId);
printTxData("tokenSellerTransferERC20TxId", tokenSellerTransferERC20TxId);
printTxData("tokenSellerTransferFactoryTxId", tokenSellerTransferFactoryTxId);
console.log("RESULT: Expecting some to succeed and most to fail gas==gasUsed ");
printBalances(accounts);

var makerTransferredAssetEvent = tokenTrader.MakerTransferredAsset({}, { fromBlock: startBlock, toBlock: endBlock });
i = 0;
makerTransferredAssetEvent.watch(function (error, result) {
  console.log("RESULT: TokenTrader.MakerTransferredAsset " + i++ + " " + JSON.stringify(result));
});
makerTransferredAssetEvent.stopWatching();
var makerTransferredEtherEvent = tokenTrader.MakerTransferredEther({}, { fromBlock: startBlock, toBlock: endBlock });
i = 0;
makerTransferredEtherEvent.watch(function (error, result) {
  console.log("RESULT: TokenTrader.MakerTransferredEther " + i++ + " " + JSON.stringify(result));
});
makerTransferredEtherEvent.stopWatching();
var tokenTraderSOSA = web3.eth.contract(tokenTraderABI).at(sameOwnerSameAssetTradeContractAddress);
var makerDepositedEtherEvent = tokenTraderSOSA.MakerDepositedEther({}, { fromBlock: startBlock, toBlock: endBlock });
i = 0;
makerDepositedEtherEvent.watch(function (error, result) {
  console.log("RESULT: TokenTrader.MakerDepositedEther " + i++ + " " + JSON.stringify(result));
});
makerDepositedEtherEvent.stopWatching();
makerTransferredAssetEvent = tokenSeller.MakerTransferredAsset({}, { fromBlock: startBlock, toBlock: endBlock });
i = 0;
makerTransferredAssetEvent.watch(function (error, result) {
  console.log("RESULT: TokenSeller.MakerTransferredAsset " + i++ + " " + JSON.stringify(result));
});
makerTransferredAssetEvent.stopWatching();
assertEtherBalance(eth.accounts[1], 96812.4818);
assertTokenBalance(eth.accounts[1], tokenA, 686.0769);
assertTokenBalance(eth.accounts[1], tokenB, 955);
assertEtherBalance(eth.accounts[2], 96620.8665);
assertTokenBalance(eth.accounts[2], tokenA, 1300);
assertTokenBalance(tokenTraderFactory.address, tokenB, 9);
assertTokenBalance(tokenSellerFactory.address, tokenB, 9);
assertEtherBalance(tokenTrader.address, 257.8909);
assertTokenBalance(tokenTrader.address, tokenA, 3.9);
assertTokenBalance(tokenTrader.address, tokenB, 9);
assertEtherBalance(tokenSeller.address, 149);
assertTokenBalance(tokenSeller.address, tokenA, 3.9);
assertTokenBalance(tokenSeller.address, tokenB, 9);
assertEtherBalance(gntTokenTrader.address, 159);
assertTokenBalance(gntTokenTrader.address, tokenA, 5.9231);
assertTokenBalance(gntTokenTrader.address, tokenB, 9);

assertEtherBalance(sameOwnerSameAssetTradeContractAddress, 0.2);
assertTokenBalance(sameOwnerSameAssetTradeContractAddress, tokenA, 0.1);
assertEtherBalance(sameOwnerDiffAssetTradeContractAddress, 0);
assertTokenBalance(sameOwnerDiffAssetTradeContractAddress, tokenA, 0);
assertEtherBalance(diffOwnerSameAssetTradeContractAddress, 0);
assertTokenBalance(diffOwnerSameAssetTradeContractAddress, tokenA, 0);

assertEtherBalance(sameOwnerSameAssetSaleContractAddress, 0);
assertTokenBalance(sameOwnerSameAssetSaleContractAddress, tokenA, 0.1);
assertEtherBalance(sameOwnerDiffAssetSaleContractAddress, 0);
assertTokenBalance(sameOwnerDiffAssetSaleContractAddress, tokenA, 0);
assertEtherBalance(diffOwnerSameAssetSaleContractAddress, 0);
assertTokenBalance(diffOwnerSameAssetSaleContractAddress, tokenA, 0);

exit;

EOF

grep "RESULT: " $OTHEROUTPUTFILE | sed "s/RESULT: //" > $OTHERRESULTFILE
cat $OTHERRESULTFILE
