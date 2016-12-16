# TokenTrader
Decentralised trustless exchange contract on the Ethereum blockchain.

## Original TokenTraderFactory Source

### TokenTraderFactory
This repository contains the excellent REP [TokenTraderFactory](https://github.com/bokkypoobah/TokenTrader/blob/master/contracts/TokenTraderFactory.sol) that was originally written by [/u/JonnyLatte](https://www.reddit.com/user/JonnyLatte) at [0x3398080b81a1cff1429af347ce2b17fc28de3937](https://etherscan.io/address/0x3398080b81a1cff1429af347ce2b17fc28de3937#code). 

**Note that there is a bug in the original version in the `sell(...)` method that could lead to some losses in ethers.** Use of this contract has been / should be discontinued. See [TokenTrader error found in sell logic (unsafe to sell tokens to my trade contracts)](https://www.reddit.com/r/reptrader/comments/5i3wrt/tokentrader_error_found_in_sell_logic_unsafe_to/).

Some further information on this contract can be found at [Live testing ETH <-> Token, Atomic swap market](https://www.reddit.com/r/ethtrader/comments/56ajll/live_testing_eth_token_atomic_swap_market/).

### TokenSellerFactory (SellOnly GNT TokenTraderFactory)
This repository also contains the SellOnly GNT TokenTraderFactory, renamed to [TokenSellerFactory](https://github.com/bokkypoobah/TokenTrader/blob/master/contracts/TokenSellerFactory.sol) that was the original REP TokenTraderFactory modified by [/u/Cintix](https://www.reddit.com/user/cintix) at [0xc4af56cd5254aef959d4bce2f75874007808b701](https://etherscan.io/address/0xc4af56cd5254aef959d4bce2f75874007808b701#code). The bug from the original REP TokenTraderFactory does not exist in this TokenSellerFactory. 

Some further information can be found at [The Decentralized GNT/ETH Market](https://www.reddit.com/r/ethtrader/comments/5d455f/the_decentralized_gnteth_market/) and [Trustless Golem Network Token (GNT) Selling Contract](https://www.bokconsulting.com.au/blog/trustless-token-selling-contract/).



Enjoy. (c) JonnyLatte, Cintix &amp; BokkyPooBah 2016. The MIT licence.
