# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```


1. Get sub id for the chainlink vrf and fund.
https://docs.chain.link/vrf/v2/subscription/supported-networks#goerli-testnet
2. Deploy the contract using the sub id
3. Register the contract deployed with chainlink vrf and it's subscription id
4. Register the contract to chainlink automation (https://automation.chain.link/)
5. Run staging tests
