# SUI Payroll Module

The SUI Payroll module provides functionality for managing payroll-related operations within the SUI ecosystem. It enables organizations to handle employee salaries, deposits, and withdrawals in a decentralized and secure manner.

## Structs

### Organization

- Attributes:
  - `id`: Unique identifier for the organization.
  - `name`: Name of the organization.
  - `email`: Email address of the organization.
  - `balance`: Current balance of the organization in SUI tokens.
  - `employees`: Table storing information about employees associated with the organization.
  - `new_payrolls`: Table containing details of new payrolls.
  - `paid_payrolls`: Table for storing paid payroll records.
  - `principal`: Address of the organization's principal.

### OrganizationCap

- Attributes:
  - `id`: Unique identifier for the organization capability.
  - `for`: ID of the associated organization.

### Employee

- Attributes:
  - `id`: Unique identifier for the employee.
  - `name`: Name of the employee.
  - `home`: Employee's home address.
  - `principal`: Address of the employee.
  - `balance`: Current balance of the employee in SUI tokens.
  - `department`: Department in which the employee works.
  - `designation`: Job designation of the employee.
  - `hireDate`: Date when the employee was hired.

### Payroll

- Attributes:
  - `id`: Unique identifier for the payroll.
  - `employee`: Address of the employee associated with the payroll.
  - `date`: Date of the payroll.
  - `month`: Month of the payroll.
  - `year`: Year of the payroll.
  - `basicSalary`: Basic salary amount.
  - `allowances`: Allowances included in the payroll.
  - `netSalary`: Net salary after deductions.

## Functions

- `add_organization_info`: Adds information about a new organization.
- `deposit`: Deposits SUI tokens into an organization's balance.
- `withdraw_organization_balance`: Withdraws SUI tokens from an organization's balance.
- `add_employee_info`: Adds information about a new employee.
- `withdraw_employee_balance`: Allows an employee to withdraw SUI tokens from their balance.
- `add_payroll_info`: Adds information about a new payroll for an employee.
- `remove_payroll_info`: Removes payroll information from an organization's records.

## Errors

- `EInsufficientBalance`: Indicates insufficient balance for a transaction.
- `ENotOrganization`: Indicates that the entity is not an organization.
- `ENotEmployee`: Indicates that the entity is not an employee.

## Usage

To utilize the SUI Payroll module, follow these steps:

1. **Adding Organization Information**: Use the `add_organization_info` function to add information about a new organization.

2. **Depositing Tokens**: Deposit SUI tokens into the organization's balance using the `deposit` function.

3. **Adding Employee Information**: Add information about new employees with the `add_employee_info` function.

4. **Managing Payrolls**: Use the `add_payroll_info` function to add payroll information for employees. This includes details such as salary, allowances, and net salary.

5. **Withdrawing Employee Balance**: Employees can withdraw their SUI token balances using the `withdraw_employee_balance` function.

6. **Withdrawing Organization Balance**: Organizations can withdraw SUI token balances using the `withdraw_organization_balance` function.

7. **Removing Payroll Information**: Use the `remove_payroll_info` function to remove payroll information from the organization's records.

## Run a local network

To run a local network with a pre-built binary (recommended way), run this command:

```
RUST_LOG="off,sui_node=info" sui-test-validator
```

## Configure connectivity to a local node

Once the local node is running (using `sui-test-validator`), you should the url of a local node - `http://127.0.0.1:9000` (or similar).
Also, another url in the output is the url of a local faucet - `http://127.0.0.1:9123`.

Next, we need to configure a local node. To initiate the configuration process, run this command in the terminal:

```
sui client active-address
```

The prompt should tell you that there is no configuration found:

```
Config file ["/home/codespace/.sui/sui_config/client.yaml"] doesn't exist, do you want to connect to a Sui Full node server [y/N]?
```

Type `y` and in the following prompts provide a full node url `http://127.0.0.1:9000` and a name for the config, for example, `localnet`.

On the last prompt you will be asked which key scheme to use, just pick the first one (`0` for `ed25519`).

After this, you should see the ouput with the wallet address and a mnemonic phrase to recover this wallet. You can save so later you can import this wallet into SUI Wallet.

Additionally, you can create more addresses and to do so, follow the next section - `Create addresses`.

### Create addresses

For this tutorial we need two separate addresses. To create an address run this command in the terminal:

```
sui client new-address ed25519
```

where:

- `ed25519` is the key scheme (other available options are: `ed25519`, `secp256k1`, `secp256r1`)

And the output should be similar to this:

```
╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Created new keypair and saved it to keystore.                                                   │
├────────────────┬────────────────────────────────────────────────────────────────────────────────┤
│ address        │ 0x05db1e318f1e4bc19eb3f2fa407b3ebe1e7c3cd8147665aacf2595201f731519             │
│ keyScheme      │ ed25519                                                                        │
│ recoveryPhrase │ lava perfect chef million beef mean drama guide achieve garden umbrella second │
╰────────────────┴────────────────────────────────────────────────────────────────────────────────╯
```

Use `recoveryPhrase` words to import the address to the wallet app.

### Get localnet SUI tokens

```
curl --location --request POST 'http://127.0.0.1:9123/gas' --header 'Content-Type: application/json' \
--data-raw '{
    "FixedAmountRequest": {
        "recipient": "<ADDRESS>"
    }
}'
```

`<ADDRESS>` - replace this by the output of this command that returns the active address:

```
sui client active-address
```

You can switch to another address by running this command:

```
sui client switch --address <ADDRESS>
```

## Build and publish a smart contract

### Build package

To build tha package, you should run this command:

```
sui move build
```

If the package is built successfully, the next step is to publish the package:

### Publish package

```
sui client publish --gas-budget 100000000 --json
` - `sui client publish --gas-budget 1000000000`
```
