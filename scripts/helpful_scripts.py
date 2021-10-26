from brownie import (
    accounts,
    network,
    config,
    MockV3Aggregator,
    MockDAI,
    MockWETH,
    LinkToken,
    Contract,
)
import eth_utils

INITIAL_PRICE_FEED_VALUE = 2000 * 10 ** 18
DECIMALS = 18

NON_FORKED_LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["hardhat", "development", "ganache"]

LOCAL_BLOCKCHAIN_ENVIRONMENT = NON_FORKED_LOCAL_BLOCKCHAIN_ENVIRONMENTS + [
    "mainnet-fork",
    "binance-fork",
    "matic-fork",
]

contract_to_mock = {
    "eth_usd_price_feed": MockV3Aggregator,
    "dai_usd_price_feed": MockV3Aggregator,
    "fau_token": MockDAI,
    "weth_token": MockWETH,
}


def get_account(index=None, id=None):
    if index:
        return accounts[index]
    if id:
        return accounts.load(id)
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENT:
        return accounts[0]
    return accounts.add(config["wallets"]["from_key"])


def get_contract(contract_name):
    """
    Args:
        contract_name(string): name refered to in the brownie config and 'contract_to_mock' variable
    Returns:
        brownie.network.contract.ProjectContract: The most recently deployed contract of the type
        specified by the dictionary.  This cold either be a mock or the 'real' contract on a live
        network
    """
    contract_type = contract_to_mock[contract_name]
    if network.show_active() in NON_FORKED_LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        if len(contract_type) <= 0:
            deploy_mocks()
        contract = contract_type[-1]
    else:
        try:
            contract_address = config["networks"][network.show_active()][contract_name]
            contract = Contract.from_abi(
                contract_type._name, contract_address, contract_type._abi
            )
        except KeyError:
            print(
                f"{network.show_active()} address not found, perhaps you should add it to the config or deploy mocks?"
            )
            print(
                f"brownie run scripts/deploy_mocks.py --network {network.show_active()}"
            )
    return contract


def get_verify_status():
    verify = config["networks"][network.show_active()]["verify"]
    return verify


def deploy_mocks(decimals=DECIMALS, initial_price_feed_value=INITIAL_PRICE_FEED_VALUE):
    print(f"The active network is {network.show_active()}")
    print(f"Deploying mocks for {network.show_active()}")
    account = get_account()
    print("Deploying Mock Link Token")
    link_token = LinkToken.deploy({"from": account})
    print(f"deployed to {link_token.address}")
    print("Deploying Mock price feed ")
    mock_price_feed = MockV3Aggregator.deploy(
        decimals, initial_price_feed_value, {"from": account}
    )
    print(f"deployed to {mock_price_feed.address}")
    print("Deploying Mock Dai Token")
    dai_token = MockDAI.deploy({"from": account})
    print(f"deployed to {dai_token.address}")
    print("Deploying Mock weth Token")
    weth_token = MockWETH.deploy({"from": account})
    print(f"deployed to {weth_token.address}")


def encode_function_data(initialiser=None, *args):
    if len(args) == 0 or not initialiser:
        return eth_utils.to_bytes(hexstr="0x")
    return initialiser.encode_input(*args)
