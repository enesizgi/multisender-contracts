// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface Token {

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance the balance
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) external returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender, uint256 _value) external returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Multisender {
    function sendEther(address payable[] memory to, uint256[] memory value) public payable returns (bool success) {
        require(to.length == value.length);
        uint256 total = 0;
        for (uint256 i = 0; i < to.length; i++) {
            (bool sent, ) = to[i].call{value: value[i]}("");
            require(sent);
            total += value[i];
        }
        if (total < msg.value) {
            (bool sent, ) = msg.sender.call{value: msg.value - total}("");
            require(sent);
        }
        return true;
    }

    function sendERC20(address tokenAddress, address[] memory to, uint256[] memory value) public returns (bool success) {
        require(to.length == value.length);
        Token token = Token(tokenAddress);
        for (uint256 i = 0; i < to.length; i++) {
            require(token.transferFrom(msg.sender, to[i], value[i]));
        }
        return true;
    }
}
