// verifying_try: 7
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BadgeToken is ERC721 {
    uint256 private _currentTokenId = 0;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
    }

    function mintTo(address _to) public {
        uint256 newTokenId = _getNextTokenId();
        _mint(_to, newTokenId);
        _incrementTokenId();
    }

    function _getNextTokenId() private view returns (uint256) {
        return _currentTokenId+1;
    }

    function _incrementTokenId() private {
        _currentTokenId++;
    }
}