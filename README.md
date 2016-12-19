# TokenTrader
Decentralised trustless ERC20-compliant token to ETH exchange contract on the Ethereum blockchain.

There are two types of these contracts:

* **TokenTrader** - The original REP TokenTrader that allows users to buy or sell ERC20-compliant tokens

* **TokenSeller** - A modified TokenTrader customised to handle the partial ERC20 compliance of the Golem Network Token where the `approve(...)`, `transferFrom(...)` and `allowance(...)` methods are not implemented.

See the [wiki](https://github.com/bokkypoobah/TokenTrader/wiki) for further information.

---

## TokenTrader

This repository contains the excellent REP [TokenTraderFactory](https://github.com/bokkypoobah/TokenTrader/blob/master/contracts/TokenTraderFactory.sol) that was originally written by [/u/JonnyLatte](https://www.reddit.com/user/JonnyLatte) and deployed at [0x3398080b81a1cff1429af347ce2b17fc28de3937](https://etherscan.io/address/0x3398080b81a1cff1429af347ce2b17fc28de3937#code). The source code file for this version is available at [TokenTraderFactory.sol](https://github.com/bokkypoobah/TokenTrader/blob/b94177d99cf4f3caaa89d172d033c6632a00aae3/contracts/TokenTraderFactory.sol): 

**Note that there is a bug in the original version in the `sell(...)` method that could lead to some losses in ethers.** Use of the first commited version of this contract has been / should be discontinued. See [TokenTrader error found in sell logic (unsafe to sell tokens to my trade contracts)](https://www.reddit.com/r/reptrader/comments/5i3wrt/tokentrader_error_found_in_sell_logic_unsafe_to/). 

**The latest committed version of this contract no longer contains this bug.** 

This TokenTraderFactory contract has been deployed to [0x5a4fc44325aa235b81ad60c60444f515fd418436](https://etherscan.io/address/0x5a4fc44325aa235b81ad60c60444f515fd418436#code). The source code file for this version is available at [TokenTraderFactory.sol](https://github.com/bokkypoobah/TokenTrader/blob/8d09323695fea1f7bd0e571edc0b6aa8d59ad601/contracts/TokenTraderFactory.sol)

Some further information on this contract can be found at [Live testing ETH <-> Token, Atomic swap market](https://www.reddit.com/r/ethtrader/comments/56ajll/live_testing_eth_token_atomic_swap_market/).

<br />

---

## TokenSeller (Renamed From The SellOnly GNT TokenTrader)

This repository also contains the SellOnly GNT TokenTraderFactory, renamed to [TokenSellerFactory](https://github.com/bokkypoobah/TokenTrader/blob/master/contracts/TokenSellerFactory.sol) that was the original REP TokenTraderFactory modified by [/u/Cintix](https://www.reddit.com/user/cintix) at [0xc4af56cd5254aef959d4bce2f75874007808b701](https://etherscan.io/address/0xc4af56cd5254aef959d4bce2f75874007808b701#code). The difference in this contract from the original REP TokenTraderFactory is that the `sell(...)` method has been removed as the partial ERC20 compliance of the GNT Token does not support the selling of these tokens.  The source code file for this version is available at [TokenSellerFactory.sol](https://github.com/bokkypoobah/TokenTrader/blob/3d5b4d69ad1be5816fd39b74bd0a40e7c31a2de0/contracts/TokenSellerFactory). 

The bug from the original REP TokenTraderFactory does not exist in this TokenSellerFactory. 

Some further information can be found at [The Decentralized GNT/ETH Market](https://www.reddit.com/r/ethtrader/comments/5d455f/the_decentralized_gnteth_market/) and [Trustless Golem Network Token (GNT) Selling Contract](https://www.bokconsulting.com.au/blog/trustless-token-selling-contract/).

The TokenSellerFactory contract has been deployed to [0x74c2a14172cf17e8e9afcb32bb1517c4d8f3bb43](https://etherscan.io/address/0x74c2a14172cf17e8e9afcb32bb1517c4d8f3bb43#code). The source code file for this version is available at [TokenSellerFactory.sol](https://github.com/bokkypoobah/TokenTrader/blob/8d09323695fea1f7bd0e571edc0b6aa8d59ad601/contracts/TokenSellerFactory.sol)

<br />

---

## TokenTrader And TokenSeller Bug Bounty Program

Once I have completed my testing and deployed these contracts onto Mainnet, I'll personally offer a bug bounty (not a very large amount as I don't have too much spare funds), but you will get ALL the kudos!


<br />

---

## Outstanding Actions

* COMPLETED - Complete my testing. See [Testing Results ‐ Dec 19 2016 15:51](https://github.com/bokkypoobah/TokenTrader/wiki/Testing-Results-%E2%80%90-Dec-19-2016-15:51)

* IN PROGRESS - Document usage of the contracts on the [Wiki](https://github.com/bokkypoobah/TokenTrader/wiki).

* COMPLETED - Deploy on Mainnet with verified source:
  * TokenTraderFactory at [0x5a4fc44325aa235b81ad60c60444f515fd418436](https://etherscan.io/address/0x5a4fc44325aa235b81ad60c60444f515fd418436#code). 
  * TokenSellerFactory at [0x74c2a14172cf17e8e9afcb32bb1517c4d8f3bb43](https://etherscan.io/address/0x74c2a14172cf17e8e9afcb32bb1517c4d8f3bb43#code).

* Announce the bounty program.

* Rewrite https://cryptoderivatives.market to use the new contracts.

* Rewrite https://github.com/bokkypoobah/FindGNTTokenTrader to list the new contracts.

<br />

Enjoy. (c) JonnyLatte, Cintix &amp; BokkyPooBah 2016. The MIT licence.
