//pragma solidity ^0.4.20;
pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract WRCToken {
  function totalSupply()public view returns (uint total_Supply);
  function balanceOf(address who)public view returns (uint256);
  function allowance(address owner, address spender)public view returns (uint);
  function transferFrom(address from, address to, uint value)public returns (bool ok);
  function approve(address spender, uint value)public returns (bool ok);
  function transfer(address to, uint value)public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


contract CLASS is WRCToken
{
   using SafeMath for uint256;
    // Name of the token
    string public constant name = "CLASS";

    // Symbol of token
    string public constant symbol = "WRC";
    uint8 public constant decimals = 18;
    uint public _totalsupply = 2500000000 *10 ** 18; // 2.5 Billion CLS Coins
    address public owner;
    uint256 constant public _price_tokn = 20000 ;
    uint256 no_of_tokens;
    uint256 bonus_token;
    uint256 total_token;
    bool stopped = false;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    address ethFundMain = 0x67CFF9a14EA16e6D8c2f230d1bFf99A805726e57; // needs to be changed
    uint256 public Numtokens;
    uint256 public bonustokn;
    uint256 public ethreceived;
    uint bonusCalculationFactor;
    uint public bonus;
    uint x ;

  modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }


    function WRCCoin() public
    {
        owner = msg.sender;
        balances[owner] = 1250000000 *10 ** 18;  // 1.25 billion given to owner
        emit Transfer(address(this), owner, balances[owner]);
    }

    function () external payable
    {
      //  require(stage != Stages.ENDED);
        require(msg.sender != owner);

            no_of_tokens =(msg.value).mul(_price_tokn);
            ethreceived = ethreceived.add(msg.value);
            total_token = no_of_tokens;
            Numtokens= Numtokens.add(no_of_tokens);
             bonustokn= bonustokn.add(bonus_token);
            transferTokens(msg.sender,total_token);
  }


    //bonuc calculation
    //bonus calculation for ICO on purchase basis

  
    // what is the total supply of the ech tokens
     function totalSupply() public view returns (uint256 total_Supply) {
         total_Supply = _totalsupply;
     }

    // What is the balance of a particular account?
     function balanceOf(address _owner)public view returns (uint256 balance) {
         return balances[_owner];
     }

    // Send _value amount of tokens from address _from to address _to
     // The transferFrom method is used for a withdraw workflow, allowing contracts to send
     // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
     // fees in sub-currencies; the command should fail unless the _from account has
     // deliberately authorized the sender of the message via some mechanism; we propose
     // these standardized APIs for approval:
     function transferFrom( address _from, address _to, uint256 _amount ) public returns (bool success) {
             require( _to != address(0));
             require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);
             balances[_from] = (balances[_from]).sub(_amount);
             allowed[_from][msg.sender] = (allowed[_from][msg.sender]).sub(_amount);
             balances[_to] = (balances[_to]).add(_amount);
             emit Transfer(_from, _to, _amount); //wasim
             return true;
         }

   // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
     // If this function is called again it overwrites the current allowance with _value.
     function approve(address _spender, uint256 _amount)public returns (bool success) {
          require( _spender != address(0));
         allowed[msg.sender][_spender] = _amount;
         emit Approval(msg.sender, _spender, _amount); //wasim
         return true;
     }

     function allowance(address _owner, address _spender)public view returns (uint256 remaining) {
         require( _owner != address(0) && _spender !=address(0));
         return allowed[_owner][_spender];
   }

    // Transfer the balance from owner's account to another account
     function transfer(address _to, uint256 _amount) public returns (bool success) {
         if(msg.sender == owner)
         {
            require(balances[owner] >= _amount && _amount >= 0 && balances[_to] + _amount > balances[_to]);
            balances[owner] = (balances[owner]).sub(_amount);
            balances[_to] = (balances[_to]).add(_amount);
            emit Transfer(owner, _to, _amount); //wasim
            return true;
         }

        else
         revert();
     }


          // Transfer the balance from owner's account to another account
    function transferTokens(address _to, uint256 _amount) private returns(bool success) {
            require( _to != address(0));
            require(balances[address(this)] >= _amount && _amount > 0);
            balances[address(this)] = (balances[address(this)]).sub(_amount);
            balances[_to] = (balances[_to]).add(_amount);
            emit Transfer(address(this), _to, _amount);
            return true;
        }

        function transferby(address _to,uint256 _amount) external onlyOwner returns(bool success) {
              require( _to != address(0));
              require(balances[address(this)] >= _amount && _amount > 0);
              balances[address(this)] = (balances[address(this)]).sub(_amount);
              balances[_to] = (balances[_to]).add(_amount);
              emit Transfer(address(this), _to, _amount);
              return true;
        }


    	//In case the ownership needs to be transferred
    	function transferOwnership(address newOwner)public onlyOwner
    	{
    	    balances[newOwner] = (balances[newOwner]).add(balances[owner]);
    	    balances[owner] = 0;
    	    owner = newOwner;
    	}




}
