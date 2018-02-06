pragma solidity ^0.4.19;
import "./SafeMath.sol";
import "./Ownable.sol";

contract ALTXTokenSale is Ownable {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  // The token being sold
  ALTXToken public token;

  // address where funds are collected
  address public wallet;
  uint256 public startTime = 1520035200;
  uint256 discountValue;
  uint256 discountStage1 = 30;
  uint256 discountStage2 = 20;
  uint256 discountStage3 = 10;
  // how many token units a buyer gets per wei
  uint256 public rate;
  // amount of raised money in wei
  uint256 public weiRaised;
  
  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function ALTXTokenSale(
    uint256 _rate,
    address _wallet) public {
    require(_rate > 0);
    require(_wallet != address(0));

    token = createTokenContract();
    rate = _rate;
    wallet = _wallet;
    token.setSaleAgent(owner);
  }

  // creates the token to be sold.
  function createTokenContract() internal returns (ALTXToken) {
    return new ALTXToken();
  }

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    if(now < startTime + 7 days) {
        discountValue = discountStage1;
      } else if(now >= startTime + 7 days && now < startTime + 21 days) {
        discountValue = discountStage2;
      } else if(now >= startTime + 21 days && now < startTime + 28 days) {
        discountValue = discountStage3;
      } else {
        discountValue = 0;
      }

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 all = 100;
    uint256 tokens;
    // calculate token amount to be created
    tokens = weiAmount.mul(rate).mul(100).div(all.sub(discountValue));
    
    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }
  
  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  function setWallet(address _wallet) public onlyOwner {
    wallet = _wallet;
  }

  function setRate(uint _newRate) public onlyOwner  {
    rate = _newRate;
  }
}
