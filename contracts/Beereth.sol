pragma solidity ^0.4.0;

import "https://github.com/souradeep-das/Beereth/node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "https://github.com/souradeep-das/Beereth/node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";

contract Beereth is ERC721Token, Ownable {
  using SafeMath for uint256;

  string public constant name = "BToken";
  string public constant symbol = "BET";

  constructor() ERC721Token(name,symbol) public {

  }

  function createCardSet5(uint a) public {
      for(uint i=0;i<5;i++)
      {
         uint8 rand2 = uint8(uint256(keccak256(a, block.difficulty))%4);
         createToken(rand2);
         a=a+7;

      }
  }

  function createCardSet10(uint a) public {
      for(uint i=0;i<9;i++)
      {
        uint8 rand2 = uint8(uint256(keccak256(a, block.difficulty))%4);
         createToken(rand2);
         a=a+49;
      }
      createToken(4);
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

  function mint(address _to,string _tokenURI) internal {
    uint256 newTokenId = _getNextTokenId();
    _mint(_to,newTokenId);
    _setTokenURI(newTokenId,_tokenURI);
  }

  function _getNextTokenId() private view returns(uint256){
    return totalSupply().add(1);
  }

  function getMyTokens() external view returns(uint256[]){
    return ownedTokens[msg.sender];
  }

}
