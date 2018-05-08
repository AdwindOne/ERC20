pragma solidity ^0.4.16;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


//Base class of token-owner
contract Ownable {
	address public owner;														//owner's address

	function Ownable() public 
	{
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}
	/*
	*	Funtion: Transfer owner's authority 
	*	Type:Public and onlyOwner
	*	Parameters:
			@newOwner:	address of newOwner
	*/
	function transferOwnership(address newOwner) onlyOwner public{
		if (newOwner != address(0)) {
		owner = newOwner;
		}
	}
	
	function kill() onlyOwner public{
		selfdestruct(owner);
	}
}

//Announcement of an interface for recipient approving
interface tokenRecipient { 
	function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData)public; 
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}
contract ShareXERC20 is Pausable{
	
	//===================public variables definition start==================
    string public name;															//Name of your Token
    string public symbol;														//Symbol of your Token
    uint8 public decimals;														//Decimals of your Token
    uint256 public totalSupply;													//Maximum amount of Token supplies
    using SafeMath for uint256;
    //define dictionaries of balance
    mapping (address => uint256) public balanceOf;								//Announce the dictionary of account's balance
    mapping (address => mapping (address => uint256)) public allowance;			//Announce the dictionary of account's available balance
	//===================public variables definition end==================

	
	//===================events definition start==================    
    event Transfer(address indexed from, address indexed to, uint256 value);	//Event on blockchain which notify client
	//===================events definition end==================
	
	
	//===================Contract Initialization Sequence Definition start===================
    function ShareXERC20 () public {
		decimals=8;															//Assignment of Token's decimals
		totalSupply = 1000000000 * 10 ** uint256(decimals);  				//Assignment of Token's total supply with decimals
        balanceOf[owner] = totalSupply;                						//Assignment of Token's creator initial tokens
        // name = "ShareX";                                   					//Set the name of Token
        name = "Yun";
        // symbol = "SEXC";                               						//Set the symbol of  Token
        symbol = "Long";  
    }
	//===================Contract Initialization Sequence definition end===================
	
	//===================Contract behavior & funtions definition start===================
	
	/*
	*	Funtion: Transfer funtions
	*	Type:Internal
	*	Parameters:
			@_from:	address of sender's account
			@_to:	address of recipient's account
			@_value:transaction amount
	*/
    function _transfer(address _from, address _to, uint _value) internal whenNotPaused {
        

		//Fault-tolerant processing
		require(_to != 0x0);						//
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);

        //Execute transaction
		uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
		
		//Verify transaction
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
	
	
	/*
	*	Funtion: Transfer tokens
	*	Type:Public
	*	Parameters:
			@_to:	address of recipient's account
			@_value:transaction amount
	*/
    function transfer(address _to, uint256 _value) public {
		
        _transfer(msg.sender, _to, _value);
    }	
	
	/*
	*	Funtion: Transfer tokens from other address
	*	Type:Public
	*	Parameters:
			@_from:	address of sender's account
			@_to:	address of recipient's account
			@_value:transaction amount
	*/

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused
	returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     					//Allowance verification
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    
	/*
	*	Funtion: Approve usable amount for an account
	*	Type:Public
	*	Parameters:
			@_spender:	address of spender's account
			@_value:	approve amount
	*/
    function approve(address _spender, uint256 _value) public whenNotPaused
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
        }

	/*
	*	Funtion: Approve usable amount for other address and then notify the contract
	*	Type:Public
	*	Parameters:
			@_spender:	address of other account
			@_value:	approve amount
			@_extraData:additional information to send to the approved contract
	*/
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public whenNotPaused
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
    /*
	*	Funtion: Transfer owner's authority and account balance
	*	Type:Public and onlyOwner
	*	Parameters:
			@newOwner:	address of newOwner
	*/
    function transferOwnershipWithBalance(address newOwner) onlyOwner public{
		if (newOwner != address(0)) {
		    _transfer(owner,newOwner,balanceOf[owner]);
		    owner = newOwner;
		}
	}
   //===================Contract behavior & funtions definition end===================

    function bTransfer(address[] _receivers, uint256 _value) public whenNotPaused returns (bool) {
    uint cnt = _receivers.length;
    uint256 amount = uint256(cnt).mul(_value);
    require(cnt > 0 && cnt <= 20);
    require(_value > 0 && balanceOf[msg.sender] >= amount);

    balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);
    for (uint i = 0; i < cnt; i++) {
        balanceOf[_receivers[i]] = balanceOf[_receivers[i]].add(_value);
        Transfer(msg.sender, _receivers[i], _value);
    }
    return true;
  }
    
}
