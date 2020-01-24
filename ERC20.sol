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

        function transfer(address _to, uint256 _value) external returns(bool success){
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

        function transferFrom(address _from,address _to, uint256 _value) external returns(bool success){
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

