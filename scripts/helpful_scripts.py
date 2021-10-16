from brownie import accounts, network, config

LOCAL_FORK_MAINNET = ["mainnet-fork"]

LOCAL_BLOCKCHAIN_ENVIRONMENT = LOCAL_FORK_MAINNET + ["development"]


def get_account(index=None, id=None):
    if index:
        return accounts[index]
    if id:
        return accounts.load(id)
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENT:
        return accounts[0]
    return accounts.add(config["wallets"]["from_key"])
