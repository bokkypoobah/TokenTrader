pragma solidity ^0.4.4;

// ------------------------------------------------------------------------
// TokenTraderFactory
//
// Decentralised trustless ERC20-compliant token to ETH exchange contract
// on the Ethereum blockchain.
//
// Enjoy. (c) JonnyLatte & BokkyPooBah 2016. The MIT licence.
// ------------------------------------------------------------------------

// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function totalSupply() constant returns (uint totalSupply);
    function balanceOf(address _owner) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool success);
    function transferFrom(address _from, address _to, uint _value) returns (bool success);
    function approve(address _spender, uint _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Owned {
    address public owner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

// contract can buy or sell tokens for ETH
// prices are in amount of wei per batch of token units

contract TokenTrader is Owned {

    address public asset;       // address of token
    uint256 public buyPrice;    // contract buys lots of token at this price
    uint256 public sellPrice;   // contract sells lots at this price
    uint256 public units;       // lot size (token-wei)

    bool public sellsTokens;    // is contract selling
    bool public buysTokens;     // is contract buying

    event ActivatedEvent(bool sells, bool buys);
    event EtherDeposited(uint256 amount);
    event AssetWithdrawn(uint256 value);
    event TokenWithdrawn(address token, uint256 value);
    event EtherWithdrawn(uint256 value);
    event AssetBought(address indexed buyer, uint256 amount, uint256 value, uint256 change);
    event AssetSold(address indexed seller, uint256 amount, uint256 value);

    // Constructor
    function TokenTrader (
        address _asset,
        uint256 _buyPrice,
        uint256 _sellPrice,
        uint256 _units,
        bool    _sellsTokens,
        bool    _buysTokens
    ) {
        asset       = _asset;
        buyPrice    = _buyPrice;
        sellPrice   = _sellPrice;
        units       = _units;
        sellsTokens = _sellsTokens;
        buysTokens  = _buysTokens;
        ActivatedEvent(sellsTokens, buysTokens);
    }

    // modify trading behavior
    function activate (
        bool _sellsTokens,
        bool _buysTokens
    ) onlyOwner {
        sellsTokens = _sellsTokens;
        buysTokens  = _buysTokens;
        ActivatedEvent(sellsTokens, buysTokens);
    }

    // allows owner to deposit ETH
    // deposit tokens by sending them directly to contract
    // buyers must not send tokens to the contract, use: sell(...)
    function deposit() payable onlyOwner {
        EtherDeposited(msg.value);
    }

    // allow owner to remove trade token
    function withdrawAsset(uint256 _value) onlyOwner returns (bool ok) {
        AssetWithdrawn(_value);
        return ERC20(asset).transfer(owner, _value);
    }

    // allow owner to remove arbitrary tokens
    // included just in case contract receives wrong token
    function withdrawToken(address _token, uint256 _value) onlyOwner returns (bool ok) {
        TokenWithdrawn(_token, _value);
        return ERC20(_token).transfer(owner, _value);
    }

    // allow owner to remove ETH
    function withdraw(uint256 _value) onlyOwner returns (bool ok) {
        if (this.balance >= _value) {
            EtherWithdrawn(_value);
            return owner.send(_value);
        }
    }

    // user buys token with ETH
    function buy() payable {
        if (sellsTokens || msg.sender == owner) {
            uint order    = msg.value / sellPrice;
            uint can_sell = ERC20(asset).balanceOf(address(this)) / units;
            uint256 change = 0;
            if (order > can_sell) {
                change = msg.value - (can_sell * sellPrice);
                order = can_sell;
                if (!msg.sender.send(change)) throw;
            }
            if (order > 0) {
                if(!ERC20(asset).transfer(msg.sender, order * units)) throw;
            }
            AssetBought(msg.sender, msg.value, order * units, change);
        }
        else if (!msg.sender.send(msg.value)) throw;  // return user funds if the contract is not selling
    }

    // user sells token for ETH
    // user must set allowance for this contract before calling
    function sell(uint256 amount) {
        if (buysTokens || msg.sender == owner) {
            uint256 can_buy = this.balance / buyPrice;  // token lots contract can buy
            uint256 order = amount / units;             // token lots available
            if (order > can_buy) order = can_buy;       // adjust order for funds
            if (order > 0) {
                // extract user tokens
                if(!ERC20(asset).transferFrom(msg.sender, address(this), order * units)) throw;
                // pay user
                if(!msg.sender.send(order * buyPrice)) throw;
            }
            AssetSold(msg.sender, amount, order * buyPrice);
        }
    }

    // sending ETH to contract sells ETH to user
    function () payable {
        buy();
    }
}

// This contract deploys TokenTrader contracts and logs the event
contract TokenTraderFactory is Owned {

    event TradeListing(address owner, address addr);
    event TokenWithdrawn(address token, uint256 value);

    mapping(address => bool) _verify;

    function verify(address tradeContract) constant returns (
        bool valid,
        address asset,
        uint256 buyPrice,
        uint256 sellPrice,
        uint256 units,
        bool    sellsTokens,
        bool    buysTokens
    ) {
        valid = _verify[tradeContract];
        if (valid) {
            TokenTrader t = TokenTrader(tradeContract);
            asset       = t.asset();
            buyPrice    = t.buyPrice();
            sellPrice   = t.sellPrice();
            units       = t.units();
            sellsTokens = t.sellsTokens();
            buysTokens  = t.buysTokens();
        }
    }

    function createTradeContract(
        address _asset,
        uint256 _buyPrice,
        uint256 _sellPrice,
        uint256 _units,
        bool    _sellsTokens,
        bool    _buysTokens
    ) returns (address) {
        if (_buyPrice > _sellPrice) throw; // must make profit on spread
        if (_units == 0) throw;            // can't sell zero units
        address trader = new TokenTrader(
            _asset,
            _buyPrice,
            _sellPrice,
            _units,
            _sellsTokens,
            _buysTokens);
        _verify[trader] = true; // record that this factory created the trader
        TokenTrader(trader).transferOwnership(msg.sender); // set the owner to whoever called the function
        TradeListing(msg.sender, trader);
    }

    // allow owner to remove arbitrary tokens
    // included just in case contract receives some tokens
    function withdrawToken(address _token, uint256 _value) onlyOwner returns (bool ok) {
        TokenWithdrawn(_token, _value);
        return ERC20(_token).transfer(owner, _value);
    }

    function () {
        throw;     // Prevents accidental sending of ether to the factory
    }
}
