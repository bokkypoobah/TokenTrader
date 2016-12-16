pragma solidity ^0.4.4;

// ------------------------------------------------------------------------
// TokenSellerFactory
//
// Decentralised trustless ERC20-partially-compliant token to ETH exchange
// contract on the Ethereum blockchain.
//
// This caters for the Golem Network Token which does not implement the
// transferFrom(...), approve(...) and allowance(...) methods
//
// Enjoy. (c) JonnyLatte, Cintix & BokkyPooBah 2016. The MIT licence.
// ------------------------------------------------------------------------

// https://github.com/ethereum/EIPs/issues/20
contract ERC20Partial {
    function totalSupply() constant returns (uint totalSupply);
    function balanceOf(address _owner) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool success);
    // function transferFrom(address _from, address _to, uint _value) returns (bool success);
    // function approve(address _spender, uint _value) returns (bool success);
    // function allowance(address _owner, address _spender) constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    // event Approval(address indexed _owner, address indexed _spender, uint _value);
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

// contract can sell tokens for ETH
// prices are in amount of wei per batch of token units

contract TokenSeller is Owned {

    address public asset;       // address of token
    uint256 public sellPrice;   // contract sells lots of tokens at this price
    uint256 public units;       // lot size (token-wei)

    bool public sellsTokens;    // is contract selling

    event ActivatedEvent(bool sells);
    event AssetWithdrawn(uint256 value);
    event TokenWithdrawn(address token, uint256 value);
    event EtherWithdrawn(uint256 value);
    event AssetBought(address indexed buyer, uint256 amount, uint256 value, uint256 change);
    event AssetSold(address indexed seller, uint256 amount, uint256 value);

    // Constructor
    function TokenSeller (
        address _asset,
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
        ActivatedEvent(sellsTokens);
    }

    // modify trading behavior
    function activate (
        bool _sellsTokens
    ) onlyOwner {
        sellsTokens = _sellsTokens;
        ActivatedEvent(sellsTokens);
    }

    // allow owner to remove trade token
    function withdrawAsset(uint256 _value) onlyOwner returns (bool ok) {
        AssetWithdrawn(_value);
        return ERC20Partial(asset).transfer(owner, _value);
    }

    // allow owner to remove arbitrary tokens
    // included just in case contract receives wrong token
    function withdrawToken(address _token, uint256 _value) onlyOwner returns (bool ok) {
        TokenWithdrawn(_token, _value);
        return ERC20Partial(_token).transfer(owner, _value);
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
            uint can_sell = ERC20Partial(asset).balanceOf(address(this)) / units;
            uint256 change = 0;
            if (order > can_sell) {
                change = msg.value - (can_sell * sellPrice);
                order = can_sell;
                if (!msg.sender.send(change)) throw;
            }
            if (order > 0) {
                if(!ERC20Partial(asset).transfer(msg.sender, order * units)) throw;
            }
            AssetBought(msg.sender, msg.value, order * units, change);
        }
        else if (!msg.sender.send(msg.value)) throw;  // return user funds if the contract is not selling
    }

    // sending ETH to contract sells tokens to user
    function () payable {
        buy();
    }
}

// This contract deploys TokenSeller contracts and logs the event
contract TokenSellerFactory is Owned {

    event TradeListing(address owner, address addr);
    event TokenWithdrawn(address token, uint256 value);

    mapping(address => bool) _verify;

    function verify(address tradeContract) constant returns (
        bool valid,
        address asset,
        uint256 sellPrice,
        uint256 units,
        bool    sellsTokens
    ) {
        valid = _verify[tradeContract];
        if (valid) {
            TokenSeller t = TokenSeller(tradeContract);
            asset       = t.asset();
            sellPrice   = t.sellPrice();
            units       = t.units();
            sellsTokens = t.sellsTokens();
        }
    }

    function createTradeContract(
        address _asset,
        uint256 _sellPrice,
        uint256 _units,
        bool    _sellsTokens
    ) returns (address) {
        if (_units == 0) throw;            // can't sell zero units
        address trader = new TokenSeller(
            _asset,
            _sellPrice,
            _units,
            _sellsTokens);
        _verify[trader] = true; // record that this factory created the trader
        TokenSeller(trader).transferOwnership(msg.sender); // set the owner to whoever called the function
        TradeListing(msg.sender, trader);
    }

    // allow owner to remove arbitrary tokens
    // included just in case contract receives some tokens
    function withdrawToken(address _token, uint256 _value) onlyOwner returns (bool ok) {
        TokenWithdrawn(_token, _value);
        return ERC20Partial(_token).transfer(owner, _value);
    }

    function () {
        throw;     // Prevents accidental sending of ether to the factory
    }
}
