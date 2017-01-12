# TokenTrader
Decentralised trustless ERC20-compliant token and ETH exchange contract on the Ethereum blockchain.

There are two types of these contracts:

* **TokenTrader** - The TokenTrader contract that allows users to buy or sell ERC20-compliant tokens in a single atomic transaction. Market Makers use the **TokenTraderFactory** contract to create TokenTrader contracts.

* **TokenSeller** - A modified TokenTrader customised to handle the partial ERC20 compliance of the Golem Network Token where the `approve(...)`, `transferFrom(...)` and `allowance(...)` methods are not implemented. Market Makers use the **TokenSellerFactory** contract to create TokenSeller contracts.

See the [wiki](https://github.com/bokkypoobah/TokenTrader/wiki) for the latest information.

<br />

---

Enjoy. (c) JonnyLatte, Cintix &amp; BokkyPooBah 2016. The MIT licence.
