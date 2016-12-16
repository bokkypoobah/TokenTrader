# TokenTrader
Decentralised Trustless Exchange Contract

This repository contains the REP [TokenTraderFactory](https://github.com/bokkypoobah/TokenTrader/blob/master/contracts/TokenTraderFactory.sol) that was originally written by [/u/JonnyLatte](https://www.reddit.com/user/JonnyLatte) at [0x3398080b81a1cff1429af347ce2b17fc28de3937](https://etherscan.io/address/0x3398080b81a1cff1429af347ce2b17fc28de3937#code). There is a bug in the original version in the `sell(...)` method that could lead to some losses in ethers.

This repository also contains the SellOnly GNT TokenTraderFactory, renamed to [TokenSellerFactory](https://github.com/bokkypoobah/TokenTrader/blob/master/contracts/TokenSellerFactory.sol) that was the original REP TokenTraderFactory modified by [/u/Cintix](https://www.reddit.com/user/cintix) at [0xc4af56cd5254aef959d4bce2f75874007808b701](https://etherscan.io/address/0xc4af56cd5254aef959d4bce2f75874007808b701#code). The bug from the original REP TokenTraderFactory does not exist in this TokenSellerFactory.

Enjoy. (c) JonnyLatte, Cintix &amp; BokkyPooBah 2016. The MIT licence (I am still checking with the other authors on this).
