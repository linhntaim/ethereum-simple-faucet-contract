# ethereum-simple-faucet-contract

The contract provides functions to manage fund for a simple faucet dApp on the EVM-compatible blockchain.

## Features

### Get coins

Users could directly request the contract to send its coins to them (see `sendMe` function).

The owner can request the contract to send its coins to an exact address (see `send` function).

The amount of sending coins is fixed for all requests (see the `transfer` call in `_send` function).

The default amount is `0.02`. But **the owner can update it** (see `setSendingAmount` function). 
Anyway, the updating value must be in range from `0.01` to `1` which is small enough 
to prevent the owner from bad actions like draining the fund so quickly.

Another method to prevent someone from draining the fund is the time limit for the request (see `_send` function).

By default, users can request once every 3 hour for one address. And, again, the owner can update this time limit (see `setDelayMinutes` function).
The updating value must be in range (from `15` minutes to `1` day) which is long enough
to prevent the owner from bad actions.

### Donate coins

Users could make donation by sending their free coins to the deployed contract address (see `receive` function).

Additionally, the fund held by the contract has a cap (`1,000` by default). When it is full, donation is rejected.

The amount of donation also has a cap. The maximum value is `10` by default. It is to prevent users from mistakenly donating too much.

The owner could also update those cap values above (see `setCap` and `setMaxDonatingAmount` functions).

Lastly, as a bonus, if users donate an amount of more than or equals to 75% of the sending amount (when got coins), the current time limit to their addresses will be reset.

### Others

Here are functions to get some public status information of the contract:

- `getBalance`: Current balance of the fund held by the contract.
- `getSendingAmount`: Current sending amount set by the owner.
- `getMaxDonatingAmount`: Current maximum donating amount set by the owner.
- `getCap`: Current cap of the fund held by the contract set by the owner.
- `getDelayMinutes`: Current time limit set by the owner.
- `getTimeout`: Last time of the request to get coins made by current sender.