# Aave V2 Liquidation Example

This repo demostrates how a liquidation strategy works on Aave V2 Ethereum Mainnet using foundry.

## Installation and Setup

### 1. Install [foundry](https://book.getfoundry.sh/getting-started/installation), if you haven't already.

### 2. Clone This Repo
Run the following command.
```console
git clone https://github.com/yuichiroaoki/aaveV2-liquidation-example.git
```

## Demo

### 1. Get Ethereum Mainnet RPC URL
You can get one from [Alchemy website](https://alchemy.com/?r=33851811-6ecf-40c3-a36d-d0452dda8634) for free.

### 2. Compile Smart Contracts
Run the following command.
```console
forge build
```

### 3. Execute a Liquidation Call 🔥
Replace `<your alchemy rpc url>` with the Ethereum Mainnet RPC URL you get from step 1 and run the following command. This will run test/Liquidation.t.sol, a test contract for src/Liquidation.sol on the Ethereum Mainnet fork network on your local machine.
```bash
forge test -vv --fork-url <your alchemy rpc url> --fork-block-number 15780157 --mp test/Liquidation.t.sol
```

Expected Outputs
```
Running 4 tests for test/Liquidation.t.sol:LiquidationTest
[PASS] testCollateralAsset() (gas: 10099)
[PASS] testDebtBalance() (gas: 10061)
[PASS] testFlashloan() (gas: 727761)
Logs:
  Earned  25916384485813682 MKR

[PASS] testHealthFactor() (gas: 157336)
Logs:
  health factor 999477489095341547

Test result: ok. 4 passed; 0 failed; finished in 6.29ms
```

## References

[AaveV2 Docs](https://docs.aave.com/developers/v/2.0/guides/liquidations) / [GitHub](https://github.com/aave/protocol-v2) 

### Transaction Details
- https://etherscan.io/tx/0x6e808425bffd8aa53c9cb190251907d494fc6883ea32062d9cc80434a0b1cd84
- https://eigenphi.io/ethereum/liquidation/tx/0x6e808425bffd8aa53c9cb190251907d494fc6883ea32062d9cc80434a0b1cd84
- https://phalcon.blocksec.com/tx/eth/0x6e808425bffd8aa53c9cb190251907d494fc6883ea32062d9cc80434a0b1cd84