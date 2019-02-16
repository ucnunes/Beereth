pragma solidity ^0.5.0;

import "../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";

contract EthBeer is ERC721Token, Ownable {
    using SafeMath for uint256;

    mapping (string => mapping(string => uint)) payoffMatrix;
    mapping (address => uint) userstatus;
    mapping (address => string) userchoice;
    mapping (address => uint) cardStaked;

    string public constant name = "BeerToken";
    string public constant symbol = "BRT";

    constructor() ERC721Token(name,symbol) public {

        payoffMatrix["rock"]["rock"] = 0;
        payoffMatrix["rock"]["paper"] = 2;
        payoffMatrix["rock"]["scissors"] = 1;
        payoffMatrix["paper"]["rock"] = 1;
        payoffMatrix["paper"]["paper"] = 0;
        payoffMatrix["paper"]["scissors"] = 2;
        payoffMatrix["scissors"]["rock"] = 2;
        payoffMatrix["scissors"]["paper"] = 1;
        payoffMatrix["scissors"]["scissors"] = 0;

    }

    function createFiveCards(uint256 seed) public {
        uint256 nonce = seed;
        for(uint256 i = 0; i < 5; i++)
        {
            uint256 randomNumber = uint256(uint256(keccak256(abi.encodePacked(nonce, block.difficulty)))%4);
            createToken(randomNumber);
            nonce += 7;
        }
        userstatus[msg.sender] = 0;
    }
    
    function createTenCards(uint256 seed) public {
        uint256 nonce = seed;
        for(uint256 i = 0; i < 9; i++)
        {
            uint256 randomNumber = uint256(uint256(keccak256(abi.encodePacked(nonce, block.difficulty)))%4);
            createToken(randomNumber);
            nonce += 49;
        }
        createToken(4);
        userstatus[msg.sender] = 0;
    }

    string _tokentype;

    function createToken(uint256 num) public {

        if(num == 1)
        {
            _tokentype = "Barley";
        }
        else if(num == 2)
        {
            _tokentype = "Yeast";
        }
        else if(num == 3)
        {
            _tokentype = "HOPS";
        }
        else
        {
            _tokentype = "Brewery";
        }
        mint(msg.sender, _tokentype);
    }

    function createSpecialToken() public {
        mint(msg.sender, "Beer");
    }

    // the following function in ERC721BasicToken is inherited
    // function transferFrom(address _from,address _to,uint256 _tokenId)
    function battle(address userTwo,uint256 cardId)
        public
    {
        userstatus[msg.sender] = 1;
        cardStaked[msg.sender] = cardId;

        if(userstatus[userTwo] == 1)
        {
            uint256 winner = payoffMatrix[tokenURI(cardId)][tokenURI(cardStaked[userTwo])];
            if (winner == 1)
            {
                userstatus[msg.sender] = 3;
                userstatus[userTwo] = 2;
            }
            else if (winner == 2)
            {
                userstatus[msg.sender] = 2;
                userstatus[userTwo] = 2;
            }
        }
    }

    function completebattle(address userTwo,uint256 cardId)
        public
    {
        if(userstatus[msg.sender] == 2)
        {
            transferFrom(msg.sender,userTwo,cardId);
            cardStaked[msg.sender] = 0;
        }
    }

    function mint(address _to, string memory _tokenURI) internal {
        uint256 newTokenId = _getNextTokenId();
        _mint(_to, newTokenId);
        _setTokenURI(newTokenId,_tokenURI);
    }

    function _getNextTokenId() private view returns(uint256){
        return totalSupply().add(1);
    }

    function mergeMyTokens(uint256 tokenIdOne,uint256 tokenIdTwo)
        public
    {
        require(tokenOwner[tokenIdOne] == msg.sender, "Sender is not token owner");
        require(tokenOwner[tokenIdTwo] == msg.sender, "Sender is not token owner");
        uint256 randomNumber = uint(uint(keccak256(abi.encodePacked(block.number, block.difficulty)))%4);
        createToken(randomNumber);
        _burn(msg.sender,tokenIdOne);
        _burn(msg.sender,tokenIdTwo);
    }

    function generateBeer(uint256 barleyId,uint256 yeastId, uint256 hopsId, uint256 breweryId) 
        public
    {
        require(tokenURI[barleyId] == "Barley", "error");
        require(tokenURI[yeastId] == "Yeast", "error");
        require(tokenURI[hopsId] == "HOPS", "error");
        require(tokenURI[breweryId] == "Brewery", "error");
        createSpecialToken();
        _burn(msg.sender,barleyId);
        _burn(msg.sender,yeastId);
        _burn(msg.sender,hopsId);
        _burn(msg.sender,breweryId);
    }

    function getMyTokens()
        public
        view
        returns(uint[] memory)
    {
        return tokenOwner[msg.sender];
    }
}
