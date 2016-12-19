#!/bin/sh
# --------------------------------------------------------------------
# Deploy ERC20 Token
#
# (c) BokkyPooBah 2016. The MIT licence.
# --------------------------------------------------------------------

GETHATTACHPOINT=`grep IPCFILE settings.txt | sed "s/^.*=//"`
PASSWORD=`grep PASSWORD settings.txt | sed "s/^.*=//"`

TYPE=`grep TYPE settings.txt | sed "s/^.*=//"`
INITIALETH=`grep INITIALETH settings.txt | sed "s/^.*=//"`

TEMPINFILE=`grep TEMPINFILE settings.txt | sed "s/^.*=//"`
TEMPOUTFILE=`grep TEMPOUTFILE settings.txt | sed "s/^.*=//"`

TOKENSOL=`grep TOKENSOL settings.txt | sed "s/^.*=//"`
FLATTENEDSOL=`./stripCrLf $TOKENSOL`
printf "var tokenSource = \"$FLATTENEDSOL\"" > $TEMPINFILE

TOKENDATAFILE=`grep TOKENDATA settings.txt | sed "s/^.*=//"`
TOKENRESULTFILE=`grep TOKENRESULTFILE settings.txt | sed "s/^.*=//"`

printf "geth endpoint '$GETHATTACHPOINT'\n" | tee $TEMPOUTFILE

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEMPOUTFILE

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
    i++;
    var etherBalance = web3.fromWei(eth.getBalance(e), "ether");
    var tokenBalance = web3.fromWei(token.balanceOf(e), "ether");
    console.log("RESULT: " + i + " " + e  + " " + pad(etherBalance) + " " + pad(tokenBalance));
  });
}

function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed);
}

console.log("RESULT: Creating ERC20 Token @ " + new Date());

personal.unlockAccount(eth.accounts[0], "$PASSWORD", 100000);
personal.unlockAccount(eth.accounts[1], "$PASSWORD", 100000);

loadScript("$TEMPINFILE");

var tokenCompiled = web3.eth.compile.solidity(tokenSource);
console.log("DATA: tokenABI=" + JSON.stringify(tokenCompiled.ERC20Token.info.abiDefinition));
var tokenContract = web3.eth.contract(tokenCompiled.ERC20Token.info.abiDefinition);
var tokenAddress = null;
var tokenTx = null;
var token = tokenContract.new({from: eth.accounts[0], data: tokenCompiled.ERC20Token.code, gas: 400000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
        console.log("tokenTx=" + contract.transactionHash);
      } else {
        tokenAddress = contract.address;
        console.log("DATA: tokenAddress=" + tokenAddress);
        printTxData("tokenAddress=" + tokenAddress, tokenTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}

var txIds = [];
for (var i = 0; i < 2; i++) {
  console.log("Sending $INITIALETH ETH from eth.accounts[" + i + "] to token " + tokenAddress);
  txIds[i] = eth.sendTransaction({from: eth.accounts[i], to: tokenAddress, value: web3.toWei("$INITIALETH", "ether"), gas: 100000});
  console.log("txIds[" + i + "]=" + txIds[i]);
}
while (txpool.status.pending > 0) {
}

for (var i = 0; i < 2; i++) {
  printTxData("Sent $INITIALETH ETH from eth.accounts[" + i + "] to token " + tokenAddress, txIds[i]);
}

console.log("RESULT: Expecting $INITIALETH TokenBalance in accounts 0 and 1, 2 x $INITIALETH in token EtherBalance");
printBalances([eth.accounts[0], eth.accounts[1], tokenAddress]);

EOF

grep "DATA: " $TEMPOUTFILE | sed "s/DATA: //" > $TOKENDATAFILE
grep "RESULT: " $TEMPOUTFILE | sed "s/RESULT: //" > $TOKENRESULTFILE
cat $TOKENRESULTFILE
