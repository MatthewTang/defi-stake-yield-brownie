from brownie import TokenFarm, exceptions
from scripts.helpful_scripts import get_account
import pytest


def test_stake_token_amount_must_greater_than_zero():
    account = get_account()
    token_farm = TokenFarm.deploy({"from": account})
    with pytest.raises(exceptions.VirtualMachineError):
        token_farm.stakeToken(0, account.address)


def test_only_owner_can_add_allowed_token():
    account = get_account()
    token_farm = TokenFarm.deploy({"from": account})
    token_farm.addAllowedTokens(account.address, {"from": account}).wait(1)
    assert token_farm.tokenIsAllowed(account.address) == True
    with pytest.raises(exceptions.VirtualMachineError):
        token_farm.addAllowedTokens(account.address, {"from": get_account(index=1)})
