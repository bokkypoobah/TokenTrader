#!/bin/bash
# --------------------------------------------------------------------
# Testing Contracts At https://github.com/bokkypoobah/TokenTrader
# for https://cryptoderivatives.market/
#
# Deploy TokenTraderFactory and TokenSellerFactory
#
# (c) BokkyPooBah 2017. The MIT licence.
# --------------------------------------------------------------------

GETHATTACHPOINT=`grep IPCFILE settings.txt | sed "s/^.*=//"`
PASSWORD=`grep PASSWORD settings.txt | sed "s/^.*=//"`

TEMPINFILE=`grep TEMPINFILE settings.txt | sed "s/^.*=//"`
FACTORYOUTPUTFILE=`grep FACTORYOUTPUTFILE settings.txt | sed "s/^.*=//"`

TOKENTRADERFACTORYSOL=`grep ^TOKENTRADERFACTORYSOL settings.txt | sed "s/^.*=//"`
TOKENSELLERFACTORYSOL=`grep TOKENSELLERFACTORYSOL settings.txt | sed "s/^.*=//"`
GNTTOKENTRADERFACTORYSOL=`grep GNTTOKENTRADERFACTORYSOL settings.txt | sed "s/^.*=//"`
TRADERFLATTENEDSOL=`./stripCrLf $TOKENTRADERFACTORYSOL | tr -s ' '`
SELLERFLATTENEDSOL=`./stripCrLf $TOKENSELLERFACTORYSOL | tr -s ' '`
GNTTRADERFLATTENEDSOL=`./stripCrLf $GNTTOKENTRADERFACTORYSOL | tr -s ' '`

printf "var traderSource = \"$TRADERFLATTENEDSOL\"\n" > $TEMPINFILE
printf "var sellerSource = \"$SELLERFLATTENEDSOL\"\n" >> $TEMPINFILE
printf "var gntTraderSource = \"$GNTTRADERFLATTENEDSOL\";\n" >> $TEMPINFILE

TOKENDATAFILE=`grep TOKENDATA settings.txt | sed "s/^.*=//"`
TOKENADDRESSA=`grep tokenAddressA $TOKENDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENADDRESSB=`grep tokenAddressB $TOKENDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENADDRESSC=`grep tokenAddressC $TOKENDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENABI=`grep tokenABI $TOKENDATAFILE  | tail -n 1 | sed "s/^.*=//"`

FACTORYDATAFILE=`grep FACTORYDATA settings.txt | sed "s/^.*=//"`
FACTORYRESULTFILE=`grep FACTORYRESULTFILE settings.txt | sed "s/^.*=//"`

printf "geth endpoint '$GETHATTACHPOINT'\n" | tee $FACTORYOUTPUTFILE
printf "TokenA contract address '$TOKENADDRESSA'\n" | tee -a $FACTORYOUTPUTFILE
printf "TokenB contract address '$TOKENADDRESSB'\n" | tee -a $FACTORYOUTPUTFILE
printf "TokenC contract address '$TOKENADDRESSC'\n" | tee -a $FACTORYOUTPUTFILE

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $FACTORYOUTPUTFILE

var tokenA = web3.eth.contract($TOKENABI).at("$TOKENADDRESSA");
var tokenB = web3.eth.contract($TOKENABI).at("$TOKENADDRESSB");
var tokenC = web3.eth.contract($TOKENABI).at("$TOKENADDRESSC");

var ACCOUNTS = 3;
var EPSILON = 0.01;

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

var accountName = {};
accountName[eth.accounts[0]] = "Account #0";
accountName[eth.accounts[1]] = "Account #1";
accountName[eth.accounts[2]] = "Account #2";
accountName[tokenA.address] = "ERC20A";
accountName[tokenB.address] = "ERC20B";
accountName[tokenC.address] = "ERC20C";

function printBalances(accounts) {
  var i = 0;
  console.log("RESULT: # Account                                                   EtherBalance               TokenABalance               TokenBBalance               TokenCBalance Name");
  accounts.forEach(function(e) {
    var etherBalance = web3.fromWei(eth.getBalance(e), "ether");
    var tokenABalance = web3.fromWei(tokenA.balanceOf(e), "ether");
    var tokenBBalance = web3.fromWei(tokenB.balanceOf(e), "ether");
    var tokenCBalance = web3.fromWei(tokenC.balanceOf(e), "ether");
    console.log("RESULT: " + i + " " + e  + " " + pad(etherBalance) + " " + pad(tokenABalance) + " " + pad(tokenBBalance) + " " +
      pad(tokenCBalance) + " " + accountName[e]);
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

for (var i = 0; i < ACCOUNTS; i++) {
  personal.unlockAccount(eth.accounts[i], "$PASSWORD", 100000);
}

loadScript("$TEMPINFILE");

// console.log(traderSource);
// console.log(sellerSource);
// console.log(gntTraderSource);

// TokenTraderFactory
var traderCompiled = web3.eth.compile.solidity(traderSource);
console.log("DATA: erc20ABI=" + JSON.stringify(traderCompiled["<stdin>:ERC20"].info.abiDefinition));
console.log("DATA: tokenTraderABI=" + JSON.stringify(traderCompiled["<stdin>:TokenTrader"].info.abiDefinition));
console.log("DATA: tokenTraderFactoryABI=" + JSON.stringify(traderCompiled["<stdin>:TokenTraderFactory"].info.abiDefinition));
var traderFactoryContract = web3.eth.contract(traderCompiled["<stdin>:TokenTraderFactory"].info.abiDefinition);
var traderFactoryTxId = null;
var traderFactoryAddress = null;
var traderFactory = traderFactoryContract.new({from: eth.accounts[1], data: traderCompiled["<stdin>:TokenTraderFactory"].code, gas: 3000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        traderFactoryTxId = contract.transactionHash;
        console.log("traderFactoryTxId=" + traderFactoryTxId);
      } else {
        traderFactoryAddress = contract.address;
        accountName[traderFactoryAddress] = "TokenTraderFactory";
        console.log("DATA: tokenTraderFactoryAddress=" + traderFactoryAddress);
        printTxData("traderFactoryAddress=" + traderFactoryAddress, traderFactoryTxId);
      }
    }
  }
);

// TokenSellerFactory
var sellerCompiled = web3.eth.compile.solidity(sellerSource);
console.log("DATA: erc20PartialABI=" + JSON.stringify(sellerCompiled["<stdin>:ERC20Partial"].info.abiDefinition));
console.log("DATA: tokenSellerABI=" + JSON.stringify(sellerCompiled["<stdin>:TokenSeller"].info.abiDefinition));
console.log("DATA: tokenSellerFactoryABI=" + JSON.stringify(sellerCompiled["<stdin>:TokenSellerFactory"].info.abiDefinition));
var sellerFactoryContract = web3.eth.contract(sellerCompiled["<stdin>:TokenSellerFactory"].info.abiDefinition);
var sellerFactoryTxId = null;
var sellerFactoryAddress = null;
var sellerFactory = sellerFactoryContract.new({from: eth.accounts[1], data: sellerCompiled["<stdin>:TokenSellerFactory"].code, gas: 3000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        sellerFactoryTxId = contract.transactionHash;
        console.log("sellerFactoryTxId=" + sellerFactoryTxId);
      } else {
        sellerFactoryAddress = contract.address;
        accountName[sellerFactoryAddress] = "TokenSellerFactory";
        console.log("DATA: tokenSellerFactoryAddress=" + sellerFactoryAddress);
        printTxData("sellerFactoryAddress=" + sellerFactoryAddress, sellerFactoryTxId);
      }
    }
  }
);

// GNTTokenTraderFactory
var gntTraderCompiled = web3.eth.compile.solidity(gntTraderSource);
console.log("DATA: gntTokenTraderABI=" + JSON.stringify(gntTraderCompiled["<stdin>:TokenTrader"].info.abiDefinition));
console.log("DATA: gntTokenTraderFactoryABI=" + JSON.stringify(gntTraderCompiled["<stdin>:TokenTraderFactory"].info.abiDefinition));
var gntTraderFactoryContract = web3.eth.contract(gntTraderCompiled["<stdin>:TokenTraderFactory"].info.abiDefinition);
var gntTraderFactoryTxId = null;
var gntTraderFactoryAddress = null;
var gntTraderFactory = gntTraderFactoryContract.new({from: eth.accounts[1], data: gntTraderCompiled["<stdin>:TokenTraderFactory"].code, gas: 3000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        gntTraderFactoryTxId = contract.transactionHash;
        console.log("gntTraderFactoryTxId=" + gntTraderFactoryTxId);
      } else {
        gntTraderFactoryAddress = contract.address;
        accountName[gntTraderFactoryAddress] = "GNTTokenTraderFactory";
        console.log("DATA: gntTokenTraderFactoryAddress=" + gntTraderFactoryAddress);
        printTxData("gntTraderFactoryAddress=" + gntTraderFactoryAddress, gntTraderFactoryTxId);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

var startBlock = eth.getBlock("latest").number;
var createTradeContractTxId = traderFactory.createTradeContract("$TOKENADDRESSA", 110000, 120000, 100000, true, true, {from: eth.accounts[1], gas: 1000000});
var createSaleContractTxId = sellerFactory.createSaleContract("$TOKENADDRESSA", 120000, 100000, true, {from: eth.accounts[1], gas: 1000000});
var createGNTTradeContractTxId = gntTraderFactory.createTradeContract("$TOKENADDRESSA", 130000, 100000, true, {from: eth.accounts[1], gas: 1000000});
while (txpool.status.pending > 0) {
}
printTxData("createTradeContractTxId", createTradeContractTxId);
printTxData("createSaleContractTxId", createSaleContractTxId);
printTxData("createGNTTradeContractTxId", createGNTTradeContractTxId);
var endBlock = eth.getBlock("latest").number;

// Get TokenTrader address
var tradeListingEvent = traderFactory.TradeListing({}, { fromBlock: startBlock, toBlock: endBlock });
var i = 0;
var tokenTraderAddress = null;
tradeListingEvent.watch(function (error, result) {
  var tokenTraderFactoryAddress = result.address;
  tokenTraderAddress = result.args.tokenTraderAddress;
  accountName[tokenTraderAddress] = "TokenTrader";
  var owner = result.args.ownerAddress;
  var blockNumber = result.blockNumber;
  var logIndex = result.logIndex;
  var transactionHash = result.transactionHash;
  console.log("DATA: tokenTraderAddress=" + tokenTraderAddress);
  console.log("DATA: tokenTraderOwner=" + owner);
  console.log(i++ + ": " + JSON.stringify(result));
});
tradeListingEvent.stopWatching();

// Get TokenSeller address
var tradeListingEvent = sellerFactory.TradeListing({}, { fromBlock: startBlock, toBlock: endBlock });
var i = 0;
var tokenSellerAddress = null;
tradeListingEvent.watch(function (error, result) {
  var tokenSellerFactoryAddress = result.address;
  tokenSellerAddress = result.args.tokenSellerAddress;
  accountName[tokenSellerAddress] = "TokenSeller";
  var owner = result.args.ownerAddress;
  var blockNumber = result.blockNumber;
  var logIndex = result.logIndex;
  var transactionHash = result.transactionHash;
  console.log("DATA: tokenSellerAddress=" + tokenSellerAddress);
  console.log("DATA: tokenSellerOwner=" + owner);
  console.log(i++ + ": " + JSON.stringify(result));
});
tradeListingEvent.stopWatching();

// Get GNTTokenTrader address
var gntTradeListingEvent = gntTraderFactory.TradeListing({}, { fromBlock: startBlock, toBlock: endBlock });
var i = 0;
var gntTokenTraderAddress = null;
gntTradeListingEvent.watch(function (error, result) {
  var gntTokenTraderFactoryAddress = result.address;
  gntTokenTraderAddress = result.args.addr;
  accountName[gntTokenTraderAddress] = "GNTTokenTrader";
  var owner = result.args.owner;
  var blockNumber = result.blockNumber;
  var logIndex = result.logIndex;
  var transactionHash = result.transactionHash;
  console.log("DATA: gntTokenTraderAddress=" + gntTokenTraderAddress);
  console.log("DATA: gntTokenTraderOwner=" + owner);
  console.log(i++ + ": " + JSON.stringify(result));
});
gntTradeListingEvent.stopWatching();

var traderVerifyResults = traderFactory.verify(tokenTraderAddress);
console.log("RESULT: traderVerifyResults " + JSON.stringify(traderVerifyResults));
var sellerVerifyResults = sellerFactory.verify(tokenSellerAddress);
console.log("RESULT: sellerVerifyResults " + JSON.stringify(sellerVerifyResults));
var gntTraderVerifyResults = gntTraderFactory.verify(gntTokenTraderAddress);
console.log("RESULT: gntTraderVerifyResults " + JSON.stringify(gntTraderVerifyResults));

printBalances([eth.accounts[0], eth.accounts[1], eth.accounts[2], "$TOKENADDRESSA", "$TOKENADDRESSB", "$TOKENADDRESSC",
  traderFactoryAddress, sellerFactoryAddress, gntTraderFactoryAddress, tokenTraderAddress, tokenSellerAddress, gntTokenTraderAddress]);

// Deposit ETH to new Trader contract
console.log("RESULT: Depositing 100 ETH to tokenTrader " + tokenTraderAddress);
var tokenTrader = web3.eth.contract(traderCompiled["<stdin>:TokenTrader"].info.abiDefinition).at(tokenTraderAddress);
var traderDepositEtherTxId = tokenTrader.makerDepositEther({from: eth.accounts[1], value: 100e18, gas: 100000});

// Transfer tokens to new Trader contract
console.log("RESULT: Transferring 100 tokenAs to tokenTrader " + tokenTraderAddress);
var traderTransferTokenTxId = tokenA.transfer(tokenTraderAddress, 100e18, {from: eth.accounts[1], gas: 100000});

// Transfer tokens to new Seller contract
console.log("RESULT: Transferring 100 tokenAs to tokenSeller " + tokenSellerAddress);
var sellerTransferTokenTxId = tokenA.transfer(tokenSellerAddress, 100e18, {from: eth.accounts[1], gas: 100000});

// Transfer tokens to new GNTTrader contract
console.log("RESULT: Transferring 100 tokenAs to gntTokenTrader " + gntTokenTraderAddress);
var gntTraderTransferTokenTxId = tokenA.transfer(gntTokenTraderAddress, 100e18, {from: eth.accounts[1], gas: 100000});

while (txpool.status.pending > 0) {
}

printTxData("traderDepositEtherTxId", traderDepositEtherTxId);
printTxData("traderTransferTokenTxId", traderTransferTokenTxId);
printTxData("sellerTransferTokenTxId", sellerTransferTokenTxId);
printTxData("gntTraderTransferTokenTxId", gntTraderTransferTokenTxId);

assertEtherBalance("$TOKENADDRESSA", 3000);

console.log("RESULT: Expecting 100 TokenABalance and 100 ETH in tokenTrader " + tokenTraderAddress);
console.log("RESULT: Expecting 100 TokenABalance in tokenSeller " + tokenSellerAddress);
console.log("RESULT: Expecting 100 TokenABalance in gntTokenTrader " + gntTokenTraderAddress);
printBalances([eth.accounts[0], eth.accounts[1], eth.accounts[2], "$TOKENADDRESSA", "$TOKENADDRESSB", "$TOKENADDRESSC",
  traderFactoryAddress, sellerFactoryAddress, gntTraderFactoryAddress, tokenTraderAddress, tokenSellerAddress, gntTokenTraderAddress]);

assertEtherBalance(traderFactoryAddress, 0);
assertTokenBalance(traderFactoryAddress, tokenA, 0);
assertEtherBalance(sellerFactoryAddress, 0);
assertTokenBalance(sellerFactoryAddress, tokenA, 0);
assertEtherBalance(gntTraderFactoryAddress, 0);
assertTokenBalance(gntTraderFactoryAddress, tokenA, 0);
assertEtherBalance(tokenTraderAddress, 100);
assertTokenBalance(tokenTraderAddress, tokenA, 100);
assertEtherBalance(tokenSellerAddress, 0);
assertTokenBalance(tokenSellerAddress, tokenA, 100);
assertEtherBalance(gntTokenTraderAddress, 0);
assertTokenBalance(gntTokenTraderAddress, tokenA, 100);


EOF

grep "DATA: " $FACTORYOUTPUTFILE | sed "s/DATA: //" > $FACTORYDATAFILE
grep "RESULT: " $FACTORYOUTPUTFILE | sed "s/RESULT: //" > $FACTORYRESULTFILE
cat $FACTORYRESULTFILE
