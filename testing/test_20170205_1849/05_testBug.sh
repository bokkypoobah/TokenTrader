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
BUGOUTPUTFILE=`grep BUGOUTPUTFILE settings.txt | sed "s/^.*=//"`
BUGRESULTFILE=`grep BUGRESULTFILE settings.txt | sed "s/^.*=//"`

TOKENDATAFILE=`grep TOKENDATA settings.txt | sed "s/^.*=//"`
printf "TOKENDATAFILE $TOKENDATAFILE\n"
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

printf "Connecting to geth on endpoint '$GETHATTACHPOINT'\n" | tee $BUGOUTPUTFILE
printf "TokenA address '$TOKENADDRESSA'\n" | tee -a $BUGOUTPUTFILE
printf "TokenB address '$TOKENADDRESSB'\n" | tee -a $BUGOUTPUTFILE
printf "TokenC address '$TOKENADDRESSC'\n" | tee -a $BUGOUTPUTFILE
printf "Token ABI '$TOKENABI'\n" | tee -a $BUGOUTPUTFILE
printf "TokenTraderFactory address '$TOKENTRADERFACTORYADDRESS'\n" | tee -a $BUGOUTPUTFILE
printf "TokenTraderFactory ABI '$TOKENTRADERFACTORYABI'\n" | tee -a $BUGOUTPUTFILE
printf "TokenTrader address '$TOKENTRADERADDRESS'\n" | tee -a $BUGOUTPUTFILE
printf "TokenTrader ABI '$TOKENTRADERABI'\n" | tee -a $BUGOUTPUTFILE
printf "var tokenTraderABI = $TOKENTRADERABI;\n" > $TEMPINFILE
printf "TokenSellerFactory address '$TOKENSELLERFACTORYADDRESS'\n" | tee -a $BUGOUTPUTFILE
printf "TokenSellerFactory ABI '$TOKENSELLERFACTORYABI'\n" | tee -a $BUGOUTPUTFILE
printf "TokenSeller address '$TOKENSELLERADDRESS'\n" | tee -a $BUGOUTPUTFILE
printf "TokenSeller ABI '$TOKENSELLERABI'\n" | tee -a $BUGOUTPUTFILE
printf "var tokenSellerABI = $TOKENSELLERABI;\n" >> $TEMPINFILE
printf "GNTTokenTraderFactory address '$GNTTOKENTRADERFACTORYADDRESS'\n" | tee -a $BUGOUTPUTFILE
printf "GNTTokenTraderFactory ABI '$GNTTOKENTRADERFACTORYABI'\n" | tee -a $BUGOUTPUTFILE
printf "GNTTokenTrader address '$GNTTOKENTRADERADDRESS'\n" | tee -a $BUGOUTPUTFILE
printf "GNTTokenTrader ABI '$GNTTOKENTRADERABI'\n" | tee -a $BUGOUTPUTFILE

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $BUGOUTPUTFILE

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
assertEtherBalance(eth.accounts[1], 96812.4819);
assertTokenBalance(eth.accounts[1], tokenC, 1000);
assertEtherBalance(eth.accounts[2], 96620.8574);
assertTokenBalance(eth.accounts[2], tokenC, 1000);
for (var i = 0; i < ACCOUNTS; i++) {
  personal.unlockAccount(eth.accounts[i], "$PASSWORD", 100000);
}

console.log("RESULT: Testing bug in change calculation");
var startBlock = eth.getBlock("latest").number;
var createTradeContract1TxId = tokenTraderFactory.createTradeContract("$TOKENADDRESSC", 18e17, 19e17, 1, true, true, {from: eth.accounts[1], gas: 1000000});
var createSaleContract1TxId = tokenSellerFactory.createSaleContract("$TOKENADDRESSC", 19e17, 1, true, {from: eth.accounts[1], gas: 1000000});
while (txpool.status.pending > 0) {
}
// Get contract addresses
var endBlock = eth.getBlock("latest").number;
printTxData("createTradeContract1TxId", createTradeContract1TxId);
printTxData("createSaleContract1TxId", createSaleContract1TxId);

var tradeContract1Address = null;
var saleContract1Address = null;

// Get TokenTrader address
var tradeListingEvent = tokenTraderFactory.TradeListing({}, { fromBlock: startBlock, toBlock: endBlock });
var i = 0;
tradeListingEvent.watch(function (error, result) {
  var transactionHash = result.transactionHash;
  if (transactionHash === createTradeContract1TxId) {
    tradeContract1Address = result.args.tokenTraderAddress;
    accounts.push(tradeContract1Address);
    accountName[tradeContract1Address] = "TokenCTrader";
    console.log("RESULT: tradeContract1Address=" + tradeContract1Address);
  }
  console.log(i++ + ": " + JSON.stringify(result));
});
tradeListingEvent.stopWatching();

// Get TokenSeller address
var saleListingEvent = tokenSellerFactory.TradeListing({}, { fromBlock: startBlock, toBlock: endBlock });
var i = 0;
saleListingEvent.watch(function (error, result) {
  var transactionHash = result.transactionHash;
  if (transactionHash === createSaleContract1TxId) {
    saleContract1Address = result.args.tokenSellerAddress;
    accounts.push(saleContract1Address);
    accountName[saleContract1Address] = "TokenCSeller";
    console.log("RESULT: saleContract1Address=" + saleContract1Address);
  }
  console.log(i++ + ": " + JSON.stringify(result));
});
saleListingEvent.stopWatching();

console.log("RESULT: Expecting small change in eth.accounts[1]");
printBalances(accounts);

console.log("RESULT: Maker transferring 1 tokenC to tokenTrader and tokenSeller");
var traderTransferTokenTxId = tokenC.transfer(tradeContract1Address, 1, {from: eth.accounts[1], gas: 100000});
var sellerTransferTokenTxId = tokenC.transfer(saleContract1Address, 1, {from: eth.accounts[1], gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("traderTransferTokenTxId", traderTransferTokenTxId);
printTxData("sellerTransferTokenTxId", sellerTransferTokenTxId);
console.log("RESULT: Expecting change in eth.accounts[1] tokens plus 1 tokens in TokenTrader and TokenSeller");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96812.4460);
assertTokenBalance(eth.accounts[1], tokenC, 999.9999); // no resolution but should be 999.999999999999999998
assertEtherBalance(eth.accounts[2], 96620.8574);
assertTokenBalance(eth.accounts[2], tokenC, 1000);
assertEtherBalance(tradeContract1Address, 0);
assertTokenBalance(tradeContract1Address, tokenC, 0); // No resolution but should be 0.000000000000000001
assertEtherBalance(saleContract1Address, 0);
assertTokenBalance(saleContract1Address, tokenC, 0); // No resolution but should be 0.000000000000000001

var tokenTraderBuyTokenTxId = eth.sendTransaction({from: eth.accounts[2], to: tradeContract1Address, value: web3.toWei(2, "ether"), gas: 100000});
var tokenSellerBuyTokenTxId = eth.sendTransaction({from: eth.accounts[2], to: saleContract1Address, value: web3.toWei(2, "ether"), gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tokenTraderBuyTokenTxId", tokenTraderBuyTokenTxId);
printTxData("tokenSellerBuyTokenTxId", tokenSellerBuyTokenTxId);

console.log("RESULT: Expecting change in eth.accounts[2] plus decrease in TokenTrader and TokenSeller balances. Change should be received and checked");
printBalances(accounts);
assertEtherBalance(eth.accounts[1], 96812.4460);
assertTokenBalance(eth.accounts[1], tokenC, 999.9999); // no resolution but should be 999.999999999999999998
assertEtherBalance(eth.accounts[2], 96617.0562);
assertTokenBalance(eth.accounts[2], tokenC, 1000); // no resolution but should be 1000.000000000000000002
assertEtherBalance(tradeContract1Address, 1.9);
assertTokenBalance(tradeContract1Address, tokenC, 0); // No resolution but should be 0
assertEtherBalance(saleContract1Address, 1.9);
assertTokenBalance(saleContract1Address, tokenC, 0); // No resolution but should be 0

exit;

EOF

grep "RESULT: " $BUGOUTPUTFILE | sed "s/RESULT: //" > $BUGRESULTFILE
cat $BUGRESULTFILE
