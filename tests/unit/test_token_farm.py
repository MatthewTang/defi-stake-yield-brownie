from _pytest.python_api import raises
from brownie import network, exceptions
from scripts.helpful_scripts import (
    INITIAL_PRICE_FEED_VALUE,
    LOCAL_BLOCKCHAIN_ENVIRONMENT,
    get_account,
    get_contract,
)
from scripts.deploy import deploy_token_farm_and_dapp_token
import pytest


def test_set_price_feed_address():
    # arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENT:
        pytest.skip("Test only runs on local blockchain")

    account = get_account()
    non_owner = get_account(index=1)
    token_farm, dapp_token = deploy_token_farm_and_dapp_token()
    # act
    price_feed_address = get_contract("eth_usd_price_feed")
    token_farm.setPriceFeedContract(
        dapp_token.address, price_feed_address, {"from": account}
    )
    # assert
    assert token_farm.tokenPriceFeedMapping(dapp_token.address) == price_feed_address
    with pytest.raises(exceptions.VirtualMachineError):
        token_farm.setPriceFeedContract(
            dapp_token.address, price_feed_address, {"from": non_owner}
        )


def test_stake_token(amount_staked):
    # arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENT:
        pytest.skip("Test only runs on local blockchain")

    account = get_account()
    token_farm, dapp_token = deploy_token_farm_and_dapp_token()
    # act
    dapp_token.approve(token_farm.address, amount_staked, {"from": account})
    token_farm.stakeToken(amount_staked, dapp_token.address, {"from": account})
    # assert
    assert (
        token_farm.stakingBalance(dapp_token.address, account.address)
        == amount_staked  # can pass in the key of mapping within the mapping as second arguement
    )
    assert token_farm.uniqueTokenStaked(account.address) == 1
    assert token_farm.stakers(0) == account.address
    return token_farm, dapp_token


def test_issue_tokens(amount_staked):
    # arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENT:
        pytest.skip("Test only runs on local blockchain")
    account = get_account()
    token_farm, dapp_token = test_stake_token(amount_staked)
    starting_balance = dapp_token.balanceOf(account.address)
    # act
    token_farm.issueTokens({"from": account})
    # assert
    # amount_staked = 1 ETH
    # mock price aggregator initial price feed value 1 ETH is 200 usd
    # 1 ETH * 200 usd = 200 usd
    # so we should get back 200 usd
    assert (
        dapp_token.balanceOf(account.address)
        == starting_balance + INITIAL_PRICE_FEED_VALUE
    )


def test_unstake_tokens():
    # arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENT:
        pytest.skip("Test only runs on local blockchain")
    account = get_account()
    token_farm, dapp_token = test_stake_token(1)
    # act
    token_farm.unstakeTokens(dapp_token.address, {"from": account})
    # assert
    assert token_farm.stakingBalance(dapp_token.address, account.address) == 0
    assert token_farm.uniqueTokenStaked(account.address) == 0
    assert token_farm.stakers(0) == "0x0000000000000000000000000000000000000000"


def test_add_allowed_token():
    # arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENT:
        pytest.skip("Test only runs on local blockchain")
    account = get_account()
    non_owner = get_account(index=1)
    token_farm, dapp_token = deploy_token_farm_and_dapp_token()
    # act
    token_farm.addAllowedTokens(dapp_token.address, {"from": account})
    # assert
    assert token_farm.allowedTokens(0) == dapp_token.address
    with raises(exceptions.VirtualMachineError):
        token_farm.addAllowedTokens(dapp_token.address, {"from": non_owner})
