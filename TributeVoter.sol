  pragma solidity ^0.5.16;

  interface IERC20 {
      // Views
      function totalSupply() external view returns (uint);
      function balanceOf(address owner) external view returns (uint);
      function allowance(address owner, address spender) external view returns (uint);

      // Mutative functions
      function transfer(address to, uint value) external returns (bool);
      function approve(address spender, uint value) external returns (bool);
      function transferFrom(
          address from,
          address to,
          uint value
      ) external returns (bool);

      // Events
      event Transfer(address indexed from, address indexed to, uint value);
      event Approval(address indexed owner, address indexed spender, uint value);
  }

  library SafeMath {
      function add(uint a, uint b) internal pure returns (uint) {
          uint c = a + b;
          require(c >= a, "SafeMath: addition overflow");

          return c;
      }
      function sub(uint a, uint b) internal pure returns (uint) {
          return sub(a, b, "SafeMath: subtraction overflow");
      }
      function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
          require(b <= a, errorMessage);
          uint c = a - b;

          return c;
      }
      function mul(uint a, uint b) internal pure returns (uint) {
          if (a == 0) {
              return 0;
          }

          uint c = a * b;
          require(c / a == b, "SafeMath: multiplication overflow");

          return c;
      }
      function div(uint a, uint b) internal pure returns (uint) {
          return div(a, b, "SafeMath: division by zero");
      }
      function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
          // Solidity only automatically asserts when dividing by 0
          require(b > 0, errorMessage);
          uint c = a / b;

          return c;
      }
  }

  contract Context {
      constructor () internal { }
      // solhint-disable-previous-line no-empty-blocks

      function _msgSender() internal view returns (address payable) {
          return msg.sender;
      }
  }

  contract ERC20 is Context, IERC20 {
      using SafeMath for uint256;

      mapping (address => uint256) private _balances;
      mapping (address => mapping (address => uint256)) private _allowances;
      uint256 private _totalSupply;


      function totalSupply() public view returns (uint256) {
          return _totalSupply;
      }

      function balanceOf(address account) public view returns (uint256) {
          return _balances[account];
      }

      function transfer(address recipient, uint256 amount) public returns (bool) {
          _transfer(msg.sender, recipient, amount);
          return true;
      }

      function allowance(address owner, address spender) public view returns (uint256) {
          return _allowances[owner][spender];
      }

      function approve(address spender, uint256 value) public returns (bool) {
          _approve(msg.sender, spender, value);
          return true;
      }

      function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
          _transfer(sender, recipient, amount);
          _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
          return true;
      }

      function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
          _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
          return true;
      }

      function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
          _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
          return true;
      }

      function _transfer(address sender, address recipient, uint256 amount) internal {
          require(sender != address(0), "ERC20: transfer from the zero address");
          require(recipient != address(0), "ERC20: transfer to the zero address");

          _balances[sender] = _balances[sender].sub(amount);
          _balances[recipient] = _balances[recipient].add(amount);
          emit Transfer(sender, recipient, amount);
      }

      function _mint(address account, uint256 amount) internal {
          require(account != address(0), "ERC20: mint to the zero address");

          _totalSupply = _totalSupply.add(amount);
          _balances[account] = _balances[account].add(amount);
          emit Transfer(address(0), account, amount);
      }

      function _burn(address account, uint256 value) internal {
          require(account != address(0), "ERC20: burn from the zero address");

          _totalSupply = _totalSupply.sub(value);
          _balances[account] = _balances[account].sub(value);
          emit Transfer(account, address(0), value);
      }

      function _approve(address owner, address spender, uint256 value) internal {
          require(owner != address(0), "ERC20: approve from the zero address");
          require(spender != address(0), "ERC20: approve to the zero address");

          _allowances[owner][spender] = value;
          emit Approval(owner, spender, value);
      }

      function _burnFrom(address account, uint256 amount) internal {
          _burn(account, amount);
          _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
      }
  }

  contract ERC20Detailed is IERC20 {
      string private _name;
      string private _symbol;
      uint8 private _decimals;

      constructor (string memory name, string memory symbol, uint8 decimals) public {
          _name = name;
          _symbol = symbol;
          _decimals = decimals;
      }

      function name() public view returns (string memory) {
          return _name;
      }

      function symbol() public view returns (string memory) {
          return _symbol;
      }

      function decimals() public view returns (uint8) {
          return _decimals;
      }
  }

  library Address {
      function isContract(address account) internal view returns (bool) {
          bytes32 codehash;
          bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
          // solhint-disable-next-line no-inline-assembly
          assembly { codehash := extcodehash(account) }
          return (codehash != 0x0 && codehash != accountHash);
      }
  }

  library SafeERC20 {
      using SafeMath for uint;
      using Address for address;

      function safeTransfer(IERC20 token, address to, uint value) internal {
          callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
      }

      function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
          callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
      }

      function safeApprove(IERC20 token, address spender, uint value) internal {
          require((value == 0) || (token.allowance(address(this), spender) == 0),
              "SafeERC20: approve from non-zero to non-zero allowance"
          );
          callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
      }
      function callOptionalReturn(IERC20 token, bytes memory data) private {
          require(address(token).isContract(), "SafeERC20: call to non-contract");

          // solhint-disable-next-line avoid-low-level-calls
          (bool success, bytes memory returndata) = address(token).call(data);
          require(success, "SafeERC20: low-level call failed");

          if (returndata.length > 0) { // Return data is optional
              // solhint-disable-next-line max-line-length
              require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
          }
      }
  }
  
  contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

  contract VitaToken is ERC20, ERC20Detailed, Ownable {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

  mapping (address => bool) public minters;

  constructor () public ERC20Detailed("Tribute Voter", "TVOTER", 18) {
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
