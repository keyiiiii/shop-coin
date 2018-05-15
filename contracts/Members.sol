pragma solidity ^0.4.8;

import "./Ownable.sol";

/**
 * @title Members
 * @dev 会員管理用コントラクト
 */
contract Members is Ownable {
    address public coin;
    MemberStatus[] public status;
    mapping(address => History) public tradingHistory;

    struct MemberStatus {
        string name;
        uint256 times;
        uint256 sum;
        int8 rate;
    }

    struct History {
        uint256 times;
        uint256 sum;
        uint256 statusIndex;
    }

    modifier onlyCoin() {
        require(msg.sender == coin);
        _;
    }

    function setCoin(address _address) onlyOwner {
        coin = _address;
    }

    function pushStatus(string _name, uint256 _times, uint256 _sum, int8 _rate) onlyOwner {
        status.push(MemberStatus({
            name : _name,
            times: _times,
            sum: _sum,
            rate: _rate
        }));
    }

    function editStatus(uint256 _index, string _name, uint256 _times, uint256 _sum, int8 _rate) onlyOwner {
        if (_index < status.length) {
            status[_index].name = _name;
            status[_index].times = _times;
            status[_index].sum = _sum;
            status[_index].rate = _rate;
        }
    }

    function updateHistory(address _member, uint256 _value) onlyCoin {
        tradingHistory[_member].times += 1;
        tradingHistory[_member].sum += _value;
        uint256 index;
        int8 tmprate;
        for (uint i = 0; i < status.length; i++) {
            if (tradingHistory[_member].times >= status[i].times &&
            tradingHistory[_member].sum >= status[i].sum &&
            tmprate < status[i].rate) {
                index = i;
            }
        }
        tradingHistory[_member].statusIndex = index;
    }

    function getCashbackRate(address _member) constant returns (int8 rate) {
        rate = status[tradingHistory[_member].statusIndex].rate;
    }

}
