pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

  contract TributeVoter is ERC20, Ownable {
    using SafeMath for uint;

  mapping (address => bool) public minters;

    constructor()
        public
        ERC20("TributeVoter", "TVOTER")
    {
        addMinter(msg.sender);
        mint(msg.sender, 100000000000000000000000);
  }
 
  function mint(address account, uint256 amount) public {
      require(minters[msg.sender], "!minter");
      _mint(account, amount);
  }
 
  function addMinter(address _minter) public onlyOwner {
      minters[_minter] = true;
  }

  function removeMinter(address _minter) public onlyOwner {
      minters[_minter] = false;
  }
  
  }
