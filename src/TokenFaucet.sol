pragma solidity >=0.5.0;

import "./lib.sol";

interface ERC20Like {
    function balanceOf(address) external view returns (uint256);
    function transfer(address,uint256) external; // return bool?
}

contract TokenFaucet is DSNote {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) public auth note { wards[guy] = 1; }
    function deny(address guy) public auth note { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    uint256 public amt;
    mapping (address => mapping (address => bool)) public done;

    constructor (uint256 amt_) public {
        wards[msg.sender] = 1;
        amt = amt_;
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function gulp(address gem) external {
        require(!done[msg.sender][address(gem)], "token-faucet: already used faucet");
        require(ERC20Like(gem).balanceOf(address(this)) >= amt, "token-faucet: not enough balance");
        done[msg.sender][address(gem)] = true;
        ERC20Like(gem).transfer(msg.sender, amt);
    }

    function gulp(address gem, address[] calldata addrs) external {
        require(ERC20Like(gem).balanceOf(address(this)) >= mul(amt, addrs.length), "token-faucet: not enough balance");

        for (uint i = 0; i < addrs.length; i++) {
            require(!done[addrs[i]][address(gem)], "token-faucet: already used faucet");
            done[addrs[i]][address(gem)] = true;
            ERC20Like(gem).transfer(addrs[i], amt);
        }
    }

    function shut(ERC20Like gem) external auth {
        gem.transfer(msg.sender, gem.balanceOf(address(this)));
    }

    function setamt(uint256 amt_) external auth note {
        amt = amt_;
    }
}
