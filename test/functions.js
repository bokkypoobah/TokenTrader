var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - CustomerDepositFactory Owner");
addAccount(eth.accounts[2], "Account #2 - Incent Account");
addAccount(eth.accounts[3], "Account #3 - Fee Account");
addAccount(eth.accounts[4], "Account #4 - Client Account");
addAccount(eth.accounts[5], "Account #5 - Customer1 Account");
addAccount(eth.accounts[6], "Account #6 - Customer2 Account");

var tokenOwnerAccount = eth.accounts[1];
var customerDepositFactoryOwnerAccount = eth.accounts[1];
var incentAccount = eth.accounts[2];
var feeAccount = eth.accounts[3];
var clientAccount = eth.accounts[4];
var customer1Account = eth.accounts[5];
var customer2Account = eth.accounts[6];
var depositContractFactoryAddress = null;

function unlockAccounts(password) {
  for (var i = 0; i < 7; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}

function printBalances() {
  var i = 0;
  console.log("RESULT: # Account                                                   EtherBalance Name");
  accounts.forEach(function(e) {
    i++;
    var etherBalance = web3.fromWei(eth.getBalance(e), "ether");
    console.log("RESULT: " + i + " " + e  + " " + pad(etherBalance) + " " + accountNames[e]);
  });
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed + " cost=" + tx.gasPrice.mul(txReceipt.gasUsed).div(1e18) +
    " block=" + txReceipt.blockNumber + " txId=" + txId);
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}

var contractAddress = null;
var contractAbi = null;

function addContractAddressAndAbi(address, abi) {
  contractAddress = address;
  contractAbi = abi;
}

function printContractStaticDetails() {
  var contract = eth.contract(contractAbi).at(contractAddress);
  var depositDateFrom = contract.DEPOSIT_DATE_FROM();
  console.log("RESULT: contract.depositDateFrom=" + depositDateFrom + " " + new Date(depositDateFrom * 1000));
  var depositDateTo = contract.DEPOSIT_DATE_TO();
  console.log("RESULT: contract.depositDateTo=" + depositDateTo + " " + new Date(depositDateTo * 1000));
  var incentRatePerThousand = contract.INCENT_RATE_PER_THOUSAND();
  console.log("RESULT: contract.incentRatePerThousand=" + incentRatePerThousand);
  var incentAccount = contract.incentAccount();
  console.log("RESULT: contract.incentAccount=" + incentAccount);
  var feeRatePerThousand = contract.FEE_RATE_PER_THOUSAND();
  console.log("RESULT: contract.feeRatePerThousand=" + feeRatePerThousand);
  var feeAccount = contract.feeAccount();
  console.log("RESULT: contract.feeAccount=" + feeAccount);
  var clientAccount = contract.clientAccount();
  console.log("RESULT: contract.clientAccount=" + clientAccount);
}

function printContractDynamicDetails() {
  var i;
  var contract = eth.contract(contractAbi).at(contractAddress);
  var numberOfDepositContracts = contract.numberOfDepositContracts();
  console.log("RESULT: contract.numberOfDepositContracts=" + numberOfDepositContracts);
  for (i = 0; i < numberOfDepositContracts; i++) {
    console.log("RESULT: contract.depositContracts(" + i + ") " + contract.depositContracts(i))
  }
  var totalDeposits = contract.totalDeposits();
  console.log("RESULT: contract.totalDeposits=" + web3.fromWei(totalDeposits, "ether"));
  var depositContractCreatedEvent = contract.DepositContractCreated({}, { fromBlock: 0, toBlock: "latest" });
  i = 0;
  depositContractCreatedEvent.watch(function (error, result) {
    console.log("RESULT: DepositContractCreated Event " + i++ + ": " + result.args.depositContract + " " + result.args.number +
      " block " + result.blockNumber);
  });
  depositContractCreatedEvent.stopWatching();
  var depositReceivedEvent = contract.DepositReceived({}, { fromBlock: 0, toBlock: "latest" });
  i = 0;
  depositReceivedEvent.watch(function (error, result) {
    console.log("RESULT: DepositReceived Event " + i++ + ": " + result.args.depositOrigin + " " + result.args.depositContract +
      " " + web3.fromWei(result.args._value, "ether") + " ETH block " + result.blockNumber);
    // console.log("RESULT: DepositReceived Event " + i++ + ": " + JSON.stringify(result));
  });
  depositReceivedEvent.stopWatching();
}
