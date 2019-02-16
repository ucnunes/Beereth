pragma solidity ^0.4.0;

import "https://github.com/souradeep-das/Beereth/node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "https://github.com/souradeep-das/Beereth/node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";

contract Beereth is ERC721Token, Ownable {
  using SafeMath for uint256;


  mapping (string => mapping(string => uint)) payoffMatrix;
  mapping (address => uint) userstatus;
  mapping (address => string) userchoice;
  mapping (address => uint) cardstaked;

  string public constant name = "BToken";
  string public constant symbol = "BET";

  constructor() ERC721Token(name,symbol) public {

    payoffMatrix["Barley"]["Barley"] = 0;
    payoffMatrix["Barley"]["Yeast"] = 2;
    payoffMatrix["Barley"]["HOPS"] = 1;
    payoffMatrix["Yeast"]["Barley"] = 1;
    payoffMatrix["Yeast"]["Yeast"] = 0;
    payoffMatrix["Yeast"]["HOPS"] = 2;
    payoffMatrix["HOPS"]["Barley"] = 2;
    payoffMatrix["HOPS"]["Yeast"] = 1;
    payoffMatrix["HOPS"]["HOPS"] = 0;

  }

  function createCardSet5(uint a) public payable {
      require(msg.value>= 0.008 ether);
      for(uint i=0;i<5;i++)
      {
         uint8 rand2 = uint8(uint256(keccak256(a, block.difficulty))%4);
         createToken(rand2);
         a=a+7;

      }
      userstatus[msg.sender]=0;
  }

  function createCardSet10(uint a) public payable {
      require(msg.value>=0.02 ether);
      for(uint i=0;i<9;i++)
      {
        uint8 rand2 = uint8(uint256(keccak256(a, block.difficulty))%4);
         createToken(rand2);
         a=a+49;
      }
      createToken(4);
      userstatus[msg.sender]=0;
  }

//   function test(uint a) view returns(uint256){
//       return uint8(uint256(keccak256(a, block.difficulty))%4);
//   }

  string _tokentype;
  function createToken(uint num) public {

    if(num==1)
    {
        _tokentype="Barley";
    }
    else if(num==2)
    {
        _tokentype="Yeast";
    }
    else if(num==3)
    {
        _tokentype="HOPS";
    }
    else
    {
       _tokentype="Brewery";
    }
    mint(msg.sender,_tokentype);
  }

  function createSpecialToken() public {
    mint(msg.sender,"Beer");
  }

    // the following function in ERC721BasicToken is inherited
  // function transferFrom(address _from,address _to,uint256 _tokenId)
  function battle(address user2,uint cardid)
  {
      userstatus[msg.sender]=1;
      cardstaked[msg.sender]=cardid;
      if(userstatus[user2] == 1)
      {
          uint winner = payoffMatrix[tokenURI(cardid)][tokenURI(cardstaked[user2])];
          if (winner ==1)
          {
              userstatus[msg.sender]=3;
              userstatus[user2]=2;
          }
          else if (winner ==2)
          {
              userstatus[msg.sender]=2;
              userstatus[user2]=2;
          }
      }
  }

  function completebattle(address user2,uint cardid)
  {
      if(userstatus[msg.sender]==2)
      {
          transferFrom(msg.sender,user2,cardid);
          cardstaked[msg.sender]=0;
      }
  }


  function mint(address _to,string _tokenURI) internal {
    uint256 newTokenId = _getNextTokenId();
    _mint(_to,newTokenId);
    _setTokenURI(newTokenId,_tokenURI);
  }

  function _getNextTokenId() private view returns(uint256){
    return totalSupply().add(1);
  }

  function mergemytokens(uint id1,uint id2) {
    require(tokenOwner[id1] == msg.sender);
    require(tokenOwner[id2] == msg.sender);
    uint8 rand2 = uint8(uint256(keccak256(block.number, block.difficulty))%4);
     createToken(rand2);
     _burn(msg.sender,id1);
     _burn(msg.sender,id2);

  }

  function GenerateBeer(uint barleyid,uint yeastid, uint hopsid, uint breweryid) {
    require(sha3(tokenURI(barleyid))==sha3('Barley'));
    require(sha3(tokenURI(yeastid))==sha3('Yeast'));
    require(sha3(tokenURI(hopsid))==sha3('HOPS'));
    require(sha3(tokenURI(breweryid))==sha3('Brewery'));
    createSpecialToken();
    _burn(msg.sender,barleyid);
    _burn(msg.sender,yeastid);
    _burn(msg.sender,hopsid);
    _burn(msg.sender,breweryid);

  }

  function getMyTokens() external view returns(uint256[]){
    return ownedTokens[msg.sender];
  }



}
