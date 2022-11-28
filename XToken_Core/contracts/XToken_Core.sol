// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
> X-Token (Core)
* will handle most of the ERC20 related functions. Extra functions such as dropshipping 
* and minting/burning will be handled by external scripts
- is ERC20
- is ERC20Mintable
- is ERC20Burnable
- is ERC20Pausable

Minting
- mint() 
- addMinter(account) [ownerOnly]
- _removeMinter(account) ***

Burning
- burnFrom
- approve(XTConvAddress, 999999999999999999) [to be called by player on front-end after they sign up]

Pause
- pause
- unpause
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract XToken_Core is ERC20Burnable, ERC20Pausable, Ownable, AccessControl {
    constructor() ERC20("XToken_Core", "XTC") {
        // Grant the minter role to a specified account
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // Create a new role identifier for the minter role
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, _msgSender()));
        _;
    }

    function burnToken(uint amount) external {
        _burn(_msgSender(), amount);
    }

    function burnTokenFrom(address account, uint amount) external {
        burnFrom(account, amount);
    }

    function approveBurn(address spender, uint amount) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint amount) public onlyMinter {
        _mint(to, amount);
    }

    function addMinter(address account) public onlyOwner {
        grantRole(MINTER_ROLE, account);
    }

    function removeMinter(address account) public onlyOwner {
        revokeRole(MINTER_ROLE, account);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }
}
