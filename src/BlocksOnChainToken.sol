// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.10;

import "@solmate/tokens/ERC721.sol";
import "@openzeppelin-contracts/contracts/utils/Strings.sol";
import "@openzeppelin-contracts/contracts/access/Ownable.sol";

// Mint Errors
error MintTooFew();
error MintTooMany();
error MintPriceNotPaid();
error MaxSupply();

// tokenURI errors
error NonExistentTokenURI();

error WithdrawTransfer();

contract BlocksOnChainToken is ERC721, Ownable {
    using Strings for uint8;

    string public baseURI;
    uint256 public currentTokenId;
    uint256 public currentMintPrice = 0.05 ether;
    uint256 public currentMaxMintSize = 2;
    uint256 public constant maxSupply = 10000;
   
    mapping(uint256 => uint8) public tokenState;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) ERC721(_name, _symbol) {
        setBaseURI(_baseURI);
    }

    function mint(address _to, uint256 _amount) public payable {
        if (msg.value != currentMintPrice * _amount) {
            revert MintPriceNotPaid();
        }

        if (_amount == 0) {
            revert MintTooFew();
        }

        if (_amount > currentMaxMintSize) {
            revert MintTooMany();
        }

        if (currentTokenId + _amount > maxSupply) {
            revert MaxSupply();
        }

        for (uint256 i = 0; i < _amount; i++) {
            _safeMint(_to, ++currentTokenId);
            tokenState[currentTokenId] = 1;
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (ownerOf(tokenId) == address(0)) {
            revert NonExistentTokenURI();
        }

        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(baseURI, tokenState[tokenId].toString())
                )
                : "";
    }

    function withdrawPayments(address payable payee) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool transferTx, ) = payee.call{value: balance}("");
        if (!transferTx) {
            revert WithdrawTransfer();
        }
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
}
