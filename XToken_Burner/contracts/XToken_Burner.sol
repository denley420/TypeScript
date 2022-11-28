// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interface/XToken_Core.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

contract XToken_Burner is Ownable {
    using Strings for uint256;

    IXToken_Core public xtoken_Core;
    address public xRewardsVerifier;
    address public targetNFTAddress;
    uint256 public targetNFTNetwork;
    uint public mintPrice;
    uint public xRewardPrice;
    uint public maxBurnedTimes;
    bool public limitBurn;
    bool public isWhitelisting;
    mapping(address => bool) public _isWhitelisted;
    mapping(address => uint256) public burnedTimes;

    event MintEvent(address Address, uint Timestamp, uint Amount);

    constructor(
        IXToken_Core _xtoken_Core,
        address _targetNFTAddress,
        uint256 _targetNFTNetwork
    ) {
        xtoken_Core = IXToken_Core(_xtoken_Core);
        targetNFTAddress = _targetNFTAddress;
        targetNFTNetwork = _targetNFTNetwork;
    }

    function isWhitelisted(address _address) public view returns (bool) {
        return isWhitelisting == false || _isWhitelisted[_address];
    }

    function tokenBurner(address _ownerAddress, uint _tokenAmount) public {
        require(isWhitelisted(msg.sender) == true, "Is not Whitelisted");

        require(
            _ownerAddress == msg.sender,
            "Error: Sending to other wallet address not allowed!."
        );
        require(_tokenAmount == mintPrice, "Did not reach require amount");

        if (limitBurn) {
            require(
                burnedTimes[msg.sender] < maxBurnedTimes,
                "Exceed max burn times"
            );
            burnedTimes[msg.sender] += 1;
        }

        xtoken_Core.burnTokenFrom(msg.sender, _tokenAmount);
        emit MintEvent(msg.sender, block.timestamp, _tokenAmount);
    }

    function setMintPrice(uint _tokenAmount) public onlyOwner {
        mintPrice = _tokenAmount;
    }

    function setMaxBurnTimes(uint _maxBurnTimes, bool _isBurn)
        public
        onlyOwner
    {
        maxBurnedTimes = _maxBurnTimes;
        limitBurn = _isBurn;
    }

    function xRewardsBurner(
        address _ownerAddress,
        uint256 _tokenAmount,
        bytes memory _signature
    ) public {
        require(
            _ownerAddress == msg.sender,
            "Error: Sending to other wallet address not allowed!."
        );
        require(_tokenAmount == xRewardPrice, "Did not reach require amount");

        string memory _address = Strings.toHexString(
            uint256(uint160(_ownerAddress)),
            20
        );

        string memory message = string(
            abi.encodePacked(_tokenAmount.toString(), _address)
        );

        require(
            xRewardsVerifier == decodeEIP191(message, _signature),
            "Error Verifying Message"
        );

        // if (isWhitelisting) {
        require(isWhitelisted(msg.sender) == true, "Is not Whitelisted");
        // }

        if (limitBurn) {
            require(
                burnedTimes[msg.sender] < maxBurnedTimes,
                "Exceed max burn times"
            );
            burnedTimes[msg.sender] += 1;
        }

        emit MintEvent(msg.sender, block.timestamp, _tokenAmount);
    }

    function setXRewardsVerifier(address _ownerAddress) public onlyOwner {
        xRewardsVerifier = _ownerAddress;
    }

    function setXRewardsPrice(uint _price) public onlyOwner {
        xRewardPrice = _price;
    }

    function setXTokenCore(address _newXTokenCoreAddress) public onlyOwner {
        xtoken_Core = IXToken_Core(_newXTokenCoreAddress);
    }

    function setTargetNftAddress(address _newNftAddress) public onlyOwner {
        targetNFTAddress = _newNftAddress;
    }

    function setTargetNftNetwork(uint256 _newNftNetwork) public onlyOwner {
        targetNFTNetwork = _newNftNetwork;
    }

    function setWhitelisted(address _newWhitelistedAddress, bool isWhitelisted_)
        public
        onlyOwner
    {
        _isWhitelisted[_newWhitelistedAddress] = isWhitelisted_;
    }

    function setIsWhitelisting(bool _newWhitelisting) public onlyOwner {
        isWhitelisting = _newWhitelisting;
    }

    function setWhitelistedBatch(
        address[] memory _whiteListedBatch,
        bool isWhitelistedBatch_
    ) public onlyOwner {
        for (uint i = 0; i < _whiteListedBatch.length; i++) {
            address _newAddress = _whiteListedBatch[i];
            _isWhitelisted[_newAddress] = isWhitelistedBatch_;
        }
    }

    function decodeEIP191(string memory message, bytes memory signature)
        public
        pure
        returns (address signer)
    {
        // The message header; we will fill in the length next
        string memory header = "\x19Ethereum Signed Message:\n000000";

        uint256 lengthOffset;
        uint256 length;
        assembly {
            // The first word of a string is its length
            length := mload(message)
            // The beginning of the base-10 message length in the prefix
            lengthOffset := add(header, 57)
        }

        // Maximum length we support
        require(length <= 999999);

        // The length of the message's length in base-10
        uint256 lengthLength = 0;

        // The divisor to get the next left-most message length digit
        uint256 divisor = 100000;

        // Move one digit of the message length to the right at a time
        while (divisor != 0) {
            // The place value at the divisor
            uint256 digit = length / divisor;
            if (digit == 0) {
                // Skip leading zeros
                if (lengthLength == 0) {
                    divisor /= 10;
                    continue;
                }
            }

            // Found a non-zero digit or non-leading zero digit
            lengthLength++;

            // Remove this digit from the message length's current value
            length -= digit * divisor;

            // Shift our base-10 divisor over
            divisor /= 10;

            // Convert the digit to its ASCII representation (man ascii)
            digit += 0x30;
            // Move to the next character and write the digit
            lengthOffset++;

            assembly {
                mstore8(lengthOffset, digit)
            }
        }

        // The null string requires exactly 1 zero (unskip 1 leading 0)
        if (lengthLength == 0) {
            lengthLength = 1 + 0x19 + 1;
        } else {
            lengthLength += 1 + 0x19;
        }

        // Truncate the tailing zeros from the header
        assembly {
            mstore(header, lengthLength)
        }

        // Perform the elliptic curve recover operation
        bytes32 check = keccak256(abi.encodePacked(header, message));

        return ECDSA.recover(check, signature);
    }
}
