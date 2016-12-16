# TokenTrader
Decentralised trustless ERC20-compliant token to ETH exchange contract on the Ethereum blockchain.

There are two types of these contracts:

* **TokenTraderFactory** - The original REP TokenTraderFactory that will allow users to buy or sell ERC20-compliant tokens

* **TokenSellerFactory** - A modified TokenTraderFactory customised to handle the partial ERC20 compliance of the Golem Network Token where the `approve(...)`, `transferFrom(...)` and `allowance(...)` methods are not implemented.

---

## TokenTraderFactory

This repository contains the excellent REP [TokenTraderFactory](https://github.com/bokkypoobah/TokenTrader/blob/master/contracts/TokenTraderFactory.sol) that was originally written by [/u/JonnyLatte](https://www.reddit.com/user/JonnyLatte) and deployed at [0x3398080b81a1cff1429af347ce2b17fc28de3937](https://etherscan.io/address/0x3398080b81a1cff1429af347ce2b17fc28de3937#code). 

**Note that there is a bug in the original version in the `sell(...)` method that could lead to some losses in ethers.** Use of the first commited version of this contract has been / should be discontinued. See [TokenTrader error found in sell logic (unsafe to sell tokens to my trade contracts)](https://www.reddit.com/r/reptrader/comments/5i3wrt/tokentrader_error_found_in_sell_logic_unsafe_to/). 

**The latest committed version of this contract no longer contains this bug.**

Some further information on this contract can be found at [Live testing ETH <-> Token, Atomic swap market](https://www.reddit.com/r/ethtrader/comments/56ajll/live_testing_eth_token_atomic_swap_market/).

<br />

---

## TokenSellerFactory (Renamed From The SellOnly GNT TokenTraderFactory)

This repository also contains the SellOnly GNT TokenTraderFactory, renamed to [TokenSellerFactory](https://github.com/bokkypoobah/TokenTrader/blob/master/contracts/TokenSellerFactory.sol) that was the original REP TokenTraderFactory modified by [/u/Cintix](https://www.reddit.com/user/cintix) at [0xc4af56cd5254aef959d4bce2f75874007808b701](https://etherscan.io/address/0xc4af56cd5254aef959d4bce2f75874007808b701#code). The difference in this contract from the original REP TokenTraderFactory is that the `sell(...)` method has been removed as the partial ERC20 compliance of the GNT Token does not support the selling of these tokens. 

The bug from the original REP TokenTraderFactory does not exist in this TokenSellerFactory. 

Some further information can be found at [The Decentralized GNT/ETH Market](https://www.reddit.com/r/ethtrader/comments/5d455f/the_decentralized_gnteth_market/) and [Trustless Golem Network Token (GNT) Selling Contract](https://www.bokconsulting.com.au/blog/trustless-token-selling-contract/).

<br />

---

## TokenTrader And TokenSeller Bug Bounty Program

Once I have completed my testing and deployed these contracts onto Mainnet, I'll personally offer a bug bounty (not a very large amount as I don't have too much spare funds), but you will get ALL the kudos!


<br />

---

## Outstanding Actions

* Complete my testing.

* Document usage of the contracts on the [Wiki](https://github.com/bokkypoobah/TokenTrader/wiki).

* Deploy on Mainnet, announce the bounty program.

* Rewrite https://cryptoderivatives.market to use the new contracts.

* Rewrite https://github.com/bokkypoobah/FindGNTTokenTrader to list the new contracts.

<br />

Enjoy. (c) JonnyLatte, Cintix &amp; BokkyPooBah 2016. The MIT licence.
