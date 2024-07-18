

# AIRDROP CONTRACT

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg?style=for-the-badge)
![Forge](https://img.shields.io/badge/Forge-v0.2.0-blue?style=for-the-badge)
[![License: MIT](https://img.shields.io/github/license/trashpirate/airdrop-contract?style=for-the-badge)](https://github.com/trashpirate/airdrop-contract/blob/master/LICENSE)

[![Website: nadinaoates.com](https://img.shields.io/badge/Portfolio-00e0a7?style=for-the-badge&logo=Website)](https://nadinaoates.com)
[![LinkedIn: nadinaoates](https://img.shields.io/badge/LinkedIn-0a66c2?style=for-the-badge&logo=LinkedIn&logoColor=f5f5f5)](https://linkedin.com/in/nadinaoates)
[![Twitter: N0\_crypto](https://img.shields.io/badge/@N0\_crypto-black?style=for-the-badge&logo=X)](https://twitter.com/N0\_crypto)

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#usage">Usage</a></li>
      </ul>
    </li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <!-- <li><a href="#acknowledgments">Acknowledgments</a></li> -->
  </ol>
</details>

### ✨ [DApp](https://airdrop.buyholdearn.com)

<!-- ABOUT THE PROJECT -->
## About The Project

![Airdrop](https://airdrop.buyholdearn.com/title.png?raw=true)


Smart contract to perform airdrops to multiple wallets. Users pay a fee in EARN to perform an airdrop (call airdrop() function).

### Contracts on BASE TESTNET

**Fee Token on Testnet**  
https://sepolia.basescan.org/token/0x714e4e99125c47bd3226d8b644c147d3ff8e1e3b

**Airdrop Token on Testnet**  
https://sepolia.basescan.org/token/0xd8a3d75aa2db08bcefc67cde9cd2b51b981153e1

**Airdrop Contract on Testnet**  
https://sepolia.basescan.org/address/0xf1b8489f2e119dd023f19984de533f95ff28ecee

### Contracts on BASE MAINNET

**Fee Token on Mainnet**  
https://basescan.org/token/0x803b629c339941e2b77d2dc499dac9e1fd9eac66

**Airdrop Token on Mainnet**  
https://basescan.org/address/0xcd8946dda83af26e817579a40587efec05aec45b

**Airdrop Contract Mainnet**  
https://basescan.org/address/0x8A0625F75A18f045057B59CE19fF83E7F03c6Dba

<!-- GETTING STARTED -->
## Getting Started

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/trashpirate/airdrop-contract.git
   ```
2. Navigate to the project directory
   ```sh
   cd airdrop-contract
   ```
3. Install Foundry submodules
   ```sh
   forge install
   ```

### Usage

Before running any commands, create a .env file and add the following environment variables. These are configured for BASE chain:

```bash
# rpcs
RPC_LOCALHOST="http://127.0.0.1:8545"

# base chain
RPC_BASE_MAIN=<RPC_URL>
RPC_BASE_SEPOLIA=<RPC_URL>
RPC_BASE_GOERLI=<RPC_URL>

BASESCAN_KEY=<BASESCAN_API_KEY>
```

#### Compiling
```sh
forge build
```

#### Testing locally

Run local tests:  
```sh
forge test
```

Run test with mainnet fork:
1. Start local test environment
    ```sh
    make fork
    ```
2. Run fork tests
    ```sh
    forge test
    ```

#### Deploy to testnet

1. Create test wallet using keystore. Enter private key of test wallet when prompted.
    ```sh
    cast wallet import <KeystoreName> --interactive
    ```
    Update the Makefile accordingly.

2. Deploy to testnet
    ```sh
    make deploy-testnet
    ```

#### Deploy to mainnet
1. Create deployer wallet using keystore. Enter private key of deployer wallet when prompted.
    ```sh
    cast wallet import <KeystoreName> --interactive
    ```
    Update the Makefile accordingly.

2. Deploy to mainnet
    ```sh
    make deploy-mainnet
    ```

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<!-- CONTACT -->
## Contact

Nadina Oates - [@N0_crypto](https://twitter.com/N0_crypto)
Contract Repository: [https://github.com/trashpirate/airdrop-dapp](https://github.com/trashpirate/airdrop-dapp)
Project Link: [https://airdrop.buyholdearn.com/](https://airdrop.buyholdearn.com/)

<!-- ACKNOWLEDGMENTS -->
<!-- ## Acknowledgments -->



