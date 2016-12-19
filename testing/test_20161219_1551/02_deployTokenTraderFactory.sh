#!/bin/bash
# --------------------------------------------------------------------
# Deploy TokenTraderFactory and TokenSellerFactory
#
# (c) BokkyPooBah 2016. The MIT licence.
# --------------------------------------------------------------------

GETHATTACHPOINT=`grep IPCFILE settings.txt | sed "s/^.*=//"`
PASSWORD=`grep PASSWORD settings.txt | sed "s/^.*=//"`

TEMPINFILE=`grep TEMPINFILE settings.txt | sed "s/^.*=//"`
TEMPOUTFILE=`grep TEMPOUTFILE settings.txt | sed "s/^.*=//"`

TOKENTRADERFACTORYSOL=`grep TOKENTRADERFACTORYSOL settings.txt | sed "s/^.*=//"`
TOKENSELLERFACTORYSOL=`grep TOKENSELLERFACTORYSOL settings.txt | sed "s/^.*=//"`
TRADERFLATTENEDSOL=`./stripCrLf $TOKENTRADERFACTORYSOL | tr -s ' '`
SELLERFLATTENEDSOL=`./stripCrLf $TOKENSELLERFACTORYSOL | tr -s ' '`
printf "var traderSource = \"$TRADERFLATTENEDSOL\";" > $TEMPINFILE
printf "var sellerSource = \"$SELLERFLATTENEDSOL\";" >> $TEMPINFILE

TOKENDATAFILE=`grep TOKENDATA settings.txt | sed "s/^.*=//"`
TOKENADDRESS=`grep tokenAddress $TOKENDATAFILE  | tail -n 1 | sed "s/^.*=//"`
TOKENABI=`grep tokenABI $TOKENDATAFILE  | tail -n 1 | sed "s/^.*=//"`

FACTORYDATAFILE=`grep FACTORYDATA settings.txt | sed "s/^.*=//"`
FACTORYRESULTFILE=`grep FACTORYRESULTFILE settings.txt | sed "s/^.*=//"`

printf "geth endpoint '$GETHATTACHPOINT'\n" | tee $TEMPOUTFILE
printf "Token contract address '$TOKENADDRESS'\n" | tee -a $TEMPOUTFILE

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEMPOUTFILE

var token = web3.eth.contract($TOKENABI).at("$TOKENADDRESS");

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

// call printBalances([eth.accounts[0], eth.accounts[1], "aaaa...", "bbb..."])
function printBalances(accounts) {
  var i = 0;
  console.log("RESULT: # Account                                                   EtherBalance                TokenBalance");
  accounts.forEach(function(e) {
    var etherBalance = web3.fromWei(eth.getBalance(e), "ether");
    var tokenBalance = web3.fromWei(token.balanceOf(e), "ether");
    console.log("RESULT: " + i + " " + e  + " " + pad(etherBalance) + " " + pad(tokenBalance));
    i++;
  });
}

function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed);
}

personal.unlockAccount(eth.accounts[0], "$PASSWORD", 100000);
personal.unlockAccount(eth.accounts[1], "$PASSWORD", 100000);

loadScript("$TEMPINFILE");

// console.log(traderSource);
// console.log(sellerSource);

// TokenTraderFactory
var traderCompiled = web3.eth.compile.solidity(traderSource);
console.log("DATA: erc20ABI=" + JSON.stringify(traderCompiled.ERC20.info.abiDefinition));
console.log("DATA: tokenTraderABI=" + JSON.stringify(traderCompiled.TokenTrader.info.abiDefinition));
console.log("DATA: tokenTraderFactoryABI=" + JSON.stringify(traderCompiled.TokenTraderFactory.info.abiDefinition));
var traderFactoryContract = web3.eth.contract(traderCompiled.TokenTraderFactory.info.abiDefinition);
var traderFactoryTxId = null;
var traderFactoryAddress = null;
var traderFactory = traderFactoryContract.new({from: eth.accounts[0], data: traderCompiled.TokenTraderFactory.code, gas: 3000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        traderFactoryTxId = contract.transactionHash;
        console.log("traderFactoryTxId=" + traderFactoryTxId);
      } else {
        traderFactoryAddress = contract.address;
        console.log("DATA: tokenTraderFactoryAddress=" + traderFactoryAddress);
        printTxData("traderFactoryAddress=" + traderFactoryAddress, traderFactoryTxId);
      }
    }
  }
);

// TokenSellerFactory
var sellerCompiled = web3.eth.compile.solidity(sellerSource);
console.log("DATA: erc20PartialABI=" + JSON.stringify(sellerCompiled.ERC20Partial.info.abiDefinition));
console.log("DATA: tokenSellerABI=" + JSON.stringify(sellerCompiled.TokenSeller.info.abiDefinition));
console.log("DATA: tokenSellerFactoryABI=" + JSON.stringify(sellerCompiled.TokenSellerFactory.info.abiDefinition));
var sellerFactoryContract = web3.eth.contract(sellerCompiled.TokenSellerFactory.info.abiDefinition);
var sellerFactoryTxId = null;
var sellerFactoryAddress = null;
var sellerFactory = sellerFactoryContract.new({from: eth.accounts[0], data: sellerCompiled.TokenSellerFactory.code, gas: 3000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        sellerFactoryTxId = contract.transactionHash;
        console.log("sellerFactoryTxId=" + sellerFactoryTxId);
      } else {
        sellerFactoryAddress = contract.address;
        console.log("DATA: tokenSellerFactoryAddress=" + sellerFactoryAddress);
        printTxData("sellerFactoryAddress=" + sellerFactoryAddress, sellerFactoryTxId);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

var startBlock = eth.getBlock("latest").number;
var createTradeContractTxId = traderFactory.createTradeContract("$TOKENADDRESS", 110000, 120000, 100000, true, true, {from: eth.accounts[0], gas: 1000000});
var createSaleContractTxId = sellerFactory.createSaleContract("$TOKENADDRESS", 120000, 100000, true, {from: eth.accounts[0], gas: 1000000});
while (txpool.status.pending > 0) {
}
printTxData("createTradeContractTxId", createTradeContractTxId);
printTxData("createSaleContractTxId", createSaleContractTxId);
var endBlock = eth.getBlock("latest").number;

// Get TokenTrader address
var tradeListingEvent = traderFactory.TradeListing({}, { fromBlock: startBlock, toBlock: endBlock });
var i = 0;
var tokenTraderAddress = null;
tradeListingEvent.watch(function (error, result) {
  var tokenTraderFactoryAddress = result.address;
  tokenTraderAddress = result.args.tokenTraderAddress;
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
  var owner = result.args.ownerAddress;
  var blockNumber = result.blockNumber;
  var logIndex = result.logIndex;
  var transactionHash = result.transactionHash;
  console.log("DATA: tokenSellerAddress=" + tokenSellerAddress);
  console.log("DATA: tokenSellerOwner=" + owner);
  console.log(i++ + ": " + JSON.stringify(result));
});
tradeListingEvent.stopWatching();

var traderVerifyResults = traderFactory.verify(tokenTraderAddress);
console.log("RESULT: traderVerifyResults " + JSON.stringify(traderVerifyResults));
var sellerVerifyResults = sellerFactory.verify(tokenSellerAddress);
console.log("RESULT: sellerVerifyResults " + JSON.stringify(sellerVerifyResults));

// Deposit ETH to new Trader contract
console.log("RESULT: Depositing 100 ETH to tokenTrader " + tokenTraderAddress);
var tokenTrader = web3.eth.contract(traderCompiled.TokenTrader.info.abiDefinition).at(tokenTraderAddress);
var traderDepositEtherTxId = tokenTrader.makerDepositEther({from: eth.accounts[0], value: 100e18, gas: 100000});

// Transfer tokens to new Trader contract
console.log("RESULT: Transferring 100 tokens to tokenTrader " + tokenTraderAddress);
var traderTransferTokenTxId = token.transfer(tokenTraderAddress, 100e18, {from: eth.accounts[0], gas: 100000});

// Transfer tokens to new Seller contract
console.log("RESULT: Transferring 100 tokens to tokenSeller " + tokenSellerAddress);
var sellerTransferTokenTxId = token.transfer(tokenSellerAddress, 100e18, {from: eth.accounts[0], gas: 100000});

while (txpool.status.pending > 0) {
}

printTxData("traderDepositEtherTxId", traderDepositEtherTxId);
printTxData("traderTransferTokenTxId", traderTransferTokenTxId);
printTxData("sellerTransferTokenTxId", sellerTransferTokenTxId);

console.log("RESULT: Expecting 100 TokenBalance and 100 ETH in tokenTrader " + tokenTraderAddress);
console.log("RESULT: Expecting 100 TokenBalance in tokenSeller " + tokenSellerAddress);
printBalances([eth.accounts[0], eth.accounts[1], "$TOKENADDRESS", tokenTraderAddress, tokenSellerAddress]);

EOF

grep "DATA: " $TEMPOUTFILE | sed "s/DATA: //" > $FACTORYDATAFILE
grep "RESULT: " $TEMPOUTFILE | sed "s/RESULT: //" > $FACTORYRESULTFILE
cat $FACTORYRESULTFILE
