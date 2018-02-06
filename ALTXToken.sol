pragma solidity ^0.4.19;
import "./StandardToken.sol";
import "./Ownable.sol";

/**
 * @title ALTXToken
 * @dev Very simple ERC20 Token that can be minted.
 * It is meant to be used in a crowdsale contract.
 */
contract ALTXToken is StandardToken, Ownable {

  string public constant name = "Alttex";
  string public constant symbol = "ALTX";
  uint8 public constant decimals = 8;

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;
  address public saleAgent = address(0);

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  function setSaleAgent(address newSaleAgnet) public {
    require(msg.sender == saleAgent || msg.sender == owner);
    saleAgent = newSaleAgnet;
  }
  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) canMint public returns (bool) {
    require(msg.sender == saleAgent || msg.sender == owner);
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() canMint public returns (bool) {
    require((msg.sender == saleAgent || msg.sender == owner));
    mintingFinished = true;
    MintFinished();
    return true;
  }
}
