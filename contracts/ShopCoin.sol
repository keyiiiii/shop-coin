pragma solidity ^0.4.8;

import "./Ownable.sol";
import "./Members.sol";

/**
 * @title Member
 * @dev 会員管理機能付き仮想通貨
 */
contract ShopCoin is Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => int8) public blackList;
    mapping (address => Members) public members;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Blacklisted(address indexed target);
    event DeleteFromBlackList(address indexed target);
    event RejectedPaymentToBlacklistedAddress(address indexed from, address indexed to, uint256 value);
    event RejectedPaymentFromBlacklistedAddress(address indexed from, address indexed to, uint256 value);
    event Cashback(address indexed from, address indexed to, uint256 value);

    function ShopCoin(uint256 _supply, string _name, string _symbol, uint8 _decimals){
        balanceOf[msg.sender] = _supply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _supply;
    }

    function blacklisting(address _address) onlyOwner {
        blackList[_address] = 1;
        Blacklisted(_address);
    }

    function deleteFromBlacklist(address _address) onlyOwner {
        blackList[_address] = -1;
        DeleteFromBlackList(_address);
    }

    function setMembers(Members _members) {
        members[msg.sender] = Members(_members);
    }

    function transfer(address _to, uint256 _value) {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);

        if (blackList[msg.sender] > 0) {
            RejectedPaymentFromBlacklistedAddress(msg.sender, _to, _value);
        } else if (blackList[_to] > 0) {
            RejectedPaymentToBlacklistedAddress(msg.sender, _to, _value);
        } else {
            uint256 cashback = 0;
            if (members[_to] > address(0)) {
                cashback = _value / 100 * uint256(members[_to].getCashbackRate(msg.sender));
                members[_to].updateHistory(msg.sender, _value);
            }

            balanceOf[msg.sender] -= (_value - cashback);
            balanceOf[_to] += (_value - cashback);

            Transfer(msg.sender, _to, _value);
            Cashback(_to, msg.sender, cashback);
        }

    }
}
