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
CUSTOMERDEPOSITFACTORYSOL=`grep ^CUSTOMERDEPOSITFACTORYSOL= settings.txt | sed "s/^.*=//"`
CUSTOMERDEPOSITFACTORYTEMPSOL=`grep ^CUSTOMERDEPOSITFACTORYTEMPSOL= settings.txt | sed "s/^.*=//"`
INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

printf "GETHATTACHPOINT               = '$GETHATTACHPOINT'\n"
printf "PASSWORD                      = '$PASSWORD'\n"
printf "CUSTOMERDEPOSITFACTORYSOL     = '$CUSTOMERDEPOSITFACTORYSOL'\n"
printf "CUSTOMERDEPOSITFACTORYTEMPSOL = '$CUSTOMERDEPOSITFACTORYTEMPSOL'\n"
printf "INCLUDEJS                     = '$INCLUDEJS'\n"
printf "TEST1OUTPUT                   = '$TEST1OUTPUT'\n"
printf "TEST1RESULTS                  = '$TEST1RESULTS'\n"

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`
CURRENTTIMEP1M=`echo "$CURRENTTIME+60" | bc`
CURRENTTIMEP1MS=`date -r $CURRENTTIMEP1M -u`
CURRENTTIMEP3M=`echo "$CURRENTTIME+60*3" | bc`
CURRENTTIMEP3MS=`date -r $CURRENTTIMEP3M -u`
printf "CURRENTTIME                   = '$CURRENTTIME' '$CURRENTTIMES'\n"
printf "CURRENTTIMEP1M                = '$CURRENTTIMEP1M' '$CURRENTTIMEP1MS'\n"
printf "CURRENTTIMEP3M                = '$CURRENTTIMEP3M' '$CURRENTTIMEP3MS'\n"


# --- Make copy of SOL file and strip out comments ---
`cp $CUSTOMERDEPOSITFACTORYSOL $CUSTOMERDEPOSITFACTORYTEMPSOL`
`perl -pi -e "s/^\/\*.*$//; s/^ \*.*$//; " $CUSTOMERDEPOSITFACTORYTEMPSOL`

# --- Modify addresses ---
`perl -pi -e "s/{{DEPOSIT_DATE_FROM}}/$CURRENTTIMEP1M/" $CUSTOMERDEPOSITFACTORYTEMPSOL`
`perl -pi -e "s/{{DEPOSIT_DATE_TO}}/$CURRENTTIMEP3M/" $CUSTOMERDEPOSITFACTORYTEMPSOL`
`perl -pi -e "s/{{INCENTACCOUNT}}/0x0020017ba4c67f76c76b1af8c41821ee54f37171/" $CUSTOMERDEPOSITFACTORYTEMPSOL`
`perl -pi -e "s/{{FEEACCOUNT}}/0x0036f6addb6d64684390f55a92f0f4988266901b/" $CUSTOMERDEPOSITFACTORYTEMPSOL`
`perl -pi -e "s/{{CLIENTACCOUNT}}/0x004e64833635cd1056b948b57286b7c91e62731c/" $CUSTOMERDEPOSITFACTORYTEMPSOL`

# --- Check differences ---
TEST=`diff $CUSTOMERDEPOSITFACTORYSOL $CUSTOMERDEPOSITFACTORYTEMPSOL`
echo "--- Differences ---"
echo "$TEST"

FLATTENEDCUSTOMERDEPOSITFACTORYSOL=`./stripCrLf $CUSTOMERDEPOSITFACTORYTEMPSOL | tr -s ' '`
printf "var depositContractFactorySource = \"$FLATTENEDCUSTOMERDEPOSITFACTORYSOL\";" > $INCLUDEJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEST1OUTPUT
loadScript("functions.js");
unlockAccounts("$PASSWORD");
printBalances();

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