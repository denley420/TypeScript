// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IXToken_Core {
    function burnTokenFrom(address account, uint amount) external;

    function burnToken(uint amount) external;

    function mint(address to, uint amount) external;

    function balanceOf(address account) external view returns (uint256);

    function approveBurn(address spender, uint amount) external returns (bool);

    function addMinter(address account) external;
    // function allowance(address owner, address spender) external view returns (uint256);
}