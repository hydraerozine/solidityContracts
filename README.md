# Sample Hardhat Project

This project has developed EVM contracts to store balances across EVM compatible chains. BLITZ folder contains contracts related to storage of balances which will be managed by ICP. We also have under BLITZ folder a testing of interacting with the pancakeSwap router, so that ICP can perform the swaps without compromising its wallet.

CIT is the token intermediary which will facilitate bridging across chains. It will not be limited to EVM but also non-EVM chains. Scripts help to deploy and perform operations

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```
