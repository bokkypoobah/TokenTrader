#!/bin/sh
# ----------------------------------------------------------------------------------------------
# Testing the unique deposit contacts for customers to deposit ethers that are sent to 
# different wallets
#
# A collaboration between Incent and Bok :)
# Enjoy. (c) Incent Loyalty Pty Ltd and Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`
TESTERC20SOL=`grep ^TESTERC20SOL= settings.txt | sed "s/^.*=//"`
TESTERC20JS=`grep ^TESTERC20JS= settings.txt | sed "s/^.*=//"`
TOKENTRADERFACTORYSOL=`grep ^TOKENTRADERFACTORYSOL= settings.txt | sed "s/^.*=//"`
TOKENTRADERFACTORYJS=`grep ^TOKENTRADERFACTORYJS= settings.txt | sed "s/^.*=//"`
TOKENSELLERFACTORYSOL=`grep ^TOKENSELLERFACTORYSOL= settings.txt | sed "s/^.*=//"`
TOKENSELLERFACTORYJS=`grep ^TOKENSELLERFACTORYJS= settings.txt | sed "s/^.*=//"`
DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

printf "GETHATTACHPOINT       = '$GETHATTACHPOINT'\n"
printf "PASSWORD              = '$PASSWORD'\n"
printf "TESTERC20SOL          = '$TESTERC20SOL'\n"
printf "TESTERC20JS           = '$TESTERC20JS'\n"
printf "TOKENTRADERFACTORYSOL = '$TOKENTRADERFACTORYSOL'\n"
printf "TOKENTRADERFACTORYJS  = '$TOKENTRADERFACTORYJS'\n"
printf "TOKENSELLERFACTORYSOL = '$TOKENSELLERFACTORYSOL'\n"
printf "TOKENSELLERFACTORYJS  = '$TOKENSELLERFACTORYJS'\n"
printf "DEPLOYMENTDATA        = '$DEPLOYMENTDATA'\n"
printf "INCLUDEJS             = '$INCLUDEJS'\n"
printf "TEST1OUTPUT           = '$TEST1OUTPUT'\n"
printf "TEST1RESULTS          = '$TEST1RESULTS'\n"

echo "var tokenOutput=`solc --optimize --combined-json abi,bin,interface $TESTERC20SOL`;" > $TESTERC20JS
echo "var tokenTraderFactoryOutput=`solc --optimize --combined-json abi,bin,interface $TOKENTRADERFACTORYSOL`;" > $TOKENTRADERFACTORYJS
echo "var tokenSellerFactoryOutput=`solc --optimize --combined-json abi,bin,interface $TOKENSELLERFACTORYSOL`;" > $TOKENSELLERFACTORYJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEST1OUTPUT
loadScript("$TESTERC20JS");
loadScript("$TOKENTRADERFACTORYJS");
loadScript("$TOKENSELLERFACTORYJS");
loadScript("functions.js");

var tokenAbi = JSON.parse(tokenOutput.contracts["../contracts/TestERC20Token.sol:TestERC20Token"].abi);
var tokenBin = "0x" + tokenOutput.contracts["../contracts/TestERC20Token.sol:TestERC20Token"].bin;
var tokenTraderAbi = JSON.parse(tokenTraderFactoryOutput.contracts["../contracts/TokenTraderFactory.sol:TokenTrader"].abi);
var tokenTraderFactoryAbi = JSON.parse(tokenTraderFactoryOutput.contracts["../contracts/TokenTraderFactory.sol:TokenTraderFactory"].abi);
var tokenTraderFactoryBin = "0x" + tokenTraderFactoryOutput.contracts["../contracts/TokenTraderFactory.sol:TokenTraderFactory"].bin;
var tokenSellerAbi = JSON.parse(tokenSellerFactoryOutput.contracts["../contracts/TokenSellerFactory.sol:TokenSeller"].abi);
var tokenSellerFactoryAbi = JSON.parse(tokenSellerFactoryOutput.contracts["../contracts/TokenSellerFactory.sol:TokenSellerFactory"].abi);
var tokenSellerFactoryBin = "0x" + tokenSellerFactoryOutput.contracts["../contracts/TokenSellerFactory.sol:TokenSellerFactory"].bin;

console.log("DATA: tokenABI=" + JSON.stringify(tokenAbi));
console.log("DATA: tokenTraderABI=" + JSON.stringify(tokenTraderAbi));
console.log("DATA: tokenTraderFactoryABI=" + JSON.stringify(tokenTraderFactoryAbi));
console.log("DATA: tokenSellerABI=" + JSON.stringify(tokenSellerAbi));
console.log("DATA: tokenSellerFactoryABI=" + JSON.stringify(tokenSellerFactoryAbi));

unlockAccounts("$PASSWORD");
printBalances();

var tokenContract = web3.eth.contract(tokenAbi);
var tokenTraderFactoryContract = web3.eth.contract(tokenTraderFactoryAbi);
var tokenSellerFactoryContract = web3.eth.contract(tokenSellerFactoryAbi);

// -----------------------------------------------------------------------------
var testMessage = "Setup 1.1 Deploy Tokens And Factories";
console.log("RESULT: " + testMessage);

var token0Tx = null;
token0 = tokenContract.new("Token 0 Decimals", "TOKEN0", 0, {from: tokenOwnerAccount, data: tokenBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        token0Tx = contract.transactionHash;
      } else {
        token0Address = contract.address;
        addAccount(token0Address, "TOKEN0");
        console.log("DATA: token0Address=" + token0Address);
        printTxData("token0Address=" + token0Address, token0Tx);
      }
    }
  }
);
var token1Tx = null;
token1 = tokenContract.new("Token 1 Decimals", "TOKEN1", 1, {from: tokenOwnerAccount, data: tokenBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        token1Tx = contract.transactionHash;
      } else {
        token1Address = contract.address;
        addAccount(token1Address, "TOKEN1");
        console.log("DATA: token1Address=" + token1Address);
        printTxData("token1Address=" + token1Address, token1Tx);
      }
    }
  }
);
var token2Tx = null;
token2 = tokenContract.new("Token 2 Decimals", "TOKEN2", 2, {from: tokenOwnerAccount, data: tokenBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        token2Tx = contract.transactionHash;
      } else {
        token2Address = contract.address;
        addAccount(token2Address, "TOKEN2");
        console.log("DATA: token2Address=" + token2Address);
        printTxData("token2Address=" + token2Address, token2Tx);
      }
    }
  }
);
var token8Tx = null;
token8 = tokenContract.new("Token 8 Decimals", "TOKEN8", 8, {from: tokenOwnerAccount, data: tokenBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        token8Tx = contract.transactionHash;
      } else {
        token8Address = contract.address;
        addAccount(token8Address, "TOKEN8");
        console.log("DATA: token8Address=" + token8Address);
        printTxData("token8Address=" + token8Address, token8Tx);
      }
    }
  }
);
var token18Tx = null;
token18 = tokenContract.new("Token 18 Decimals", "TOKEN18", 18, {from: tokenOwnerAccount, data: tokenBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        token18Tx = contract.transactionHash;
      } else {
        token18Address = contract.address;
        addAccount(token18Address, "TOKEN18");
        console.log("DATA: token18Address=" + token18Address);
        printTxData("token18Address=" + token18Address, token18Tx);
      }
    }
  }
);
var tokenTraderFactoryTx = null;
tokenTraderFactory = tokenTraderFactoryContract.new({from: factoryOwnerAccount, data: tokenTraderFactoryBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTraderFactoryTx = contract.transactionHash;
      } else {
        tokenTraderFactoryAddress = contract.address;
        addAccount(tokenTraderFactoryAddress, "TokenTraderFactory");
        console.log("DATA: tokenTraderFactoryAddress=" + tokenTraderFactoryAddress);
        printTxData("tokenTraderFactoryAddress=" + tokenTraderFactoryAddress, tokenTraderFactoryTx);
      }
    }
  }
);
var tokenSellerFactoryTx = null;
tokenSellerFactory = tokenSellerFactoryContract.new({from: factoryOwnerAccount, data: tokenSellerFactoryBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenSellerFactoryTx = contract.transactionHash;
      } else {
        tokenSellerFactoryAddress = contract.address;
        addAccount(tokenSellerFactoryAddress, "TokenSellerFactory");
        console.log("DATA: tokenSellerFactoryAddress=" + tokenSellerFactoryAddress);
        printTxData("tokenSellerFactoryAddress=" + tokenSellerFactoryAddress, tokenSellerFactoryTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();


// -----------------------------------------------------------------------------
var testMessage = "Setup 1.2 Tokens";
console.log("RESULT: " + testMessage);
var tx12_0 = eth.sendTransaction({from: maker1Account, to: token0Address, gas: 400000, value: "1000"});                     // 1000
var tx12_1 = eth.sendTransaction({from: maker1Account, to: token1Address, gas: 400000, value: "10000"});                    // 1000.0
var tx12_2 = eth.sendTransaction({from: maker1Account, to: token2Address, gas: 400000, value: "100000"});                   // 1000.00
var tx12_8 = eth.sendTransaction({from: maker1Account, to: token8Address, gas: 400000, value: "100000000000"});             // 1000.00000000
var tx12_18 = eth.sendTransaction({from: maker1Account, to: token18Address, gas: 400000, value: "1000000000000000000000"}); // 1000.000000000000000000
while (txpool.status.pending > 0) {
}
printTxData("tx12_0", tx12_0);
printTxData("tx12_1", tx12_1);
printTxData("tx12_2", tx12_2);
printTxData("tx12_8", tx12_8);
printTxData("tx12_18", tx12_18);
printBalances();
failIfGasEqualsGasUsed(tx12_0, testMessage + " Token0");
failIfGasEqualsGasUsed(tx12_1, testMessage + " Token1");
failIfGasEqualsGasUsed(tx12_2, testMessage + " Token2");
failIfGasEqualsGasUsed(tx12_8, testMessage + " Token8");
failIfGasEqualsGasUsed(tx12_18, testMessage + " Token18");
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Setup 1.3 Trader Contracts";
console.log("RESULT: " + testMessage);
var startBlock = eth.blockNumber;
var tx13_0 = tokenTraderFactory.createTradeContract(token0Address, "11111", "22222", "10000", true, true, {from: maker1Account, gas: 1000000});
var tx13_1 = tokenTraderFactory.createTradeContract(token1Address, "111110", "222220", "10000", true, true, {from: maker1Account, gas: 1000000});
var tx13_2 = tokenTraderFactory.createTradeContract(token2Address, "1111100", "2222200", "10000", true, true, {from: maker1Account, gas: 1000000});
var tx13_8 = tokenTraderFactory.createTradeContract(token8Address, "1111100000000", "22222000000000", "10000", true, true, {from: maker1Account, gas: 1000000});
// var tx13_18 = tokenTraderFactory.createTradeContract(token18Address, "11111", "22222", "10000", true, true, {from: maker1Account, gas: 1000000});
var tx13_18 = tokenTraderFactory.createTradeContract(token18Address, "2555", "2666", "1000000", true, true, {from: maker1Account, gas: 1000000});
while (txpool.status.pending > 0) {
}
printTxData("tx13_0", tx13_0);
printTxData("tx13_1", tx13_1);
printTxData("tx13_2", tx13_2);
printTxData("tx13_8", tx13_8);
printTxData("tx13_18", tx13_18);
printBalances();
failIfGasEqualsGasUsed(tx13_0, testMessage + " Token0");
failIfGasEqualsGasUsed(tx13_1, testMessage + " Token0");
failIfGasEqualsGasUsed(tx13_2, testMessage + " Token0");
failIfGasEqualsGasUsed(tx13_8, testMessage + " Token0");
failIfGasEqualsGasUsed(tx13_18, testMessage + " Token0");
console.log("RESULT: ");
var endBlock = eth.blockNumber;

// Get TokenTrader address
// var tradeListingEvent = tokenTraderFactory.TradeListing({}, { fromBlock: startBlock, toBlock: endBlock });
var tradeListingEvent = tokenTraderFactory.TradeListing({}, { fromBlock: 0, toBlock: "latest" });
var i = 0;
var tokenTrader0Address = null;
var tokenTrader1Address = null;
var tokenTrader2Address = null;
var tokenTrader8Address = null;
var tokenTrader18Address = null;
tradeListingEvent.watch(function (error, result) {
// var tokenTraderFactoryAddress = result.address;
// var owner = result.args.ownerAddress;
 var asset = result.args.asset;
if (asset == token0Address) {
 tokenTrader0Address = result.args.tokenTraderAddress;
  addAccount(tokenTrader0Address, "TokenTrader0");
  console.log("DATA: tokenTrader0Address=" + tokenTrader0Address);
} else if (asset == token1Address) {
tokenTrader1Address = result.args.tokenTraderAddress;
addAccount(tokenTrader1Address, "TokenTrader1");
  console.log("DATA: tokenTrader1Address=" + tokenTrader1Address);
} else if (asset == token2Address) {
tokenTrader2Address = result.args.tokenTraderAddress;
addAccount(tokenTrader2Address, "TokenTrader2");
  console.log("DATA: tokenTrader2Address=" + tokenTrader2Address);
} else if (asset == token8Address) {
tokenTrader8Address = result.args.tokenTraderAddress;
addAccount(tokenTrader8Address, "TokenTrader8");
  console.log("DATA: tokenTrader8Address=" + tokenTrader8Address);
} else if (asset == token18Address) {
tokenTrader18Address = result.args.tokenTraderAddress;
addAccount(tokenTrader18Address, "TokenTrader18");
  console.log("DATA: tokenTrader18Address=" + tokenTrader18Address);
}
//  var blockNumber = result.blockNumber;
//  var logIndex = result.logIndex;
//  var transactionHash = result.transactionHash;
//  console.log("DATA: tokenTraderOwner=" + owner);
  console.log(i++ + ": " + JSON.stringify(result));
});
tradeListingEvent.stopWatching();
printBalances();


// -----------------------------------------------------------------------------
var testMessage = "Setup 1.4 Transfer tokens to TokenTrader";
console.log("RESULT: " + testMessage);
var tx14_0 = token0.transfer(tokenTrader0Address, "100", {from: maker1Account, gas: 100000});
var tx14_1 = token1.transfer(tokenTrader1Address, "1000", {from: maker1Account, gas: 100000});
var tx14_2 = token2.transfer(tokenTrader2Address, "10000", {from: maker1Account, gas: 100000});
var tx14_8 = token8.transfer(tokenTrader8Address, "10000000000", {from: maker1Account, gas: 100000});
var tx14_18 = token18.transfer(tokenTrader18Address, "100000000000000000000", {from: maker1Account, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx14_0", tx14_0);
printTxData("tx14_1", tx14_1);
printTxData("tx14_2", tx14_2);
printTxData("tx14_8", tx14_8);
printTxData("tx14_18", tx14_18);
printBalances();
failIfGasEqualsGasUsed(tx14_0, testMessage + " Token0");
failIfGasEqualsGasUsed(tx14_1, testMessage + " Token1");
failIfGasEqualsGasUsed(tx14_2, testMessage + " Token2");
failIfGasEqualsGasUsed(tx14_8, testMessage + " Token8");
failIfGasEqualsGasUsed(tx14_18, testMessage + " Token18");
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 1.5 Buy Tokens from TokenTrader";
console.log("RESULT: " + testMessage);
var tx15_0 = eth.sendTransaction({from: taker1Account, to: tokenTrader0Address, gas: 400000, value: "100"});
var tx15_1 = eth.sendTransaction({from: taker1Account, to: tokenTrader1Address, gas: 400000, value: "100"});
var tx15_2 = eth.sendTransaction({from: taker1Account, to: tokenTrader2Address, gas: 400000, value: "100"});
var tx15_8 = eth.sendTransaction({from: taker1Account, to: tokenTrader8Address, gas: 400000, value: "100"});
var tx15_18 = eth.sendTransaction({from: taker1Account, to: tokenTrader18Address, gas: 400000, value: "100"});
while (txpool.status.pending > 0) {
}
printTxData("tx15_0", tx15_0);
printTxData("tx15_1", tx15_1);
printTxData("tx15_2", tx15_2);
printTxData("tx15_8", tx15_8);
printTxData("tx15_18", tx15_18);
printBalances();
failIfGasEqualsGasUsed(tx15_0, testMessage + " Token0");
failIfGasEqualsGasUsed(tx15_1, testMessage + " Token1");
failIfGasEqualsGasUsed(tx15_2, testMessage + " Token2");
failIfGasEqualsGasUsed(tx15_8, testMessage + " Token8");
failIfGasEqualsGasUsed(tx15_18, testMessage + " Token18");
console.log("RESULT: ");


exit;

printContractStaticDetails();
printContractDynamicDetails();
failIfGasEqualsGasUsedOrContractAddressNull(depositContractFactoryAddress, depositContractFactoryTx, testMessage);
console.log("RESULT: ");

// Load source code
loadScript("$INCLUDEJS");
// console.log("depositContractFactorySource=" + depositContractFactorySource);

var depositContractFactoryCompiled = web3.eth.compile.solidity(depositContractFactorySource);
console.log("----------v depositContractFactoryCompiled v----------");
depositContractFactoryCompiled;
console.log("----------^ depositContractFactoryCompiled ^----------");
console.log("DATA: tokenABI=" + JSON.stringify(depositContractFactoryCompiled["<stdin>:CustomerDepositFactory"].info.abiDefinition));

// -----------------------------------------------------------------------------
var testMessage = "Test 1.1 Deploy Deposit Contract";
console.log("RESULT: " + testMessage);
var depositContractFactoryTx = null;
var depositContractFactoryContract = web3.eth.contract(depositContractFactoryCompiled["<stdin>:CustomerDepositFactory"].info.abiDefinition);
var depositContractFactory = depositContractFactoryContract.new({from: customerDepositFactoryOwnerAccount,
  data: depositContractFactoryCompiled["<stdin>:CustomerDepositFactory"].code, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        depositContractFactoryTx = contract.transactionHash;
        console.log("depositContractFactoryTx=" + depositContractFactoryTx);
      } else {
        depositContractFactoryAddress = contract.address;
        addAccount(depositContractFactoryAddress, "Customer Deposit Factory");
        addContractAddressAndAbi(depositContractFactoryAddress, depositContractFactoryCompiled["<stdin>:CustomerDepositFactory"].info.abiDefinition);
        printTxData("depositContractFactoryAddress=" + depositContractFactoryAddress, depositContractFactoryTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
printContractStaticDetails();
printContractDynamicDetails();
failIfGasEqualsGasUsedOrContractAddressNull(depositContractFactoryAddress, depositContractFactoryTx, testMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.2 Create 1 Deposit Contract";
console.log("RESULT: " + testMessage);
var tx12 = depositContractFactory.createDepositContracts(1, {from: customerDepositFactoryOwnerAccount, gas: 4500000});
while (txpool.status.pending > 0) {
}
printBalances();
printContractDynamicDetails();
printTxData("tx12", tx12);
failIfGasEqualsGasUsed(tx12, testMessage);
console.log("RESULT: Transaction input: " + eth.getTransaction(tx12).input);
console.log("RESULT: ");

// -----------------------------------------------------------------------------
testMessage = "Test 1.3 Contribute before contribution period is active - unsuccessful";
console.log("RESULT: " + testMessage);
var depositContract0 = depositContractFactory.depositContracts(0);
var tx13 = eth.sendTransaction({from: customer1Account, to: depositContract0, gas: 400000, value: web3.toWei(100, "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("tx13", tx13);
passIfGasEqualsGasUsed(tx13, testMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.4 Create 10 Deposit Contracts";
console.log("RESULT: " + testMessage);
var tx14 = depositContractFactory.createDepositContracts(10, {from: customerDepositFactoryOwnerAccount, gas: 4500000});
while (txpool.status.pending > 0) {
}
printTxData("tx14", tx14);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx14, testMessage);
console.log("RESULT: Transaction input: " + eth.getTransaction(tx14).input);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.5 Create 20 Deposit Contracts";
console.log("RESULT: " + testMessage);
var tx15 = depositContractFactory.createDepositContracts(20, {from: customerDepositFactoryOwnerAccount, gas: 4500000});
while (txpool.status.pending > 0) {
}
printTxData("tx15", tx15);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx15, testMessage);
console.log("RESULT: Transaction input: " + eth.getTransaction(tx15).input);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.6 Customer1 Deposit 10.23456789 ETH";
console.log("RESULT: " + testMessage);

var depositDateFromTime = depositContractFactory.DEPOSIT_DATE_FROM();
var depositDateFromDate = new Date(depositDateFromTime * 1000);
console.log("RESULT: Waiting until deposit period is active at " + depositDateFromTime + " " + depositDateFromDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= depositDateFromDate.getTime()) {
}
console.log("RESULT: Waited until deposit period is active at " + depositDateFromTime + " " + depositDateFromDate +
  " currentDate=" + new Date());

var depositContract0 = depositContractFactory.depositContracts(0);
var tx16 = eth.sendTransaction({from: customer1Account, to: depositContract0, gas: 400000, value: web3.toWei(10.23456789, "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx16", tx16);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx16, testMessage);
console.log("RESULT:   CHECK Test 1.6. Test Customer1 Deposit 10.23456789 ETH - split 0.051172839/0.051172839/10.13222221");
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.7 Customer2 Deposit 1000 ETH";
console.log("RESULT: " + testMessage);
var depositContract1 = depositContractFactory.depositContracts(1);
var tx17 = eth.sendTransaction({from: customer2Account, to: depositContract1, gas: 400000, value: web3.toWei(1000, "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx17", tx17);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx17, testMessage);
console.log("RESULT:   CHECK Test 1.7. Test Customer2 Deposit 1000 ETH - split 5/5/990");
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.8 Customer2 Deposit 100 ETH with too little gas - unsuccessful";
console.log("RESULT: " + testMessage);
var depositContract1 = depositContractFactory.depositContracts(1);
var tx18 = eth.sendTransaction({from: customer2Account, to: depositContract1, gas: 50000, value: web3.toWei(100, "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx18", tx18);
printBalances();
printContractDynamicDetails();
passIfGasEqualsGasUsed(tx18, testMessage);
console.log("RESULT:   CHECK Test 1.8. There should be no partial payments");
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.9 Close funding";
console.log("RESULT: " + testMessage);
var tx19 = depositContractFactory.setFundingClosed(true, {from: customerDepositFactoryOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("tx19", tx19);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx19, testMessage);
console.log("RESULT: Transaction input: " + eth.getTransaction(tx19).input);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.10 Contribute when funding is closed - unsuccessful";
console.log("RESULT: " + testMessage);
var depositContract2 = depositContractFactory.depositContracts(2);
var tx110 = eth.sendTransaction({from: customer2Account, to: depositContract1, gas: 400000, value: web3.toWei(100, "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx110", tx110);
printBalances();
printContractDynamicDetails();
passIfGasEqualsGasUsed(tx110, testMessage);
console.log("RESULT:   CHECK 1. There should be no payments");
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.11 Reopen funding";
console.log("RESULT: " + testMessage);
var tx111 = depositContractFactory.setFundingClosed(false, {from: customerDepositFactoryOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("tx111", tx111);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx111, testMessage);
console.log("RESULT: Transaction input: " + eth.getTransaction(tx111).input);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 1.12 Contribute when funding is re-opened";
console.log("RESULT: " + testMessage);
var depositContract3 = depositContractFactory.depositContracts(3);
var tx111 = eth.sendTransaction({from: customer2Account, to: depositContract1, gas: 400000, value: web3.toWei(100, "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx111", tx111);
printBalances();
printContractDynamicDetails();
failIfGasEqualsGasUsed(tx111, testMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Test 2.0 Customer1 Deposit 100 ETH after end - unsuccessful";
console.log("RESULT: " + testMessage);

var depositDateToTime = depositContractFactory.DEPOSIT_DATE_TO();
var depositDateToDate = new Date(depositDateToTime * 1000);
console.log("RESULT: Waiting until deposit period is inactive at " + depositDateToTime + " " + depositDateToDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= depositDateToDate.getTime()) {
}
console.log("RESULT: Waited until deposit period is inactive at " + depositDateToTime + " " + depositDateToDate +
  " currentDate=" + new Date());

var depositContract0 = depositContractFactory.depositContracts(0);
var tx20 = eth.sendTransaction({from: customer1Account, to: depositContract0, gas: 400000, value: web3.toWei(100, "ether")});
while (txpool.status.pending > 0) {
}
printTxData("tx20", tx20);
printBalances();
printContractDynamicDetails();
passIfGasEqualsGasUsed(tx20, testMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
testMessage = "Extract Events";
console.log("RESULT: " + testMessage);
var filter = web3.eth.filter({ address: [depositContractFactoryAddress], fromBlock: 0, toBlock: "latest" });
var i = 0;
filter.watch(function (error, result) {
  console.log("RESULT: Filter " + i++ + ": " + JSON.stringify(result));
});
filter.stopWatching();
console.log("RESULT: ");


EOF
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA