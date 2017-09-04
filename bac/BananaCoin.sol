pragma solidity ^0.4.11;

import "./StandardToken.sol";

contract BananaToken is StandardToken{
    string public version = "1.0";
    string public constant name ="BananafundCoin";//代币名称
    string public constant symbol ="BAC";//代币标识
    uint8 public constant decimals =18;//精度
    //一个以太兑换BAC的个数
    uint public exchangePerNumber;
    //是否在发售中
    bool public saledOrNot;
    
    //合约的创建者
    address public owner;
    
    //定义事件
    //购买代币成功
    event PurchaseOk(address addr,uint256 ethAccount,uint256 account);
    //开启BAC售卖
    event saleStarted();

    //合约创建者的修饰符
    modifier onlyOwner {
        // if (msg.sender != owner) throw;
       if (msg.sender != owner) throw;
        _;
    }
    
    //构造函数 创建者和代币资产的个数；
    function BananaToken(uint tokenExchangePerNumber,uint tokenTotalNumber){
        owner=msg.sender;
        //赋值给totalSupply
        totalSupply = tokenTotalNumber;
        exchangePerNumber = tokenExchangePerNumber;
        //girve all tokens to owner
        balances[owner] = tokenTotalNumber;
        saledOrNot=false;
      
    }
    
    // 开启代币的销售
    function beginSale() onlyOwner{
        //将一定的代币转到合约地址下
        if(!saledOrNot){
          var totalToKen = balances[msg.sender];
          balances[this]= totalToKen;
          balances[msg.sender] = balances[msg.sender].sub(totalToKen);
          saledOrNot = true;
          saleStarted();
        }else{
            throw;
        }
    }
    
    //转账给以太可以直接购买Token
    function() payable{
        buyToken();
    }
    
    // 购买代币 需要以太币
    function buyToken() payable{
        //检测购买者使用的ether的数额
        assert(msg.value >= 0.01 ether);
        //根据以太获得可以购买的代币的数额
        uint256  account = getTokenAccount(msg.value);
         //合约账户的代币确保充足
        // if(account>balances[this]) throw;
        if(balances[this] <account) throw;
        //添加到数量的代币到账户
        balances[msg.sender] =balances[msg.sender].add(account);
        //合约地址下的代币数目减少
        balances[this] = balances[this].sub(account);
        PurchaseOk(msg.sender,msg.value,account);
    }
    
    //定义代币价格
    function setPrice(uint256 _exchange_per_number)  onlyOwner{
        // if(_exchange_per_number <0) throw;
        if(_exchange_per_number <=0) throw;
        exchangePerNumber = _exchange_per_number;
    }
    
    //更改用户主人
    function changeOwner(address addr) onlyOwner{
        owner = addr;
    }
    
    // 计算可以购买代币的数额 以位为单位
    function getTokenAccount(uint256 ethAccount) internal returns (uint256 account){
        //获取代币个数整数
         account = ethAccount.mul(exchangePerNumber);
    }
    
    //毁掉合约
    function killContract() onlyOwner{
        suicide(owner);
    }
}