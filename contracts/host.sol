// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RandomNameToken is ERC20 {
    string private _nameInternal;
    string private _symbolInternal;

    constructor(uint256 initialSupply) ERC20("TEMP", "TMP") {
        // Псевдорандомное число из данных блока
        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(
                    block.prevrandao,   // для PoS сетей, аналог block.difficulty
                    block.timestamp,
                    msg.sender
                )
            )
        );

        // Алфавит для генерации символов
        bytes memory alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

        // Генерим длину имени 5–10 символов
        uint256 nameLen = 5 + (rand % 6);
        bytes memory nameBytes = new bytes(nameLen);

        for (uint256 i = 0; i < nameLen; i++) {
            uint256 idx = uint8(uint256(keccak256(abi.encodePacked(rand, i))) % alphabet.length);
            nameBytes[i] = alphabet[idx];
        }

        // Генерим 3‑буквенный символ
        bytes memory symbolBytes = new bytes(3);
        for (uint256 j = 0; j < 3; j++) {
            uint256 idx2 = uint8(uint256(keccak256(abi.encodePacked(rand, j + 100))) % alphabet.length);
            symbolBytes[j] = alphabet[idx2];
        }

        _nameInternal = string(nameBytes);
        _symbolInternal = string(symbolBytes);

        // Минтим initialSupply * 10^decimals на деплойера
        _mint(msg.sender, initialSupply * (10 ** uint256(decimals())));
    }

    function name() public view override returns (string memory) {
        return _nameInternal;
    }

    function symbol() public view override returns (string memory) {
        return _symbolInternal;
    }
}
