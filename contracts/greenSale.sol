pragma solidity ^0.4.23;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  pragma solidity ^0.4.23;


contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
    constructor() public {
        owner = msg.sender;
    }

  /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

    /**
    * @title ERC20Basic
    * @dev Simpler version of ERC20 interface
    * @dev see https://github.com/ethereum/EIPs/issues/179
    */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


    /**
    * @title ERC20 interface
    * @dev see https://github.com/ethereum/EIPs/issues/20
    */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 value
    )
        internal
    {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        require(token.approve(spender, value));
    }
}

    /**
    * @title Crowdsale
    * @dev Crowdsale is a base contract for managing a token crowdsale,
    * allowing investors to purchase tokens with ether. This contract implements
    * such functionality in its most fundamental form and can be extended to provide additional
    * functionality and/or custom behavior.
    * The external interface represents the basic interface for purchasing tokens, and conform
    * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
    * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
    * the methods to add functionality. Consider using 'super' where appropiate to concatenate
    * behavior.
    */
contract Crowdsale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    // The token being sold
    ERC20 public token;

    // Address where funds are collected
    address public wallet;

    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
    // 1 wei will give you 1 unit, or 0.001 TOK.
    uint256 public rate;

    // Amount of wei raised
    uint256 public weiRaised;

    function setRate(uint _rate) public onlyOwner {
        rate = _rate;
    }
    /**
    * Event for token purchase logging
    * @param purchaser who paid for the tokens
    * @param beneficiary who got the tokens
    * @param value weis paid for purchase
    * @param amount amount of tokens purchased
    */
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    /**
    * @param _rate Number of token units a buyer gets per wei
    * @param _wallet Address where collected funds will be forwarded to
    * @param _token Address of the token being sold
    */
    constructor(uint256 _rate, address _wallet, ERC20 _token) public {
        require(_rate > 0);
        require(_wallet != address(0));
        require(_token != address(0));

        rate = _rate;
        wallet = _wallet;
        token = _token;
    }

    // -----------------------------------------
    // Crowdsale external interface
    // -----------------------------------------

    /**
    * @dev fallback function ***DO NOT OVERRIDE***
    */
    function () external payable {
        buyTokens(msg.sender);
    }

    /**
    * @dev low level token purchase ***DO NOT OVERRIDE***
    * @param _beneficiary Address performing the token purchase
    */
    function buyTokens(address _beneficiary) public payable {

        uint256 ethAmount = msg.value;
        //만약 2000이더가 넘을 경우 곱하기 116%를 해준다.
        if (ethAmount >= SafeMath.mul(40 ,1 ether)) {
            ethAmount = ethAmount.mul(116);
            ethAmount = ethAmount.div(100);
        //만약 1500이더가 넘을 경우 곱하기 112%를 해준다.
        } else if (ethAmount >= SafeMath.mul(30, 1 ether)) {
            ethAmount = ethAmount.mul(112);
            ethAmount = ethAmount.div(100);
        //만약 1000이더가 넘을 경우 곱하기 108%를 해준다.
        } else if (ethAmount >= SafeMath.mul(20, 1 ether)) {
            ethAmount = ethAmount.mul(108);
            ethAmount = ethAmount.div(100);
        //만약 500이더가 넘을 경우 곱하기 104%를 해준다.
        } else if (ethAmount >= SafeMath.mul(10, 1 ether)) {
            ethAmount = ethAmount.mul(104);
            ethAmount = ethAmount.div(100);
        }
        
        //_preValidatePurchase(_beneficiary, ethAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(ethAmount);

        // update state
        weiRaised = weiRaised.add(ethAmount);

        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(
            msg.sender,
            _beneficiary,
            ethAmount,
            tokens
        );

        //_updatePurchasingState(_beneficiary, ethAmount);

        _forwardFunds();
        //_postValidatePurchase(_beneficiary, ethAmount);
    }

    // -----------------------------------------
    // Internal interface (extensible)
    // -----------------------------------------

    /**
    * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
    * @param _beneficiary Address performing the token purchase
    * @param _ethAmount Value in wei involved in the purchase
    
    function _preValidatePurchase(
        address _beneficiary,
        uint256 _ethAmount
    )
        internal
    {
        require(_beneficiary != address(0));
        require(_ethAmount != 0);
    }
    */

    /**
    * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
    * @param _beneficiary Address performing the token purchase
    * @param _ethAmount Value in wei involved in the purchase
    
    function _postValidatePurchase(
        address _beneficiary,
        uint256 _ethAmount
    )
        internal
    {
        // optional override
    }
    */

    /**
    * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
    * @param _beneficiary Address performing the token purchase
    * @param _tokenAmount Number of tokens to be emitted
    */
    function _deliverTokens(
        address _beneficiary,
        uint256 _tokenAmount
    )
        internal
    {
        token.safeTransfer(_beneficiary, _tokenAmount);
    }

    /**
    * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
    * @param _beneficiary Address receiving the tokens
    * @param _tokenAmount Number of tokens to be purchased
    */
    function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount
    )
        internal
    {
        _deliverTokens(_beneficiary, _tokenAmount);
    }


    /**
    * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
    * @param _beneficiary Address receiving the tokens
    * @param _ethAmount Value in wei involved in the purchase
    
    function _updatePurchasingState(
        address _beneficiary,
        uint256 _ethAmount
    )
        internal
    {
        // optional override
    }*/


    /**
    * @dev Override to extend the way in which ether is converted to tokens.
    * @param _ethAmount Value in wei to be converted into tokens
    * @return Number of tokens that can be purchased with the specified _ethAmount
    */
    function _getTokenAmount(uint256 _ethAmount)
        internal view returns (uint256)
    {
        return _ethAmount.mul(rate);
    }

    /**
    * @dev Determines how ETH is stored/forwarded on purchases.
    */
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }
}
