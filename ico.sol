pragma solidity ^0.5.3;

interface IERC20{
        function totalSupply() external view returns (uint256);
        //it returns the initial quantity of rolled out tokens

        function balanceOf(address _owner) external view returns(uint256 balance);
        //it returns the number of token hold by any particular address

        function transfer(address _to,uint256 _value) external returns(bool success);
        //this function is used to transfer token from one account to another

        function approve(address _spender,uint256 _value) external returns(bool success);
        //owner approves a spender to use it's own token

        function transferFrom(address _from,address _to,uint256 _value) external returns(bool success);
        //once approved it is used to transfer all or partial allowed/approved tokens to spender

        function allowance(address _owner,address _spender) external view returns(uint256 remaining);
        //this function is used to know the number of remaining approved tokens

        event Transfer(address indexed _from,address indexed _to,uint256 _value);
        //it is used to log the transfer function activity like from account,to acccount and how much token was transferred

        event Approval(address indexed _owner,address indexed _spender, uint256 _value);
        //it is used inside approved function to log the activity of approved function

}

contract MyERC20Token is IERC20{
        mapping (address=>uint256) public _balances;

        //Approval
        mapping(address=>mapping(address=>uint256)) _allowed;
        //name,symbol,decimal

        string public name="BlkTraining";
        string public symbol="BLK";
        uint public decimals=0;

        //uint256 -initial supply
        uint256 public _totalSupply;

        //address - creator's address
        address public _creator;

        constructor() public{
                _creator=msg.sender;
                _totalSupply=5000;
                _balances[_creator]=_totalSupply;
        }

        function totalSupply() external view returns(uint256){
                return _totalSupply;
        }

        function balanceOf(address _owner) external view returns(uint256 balance){
                return _balances[_owner];
        }

        function transfer(address _to, uint256 _value) public external returns(bool success){
                require(_value > 0 && _balances[msg.sender] >= _value);

                _balances[_to]+=_value;
                _balances[msg.sender]-=_value;

                emit Transfer(msg.sender,_to,_value);

                return true;
        }

        function approve(address _spender,uint256 _value) public returns(bool success){
                require(_value>0 && _balances[msg.sender]>=_value);

                _allowed[msg.sender][_spender]=_value;
                emit Approval(msg.sender,_spender,_value);

                return true;
        }

        function transferFrom(address _from,address _to, uint256 _value) public external returns(bool success){
                require(_value > 0 && _balances[_from]>=_value && _allowed[_from][_to]>=_value);
                _balances[_to]+=_value;
                _balances[_from]-=_value;

                _allowed[_from][_to]-=_value;

                return true;
        }

        function allowance(address _owner,address _spender) external view returns(uint256 remaining){
                return _allowed[_owner][_spender];
        }
}

contract ICOBLK as MyERC20Token{
	address public administrator;		//define the admin of ICO
	
	address payable public Recipient;	//Recipient account

	uint public tokenPrice=10000000000;	//Set price of token, 0.001 ether
	
	uint public icoTarget=5000000000000;	//hardcop 500 ether

	uint public receivedFund;		//define a state variable to track the funded amount

	uint public maxInvestment=10000000000000000;
	uint public minInvestment=10000000000;

	enum Status {inactive,active,stopped,completed}
	Status public icoStatus;

	uint public icoStatus;

	//5days duration
	uint public icoEndTime=now+432000;

	modifier ownerOnly{
		if(msg.sender == adminstrator){
			_;
		}
	}

	constructor(address payable _recipient) public{
		administrator=msg.sender;
		recipient=_recipient;
	}

	function setActiveStatus() public ownerOnly{
		icoStatus=Status.active;
	}

	function getIcoStatus() public view returns(Status){
		if(icoStatus == Status.stopped){
			return Status.stopped;
		}else if (block.timestamp >= icoStartTime && block.timestamp <= icoEndTime){
			return Status.active;
		}else if (block.timestamp <= icoStartTime){
			return Status.inactive;
		}else{
			return Status.completed;
		}
	}

	function Investing() payable public returns(bool){
		//check for hard cap

		icoStatus=getIcoStatus();
		require(icoStatus == Status.active,"ICO is not  active");

		require(icoTarget >= receivedFund+msg.value,"Target Achieved, Investment not accepted");

		//check for minimum and maximum investment
		require(msg.value >= minInvestment && msg.value<=maxInvestment,"Investment not in allowed range");

		uint tokens=msg.value/tokenPrice;
		
		_balances[msg.sender]+=tokens;
		_balances[_creator]-=tokens;

		recipient.transfer(msg.value);

		receivedFund+= msg.value;
		return true;
	}

	function burn() public ownerOnly returns(bool){  //Mtlb ki agar kuch tokens bach gay hain toh unko burn krdo take koi unka misuse na kr paye
		icoStatus=getIcoStatus();
		require(icoStatus == Status.completed,"ICO not complete");

		_balances[_creator]=0;

	}


	function transfer(address _to,uint256 _value) public external returns(bool success){
		require(block.timestamp > startTrading,"Trading is not allowed currently");
		super.transfer(_to,_value);
		return true;
	}	

	function transferFrom(address _from,address _to,uint256 _value) public returns(bool success){
		require(block.timestamp > startTrading,"Trading is not allowed currently");
		super.transferFrom(_from,_to,_value);
		return true;
	}
}
