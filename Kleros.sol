//"SPDX-License-Identifier: None
pragma solidity ^0.8.0;

contract Owner {

    address public  owner;
    address public heir;
    
    //event logged whenever the owner changes
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     * @param _heir initialized  
     */
    constructor(address _heir) {
        require(_heir!=msg.sender,"Owner can't be the heir");
        owner = msg.sender; 
        heir=_heir;
        emit OwnerSet(address(0), owner);
    }
    
    /**
     * @dev Owner Sets heir 
     * @param newHeir set by new owner
     */
    function setHeir(address newHeir) public isOwner{
    require(newHeir!=address(0)&&newHeir !=owner,"can't be the heir");
    heir=newHeir;
    }
} 

contract Bank is Owner{
    uint public balance ;
    uint private counter=block.timestamp;
    /**
     * @dev Set contract deployer as owner
     * @param _heir initialized  
     */
    constructor(address _heir) Owner( _heir) {
        
    }
    /**
     * @dev Deposit amount 
     */
    function deposit() public payable {
        balance+=msg.value;
    }
    /**
     * @dev Owner Withdraws amount 
     * @param _amount to be withdrawn
     */
    function withdraw(uint _amount) public isOwner returns(bool success) {
        require(_amount<=balance,"Insufficient Balance");
            if(_amount==0){
            require(block.timestamp > counter + 30 days , "Can't change owner due to time limit");
            owner = heir;
            counter=block.timestamp;
            emit OwnerSet(owner, heir);
            return success=true;
            }else {
            balance-=_amount;
            counter= block.timestamp;
            ( success,)=owner.call{value:_amount}("");
            return success;
        }
    }

}
