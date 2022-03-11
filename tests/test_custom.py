import brownie
from brownie import *
from helpers.constants import MaxUint256
from helpers.SnapshotManager import SnapshotManager
from helpers.time import days

"""
  TODO: Put your tests here to prove the strat is good!
  See test_harvest_flow, for the basic tests
  See test_strategy_permissions, for tests at the permissions level
"""
def test_my_custom_test(deployed):
    # assert True
    deployer = deployed.deployer
    vault = deployed.vault
    controller = deployed.controller
    strategy = deployed.strategy
    want = deployed.want
    randomUser = accounts[6]

    initial_balance = want.balanceOf(deployer)

    settKeeper = accounts.at(vault.keeper(), force=True)

    snap = SnapshotManager(vault, strategy, controller, "StrategySnapshot")

    # Deposit
    assert want.balanceOf(deployer) > 0

    depositAmount = int(want.balanceOf(deployer) * 0.8)
    assert depositAmount > 0

    want.approve(vault.address, MaxUint256, {"from": deployer})

    snap.settDeposit(depositAmount, {"from": deployer})


def test_my_custom_test(deployed):
    assert False