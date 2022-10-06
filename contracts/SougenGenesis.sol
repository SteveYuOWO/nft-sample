// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract SougenGenesis is ERC721, Ownable {
  using ECDSA for bytes32;
  using Strings for uint256;
  using Counters for Counters.Counter;

  address private _systemAddress = 0x5dA24Ea1db0358811cB98Be06A82108c6878355B;
  mapping(string => bool) public _usedNonces;
  mapping(address => uint) public _walletMintStatus;

  Counters.Counter private supply;

  string public hiddenMetadataUri = 'ipfs://QmRAqrSEEZ6h9Rsz1tAgBTiTQsfQ831fFLNcucoJW22XnA/hidden.json';
  string public uriPrefix = 'ipfs://${GENESIS__CID__}/';
  string public uriSuffix = '.json';

  uint256 public cost = 0.00002 ether;
  uint256 public publicCost = 0.00001 ether;
  uint256 public maxSupply = 10;
  uint256 public maxMint = 3;
  uint256 public maxMintForGiveaway = 88;

  bool public paused = false;
  bool public wlOpen = true;
  bool public publicOpen = false;
  bool public revealed = false;

  event mintSuccess(address indexed _from, uint256 amount, uint256 supply);

  constructor() ERC721('Sougen Genesis Collection', 'SGC') {}

  function totalSupply() public view returns (uint256) {
    return supply.current();
  }

  modifier mintCompliance(uint256 _mintAmount) {
    require(!paused, 'Contract is paused');
    require(_mintAmount > 0 && _mintAmount <= maxMint, 'Invalid mint amount!');
    require(
      supply.current() + _mintAmount <= maxSupply,
      'Max supply exceeded!'
    );
    require(
      (balanceOf(msg.sender) + _mintAmount) <= maxMint,
      'Wallet limit exceeded!'
    );
    _;
  }

  function mint(
    uint256 _mintAmount,
    string memory nonce,
    bytes32 hash,
    bytes memory signature
  ) public payable mintCompliance(_mintAmount) {
    require(wlOpen, 'Whitelist sale is close');
    require(msg.value >= cost * _mintAmount, 'Insufficient funds');
    require(matchSigner(hash, signature), 'Plz mint through website');
    require(!_usedNonces[nonce], 'Hash reused');
    require(
      hashTransaction(msg.sender, _mintAmount, nonce) == hash,
      'Hash failed'
    );
    require(
      _walletMintStatus[msg.sender] + _mintAmount <= 3,
      'Wallet limit reached'
    );
    require(supply.current() + _mintAmount <= 4444, 'Max WL supply exceeded!');

    _usedNonces[nonce] = true;
    _walletMintStatus[msg.sender] += _mintAmount;
    _mintLoop(msg.sender, _mintAmount);
  }

  function publicMint(uint256 _mintAmount)
    public
    payable
    mintCompliance(_mintAmount)
  {
    require(publicOpen, 'Public sale is close');
    require(msg.value >= publicCost * _mintAmount, 'Insufficient funds!');
    _mintLoop(msg.sender, _mintAmount);
  }

  function matchSigner(bytes32 hash, bytes memory signature)
    public
    view
    returns (bool)
  {
    return _systemAddress == hash.toEthSignedMessageHash().recover(signature);
  }

  function hashTransaction(
    address sender,
    uint256 amount,
    string memory nonce
  ) public view returns (bytes32) {
    bytes32 hash = keccak256(
      abi.encodePacked(sender, amount, nonce, address(this))
    );

    return hash;
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
    uint256 currentTokenId = 1;
    uint256 ownedTokenIndex = 0;

    while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply) {
      address currentTokenOwner = ownerOf(currentTokenId);

      if (currentTokenOwner == _owner) {
        ownedTokenIds[ownedTokenIndex] = currentTokenId;

        ownedTokenIndex++;
      }

      currentTokenId++;
    }

    return ownedTokenIds;
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      'ERC721Metadata: URI query for nonexistent token'
    );

    if (revealed == false) {
      return hiddenMetadataUri;
    }

    string memory currentBaseURI = _baseURI();
    return
      bytes(currentBaseURI).length > 0
        ? string(
          abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix)
        )
        : '';
  }

  function setCost(uint256 _cost) public onlyOwner {
    cost = _cost;
  }

  function setPublicCost(uint256 _cost) public onlyOwner {
    publicCost = _cost;
  }

  function setMaxMint(uint256 _maxMint) public onlyOwner {
    maxMint = _maxMint;
  }

  function setUriPrefix(string memory _uriPrefix) public onlyOwner {
    uriPrefix = _uriPrefix;
  }

  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }

  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

  function setPublicOpen(bool _state) public onlyOwner {
    publicOpen = _state;
  }

  function setWlOpen(bool _state) public onlyOwner {
    wlOpen = _state;
  }

  function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
  }

  function setMaxSupply(uint256 _maxMSupply) public onlyOwner {
    maxSupply = _maxMSupply;
  }

  function setHiddenMetadataUri(string memory _hiddenMetadataUri)
    public
    onlyOwner
  {
    hiddenMetadataUri = _hiddenMetadataUri;
  }

  function withdraw() public onlyOwner {
    (bool fs, ) = payable(0x7c8fcBEc30A1e97EBA14E8dB5d195c1eE5f63221).call{
      value: address(this).balance * 50 / 100
    }('');
    require(fs);

    (bool os, ) = payable(0xC9ce49d16030fedA01D01F7C78e2E234daA5A2e1).call{
      value: address(this).balance
    }('');
    require(os);
  }

  function mintForGiveaway() public onlyOwner {
    require(
      balanceOf(msg.sender) <= maxMintForGiveaway,
      'Wallet limit exceeded!'
    );
    _mintLoop(msg.sender, maxMintForGiveaway);
  }

  function _mintLoop(address _receiver, uint256 _mintAmount) internal {
    for (uint256 i = 0; i < _mintAmount; i++) {
      supply.increment();
      _safeMint(_receiver, supply.current());
    }

    emit mintSuccess(_receiver, _mintAmount, supply.current());
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }
}