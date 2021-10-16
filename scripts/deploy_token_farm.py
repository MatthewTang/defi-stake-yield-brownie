from scripts.helpful_scripts import get_account
from brownie import TokenFarm


def deploy_token_farm():
    account = get_account()
    token_farm = TokenFarm.deploy({"from": account})
    token_farm.addAllowedTokens(account.address, {"from": account}).wait(1)
    tx_token_allowed = token_farm.tokenIsAllowed(account.address)
    print(tx_token_allowed)

    # with pytest.raises(exceptions.VirtualMachineError):
    # token_farm.addAllowedTokens(account.address, {"from": get_account(index=1)})


def main():
    deploy_token_farm()
