#!/bin/sh
# --------------------------------------------------------------------
# Testing Contracts At https://github.com/bokkypoobah/TokenTrader
#
# Deploy ERC20 Token
#
# (c) BokkyPooBah 2017. The MIT licence.
# --------------------------------------------------------------------

GETHATTACHPOINT=`grep IPCFILE settings.txt | sed "s/^.*=//"`
PASSWORD=`grep PASSWORD settings.txt | sed "s/^.*=//"`

TYPE=`grep TYPE settings.txt | sed "s/^.*=//"`
INITIALETH=`grep INITIALETH settings.txt | sed "s/^.*=//"`

TEMPINFILE=`grep TEMPINFILE settings.txt | sed "s/^.*=//"`
TOKENOUTPUTFILE=`grep TOKENOUTPUTFILE settings.txt | sed "s/^.*=//"`

TOKENSOL=`grep TOKENSOL settings.txt | sed "s/^.*=//"`
FLATTENEDSOL=`./stripCrLf $TOKENSOL`
printf "var tokenSource = \"$FLATTENEDSOL\"" > $TEMPINFILE

TOKENDATAFILE=`grep TOKENDATA settings.txt | sed "s/^.*=//"`
TOKENRESULTFILE=`grep TOKENRESULTFILE settings.txt | sed "s/^.*=//"`

printf "geth endpoint '$GETHATTACHPOINT'\n" | tee $TOKENOUTPUTFILE

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TOKENOUTPUTFILE

var ACCOUNTS = 3;

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

var accounts = [eth.accounts[0], eth.accounts[1], eth.accounts[2]];
var accountName = {};
accountName[eth.accounts[0]] = "Account #0";
accountName[eth.accounts[1]] = "Account #1";
accountName[eth.accounts[2]] = "Account #2";

function printBalances(accounts) {
  var i = 0;
  console.log("RESULT: # Account                                                   EtherBalance               TokenABalance               TokenBBalance               TokenCBalance Name");
  accounts.forEach(function(e) {
    i++;
    var etherBalance = web3.fromWei(eth.getBalance(e), "ether");
    var tokenABalance = web3.fromWei(tokenA.balanceOf(e), "ether");
    var tokenBBalance = web3.fromWei(tokenB.balanceOf(e), "ether");
    var tokenCBalance = web3.fromWei(tokenC.balanceOf(e), "ether");
    console.log("RESULT: " + i + " " + e  + " " + pad(etherBalance) + " " + pad(tokenABalance) + " " + pad(tokenBBalance) + " " +
      pad(tokenCBalance) + " " + accountName[e]);
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
  if (etherBalance == testBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + testBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + testBalance);
  }
}

function assertTokenBalance(account, token, testBalance) {
  var tokenBalance = token.balanceOf(account).div(1e18);
  if (tokenBalance == testBalance) {
    console.log("RESULT: OK " + account + " has expected " + accountName[token.address] + " token balance " + testBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has " + accountName[token.address] + " token balance " + tokenBalance + " <> expected " + testBalance);
  }
}

console.log("RESULT: Creating ERC20 Token @ " + new Date());

for (var i = 0; i < ACCOUNTS; i++) {
  personal.unlockAccount(eth.accounts[i], "$PASSWORD", 100000);
}

loadScript("$TEMPINFILE");

var tokenCompiled = web3.eth.compile.solidity(tokenSource);
console.log("DATA: tokenABI=" + JSON.stringify(tokenCompiled.TestERC20Token.info.abiDefinition));
var tokenContract = web3.eth.contract(tokenCompiled.TestERC20Token.info.abiDefinition);

// TokenA
var tokenAddressA = null;
var tokenTxA = null;
var tokenA = tokenContract.new({from: eth.accounts[1], data: tokenCompiled.TestERC20Token.code, gas: 400000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTxA = contract.transactionHash;
        console.log("tokenTxA=" + tokenTxA);
      } else {
        tokenAddressA = contract.address;
        accountName[tokenAddressA] = "ERC20A";
        console.log("DATA: tokenAddressA=" + tokenAddressA);
        printTxData("tokenAddressA=" + tokenAddressA, tokenTxA);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}

// TokenB
var tokenAddressB = null;
var tokenTxB = null;
var tokenB = tokenContract.new({from: eth.accounts[1], data: tokenCompiled.TestERC20Token.code, gas: 400000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTxB = contract.transactionHash;
        console.log("tokenTxB=" + tokenTxB);
      } else {
        tokenAddressB = contract.address;
        accountName[tokenAddressB] = "ERC20B";
        console.log("DATA: tokenAddressB=" + tokenAddressB);
        printTxData("tokenAddressB=" + tokenAddressB, tokenTxB);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}

// TokenC
var tokenAddressC = null;
var tokenTxC = null;
var tokenC = tokenContract.new({from: eth.accounts[1], data: tokenCompiled.TestERC20Token.code, gas: 400000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTxC = contract.transactionHash;
        console.log("tokenTxC=" + tokenTxC);
      } else {
        tokenAddressC = contract.address;
        accountName[tokenAddressC] = "ERC20C";
        console.log("DATA: tokenAddressC=" + tokenAddressC);
        printTxData("tokenAddressC=" + tokenAddressC, tokenTxC);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}

var txIdsA = [];
for (var i = 0; i < ACCOUNTS; i++) {
  console.log("Sending $INITIALETH ETH from eth.accounts[" + i + "] to tokenA " + tokenAddressA);
  txIdsA[i] = eth.sendTransaction({from: eth.accounts[i], to: tokenAddressA, value: web3.toWei("$INITIALETH", "ether"), gas: 100000});
  console.log("txIdsA[" + i + "]=" + txIdsA[i]);
}

var txIdsB = [];
for (var i = 0; i < ACCOUNTS; i++) {
  console.log("Sending $INITIALETH ETH from eth.accounts[" + i + "] to tokenB " + tokenAddressB);
  txIdsB[i] = eth.sendTransaction({from: eth.accounts[i], to: tokenAddressB, value: web3.toWei("$INITIALETH", "ether"), gas: 100000});
  console.log("txIdsB[" + i + "]=" + txIdsB[i]);
}

var txIdsC = [];
for (var i = 0; i < ACCOUNTS; i++) {
  console.log("Sending $INITIALETH ETH from eth.accounts[" + i + "] to tokenC " + tokenAddressC);
  txIdsC[i] = eth.sendTransaction({from: eth.accounts[i], to: tokenAddressC, value: web3.toWei("$INITIALETH", "ether"), gas: 100000});
  console.log("txIdsC[" + i + "]=" + txIdsC[i]);
}
while (txpool.status.pending > 0) {
}

for (var i = 0; i < ACCOUNTS; i++) {
  printTxData("Sent $INITIALETH ETH from accounts[" + i + "] to tokenA " + tokenAddressA.substring(0, 10), txIdsA[i]);
}
for (var i = 0; i < ACCOUNTS; i++) {
  printTxData("Sent $INITIALETH ETH from accounts[" + i + "] to tokenB " + tokenAddressB.substring(0, 10), txIdsB[i]);
}
for (var i = 0; i < ACCOUNTS; i++) {
  printTxData("Sent $INITIALETH ETH from accounts[" + i + "] to tokenC " + tokenAddressC.substring(0, 10), txIdsC[i]);
}

printBalances([eth.accounts[0], eth.accounts[1], eth.accounts[2], tokenAddressA, tokenAddressB, tokenAddressC]);

assertEtherBalance(tokenAddressA, 3000);
assertEtherBalance(tokenAddressB, 3000);
assertEtherBalance(tokenAddressC, 3000);

assertTokenBalance(eth.accounts[0], tokenA, 1000);
assertTokenBalance(eth.accounts[1], tokenA, 1000);
assertTokenBalance(eth.accounts[2], tokenA, 1000);

assertTokenBalance(eth.accounts[0], tokenB, 1000);
assertTokenBalance(eth.accounts[1], tokenB, 1000);
assertTokenBalance(eth.accounts[2], tokenB, 1000);

assertTokenBalance(eth.accounts[0], tokenB, 1000);
assertTokenBalance(eth.accounts[1], tokenB, 1000);
assertTokenBalance(eth.accounts[2], tokenB, 1000);

EOF

grep "DATA: " $TOKENOUTPUTFILE | sed "s/DATA: //" > $TOKENDATAFILE
grep "RESULT: " $TOKENOUTPUTFILE | sed "s/RESULT: //" > $TOKENRESULTFILE
cat $TOKENRESULTFILE
