pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CoinToken is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint private counterForRandom = 1;
    address[] private robbers;
    address[] private citizens = [0x80C9122686A039a343C0bF7c0B09fD502DDf6BdF, 0x212EeEa8dF8CA4AEe32755CA1b0d1385990614b0, 0xaB66b56d37db42589C651Feb32cA22152432E655];

    event robberyHappened(address robber, uint numberOfStolen);
    event bountyHunterChecksRobber(address bountyHunter, address robber);
    event somebodyEarnsCoin(address person);

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol) {
    }

    function mintTo(address to, string memory uri) public {
        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function citizenEarnsCoin() public {
        address citizen = citizens[_random() % citizens.length];
        mintTo(citizen, "sample_earn_coin_uri");
        emit somebodyEarnsCoin(citizen);
    }

    function coinsInTown() public view returns (uint count) {
        return _tokenIds.current();
    }

    function performRobbery() public returns (uint numberOfStolen, address robberAddress) {
        if (_tokenIds.current() == 0) {
            revert("There are no coins in a town.");
        }
        uint nStolen = 1 + _random() % _tokenIds.current();
        for (uint i = 0; i < nStolen; i++) {
            uint tokenId = _random() % _tokenIds.current();
            address tokenOwner = ownerOf(tokenId);
            if (tokenOwner == tx.origin) {
                nStolen--;
                continue;
            }
            transferFrom(tokenOwner, tx.origin, tokenId);
        }
        robbers.push(tx.origin);
        emit robberyHappened(tx.origin, nStolen);
        return (nStolen, tx.origin);
    }

    function checkLastRobber() public returns (address robberAddress) {
        if (robbers.length == 0) {
            revert("There are no robbers.");
        }
        address robber = robbers[robbers.length - 1];
        emit bountyHunterChecksRobber(tx.origin, robber);
        return robber;
    }

    function _random() private returns (uint) {
        counterForRandom++;
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _tokenIds.current(), counterForRandom)));
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}