const { newDao, newApp } = require('../../0.4.24/helpers/dao')
const { assertBn } = require('@aragon/contract-helpers-test/src/asserts')
const { ANY_ADDRESS } = require('@aragon/hardhat-aragon/dist/constants')

const Lido = artifacts.require('LidoMock.sol')
const NodeOperatorsRegistry = artifacts.require('NodeOperatorsRegistry')
const OracleMock = artifacts.require('OracleMock.sol')
const SBCTokenProxy = artifacts.require('SBCTokenProxy.sol')
const SBCToken = artifacts.require('SBCToken.sol')
const SBCDepositContractProxy = artifacts.require('SBCDepositContractProxy.sol')
const SBCDepositContract = artifacts.require('SBCDepositContract.sol')

module.exports = {
  deployDaoAndPool
}

const DEPOSIT_ROOT = '0xd151867719c94ad8458feaf491809f9bc8096c702a72747403ecaac30c179137'
const UNLIMITED = 1000000000
const tokens = (value) => web3.utils.toWei(value + '', 'ether')

async function deployDaoAndPool(appManager, voting, nobody, user1, user2, user3) {
  // Deploy the DAO, oracle and deposit contract mocks, and base contracts for
  // Lido (the pool) and NodeOperatorsRegistry (the Node Operators registry)

  const [{ dao, acl }, oracleMock, poolBase, nodeOperatorRegistryBase] = await Promise.all([
    newDao(appManager),
    OracleMock.new(),
    Lido.new(),
    NodeOperatorsRegistry.new()
  ])

  const mGnoProxy = await SBCTokenProxy.new(nobody, 'mGNO', 'mGNO')
  const mGno = await SBCToken.at(mGnoProxy.address)
  await mGno.setMinter(nobody, { from: nobody })
  await mGno.mint(user1, tokens(UNLIMITED), { from: nobody })
  await mGno.mint(user2, tokens(UNLIMITED), { from: nobody })
  await mGno.mint(user3, tokens(UNLIMITED), { from: nobody })
  assertBn(await mGno.balanceOf(user1), tokens(UNLIMITED), 'user1 mGno balance check')
  assertBn(await mGno.balanceOf(user2), tokens(UNLIMITED), 'user2 mGno balance check')
  assertBn(await mGno.balanceOf(user3), tokens(UNLIMITED), 'user3 mGno balance check')
  const depositContractProxy = await SBCDepositContractProxy.new(nobody, mGnoProxy.address)
  const depositContract = await SBCDepositContract.at(depositContractProxy.address)

  // Instantiate proxies for the pool, the token, and the node operators registry, using
  // the base contracts as their logic implementation

  const [poolProxyAddress, nodeOperatorRegistryProxyAddress] = await Promise.all([
    newApp(dao, 'lido', poolBase.address, appManager),
    newApp(dao, 'node-operators-registry', nodeOperatorRegistryBase.address, appManager)
  ])

  const [token, pool, nodeOperatorRegistry] = await Promise.all([
    Lido.at(poolProxyAddress),
    Lido.at(poolProxyAddress),
    NodeOperatorsRegistry.at(nodeOperatorRegistryProxyAddress)
  ])

  // Initialize the node operators registry and the pool
  await nodeOperatorRegistry.initialize(pool.address)

  const [
    POOL_PAUSE_ROLE,
    POOL_RESUME_ROLE,
    POOL_MANAGE_FEE,
    POOL_MANAGE_WITHDRAWAL_KEY,
    POOL_BURN_ROLE,
    DEPOSIT_ROLE,
    STAKING_PAUSE_ROLE,
    STAKING_CONTROL_ROLE,
    SET_EL_REWARDS_VAULT_ROLE,
    SET_EL_REWARDS_WITHDRAWAL_LIMIT_ROLE,
    NODE_OPERATOR_REGISTRY_MANAGE_SIGNING_KEYS,
    NODE_OPERATOR_REGISTRY_ADD_NODE_OPERATOR_ROLE,
    NODE_OPERATOR_REGISTRY_SET_NODE_OPERATOR_ACTIVE_ROLE,
    NODE_OPERATOR_REGISTRY_SET_NODE_OPERATOR_NAME_ROLE,
    NODE_OPERATOR_REGISTRY_SET_NODE_OPERATOR_ADDRESS_ROLE,
    NODE_OPERATOR_REGISTRY_SET_NODE_OPERATOR_LIMIT_ROLE,
    NODE_OPERATOR_REGISTRY_REPORT_STOPPED_VALIDATORS_ROLE
  ] = await Promise.all([
    pool.PAUSE_ROLE(),
    pool.RESUME_ROLE(),
    pool.MANAGE_FEE(),
    pool.MANAGE_WITHDRAWAL_KEY(),
    pool.BURN_ROLE(),
    pool.DEPOSIT_ROLE(),
    pool.STAKING_PAUSE_ROLE(),
    pool.STAKING_CONTROL_ROLE(),
    pool.SET_EL_REWARDS_VAULT_ROLE(),
    pool.SET_EL_REWARDS_WITHDRAWAL_LIMIT_ROLE(),
    nodeOperatorRegistry.MANAGE_SIGNING_KEYS(),
    nodeOperatorRegistry.ADD_NODE_OPERATOR_ROLE(),
    nodeOperatorRegistry.SET_NODE_OPERATOR_ACTIVE_ROLE(),
    nodeOperatorRegistry.SET_NODE_OPERATOR_NAME_ROLE(),
    nodeOperatorRegistry.SET_NODE_OPERATOR_ADDRESS_ROLE(),
    nodeOperatorRegistry.SET_NODE_OPERATOR_LIMIT_ROLE(),
    nodeOperatorRegistry.REPORT_STOPPED_VALIDATORS_ROLE()
  ])

  await Promise.all([
    // Allow voting to manage the pool
    acl.createPermission(voting, pool.address, POOL_PAUSE_ROLE, appManager, { from: appManager }),
    acl.createPermission(voting, pool.address, POOL_RESUME_ROLE, appManager, { from: appManager }),
    acl.createPermission(voting, pool.address, POOL_MANAGE_FEE, appManager, { from: appManager }),
    acl.createPermission(voting, pool.address, POOL_MANAGE_WITHDRAWAL_KEY, appManager, { from: appManager }),
    acl.createPermission(voting, pool.address, POOL_BURN_ROLE, appManager, { from: appManager }),
    acl.createPermission(voting, pool.address, STAKING_PAUSE_ROLE, appManager, { from: appManager }),
    acl.createPermission(voting, pool.address, STAKING_CONTROL_ROLE, appManager, { from: appManager }),
    acl.createPermission(voting, pool.address, SET_EL_REWARDS_VAULT_ROLE, appManager, { from: appManager }),
    acl.createPermission(voting, pool.address, SET_EL_REWARDS_WITHDRAWAL_LIMIT_ROLE, appManager, { from: appManager }),

    // Allow depositor to deposit buffered ether
    acl.createPermission(ANY_ADDRESS, pool.address, DEPOSIT_ROLE, appManager, { from: appManager }),

    // Allow voting to manage node operators registry
    acl.createPermission(voting, nodeOperatorRegistry.address, NODE_OPERATOR_REGISTRY_MANAGE_SIGNING_KEYS, appManager, {
      from: appManager
    }),
    acl.createPermission(voting, nodeOperatorRegistry.address, NODE_OPERATOR_REGISTRY_ADD_NODE_OPERATOR_ROLE, appManager, {
      from: appManager
    }),
    acl.createPermission(voting, nodeOperatorRegistry.address, NODE_OPERATOR_REGISTRY_SET_NODE_OPERATOR_ACTIVE_ROLE, appManager, {
      from: appManager
    }),
    acl.createPermission(voting, nodeOperatorRegistry.address, NODE_OPERATOR_REGISTRY_SET_NODE_OPERATOR_NAME_ROLE, appManager, {
      from: appManager
    }),
    acl.createPermission(voting, nodeOperatorRegistry.address, NODE_OPERATOR_REGISTRY_SET_NODE_OPERATOR_ADDRESS_ROLE, appManager, {
      from: appManager
    }),
    acl.createPermission(voting, nodeOperatorRegistry.address, NODE_OPERATOR_REGISTRY_SET_NODE_OPERATOR_LIMIT_ROLE, appManager, {
      from: appManager
    }),
    acl.createPermission(voting, nodeOperatorRegistry.address, NODE_OPERATOR_REGISTRY_REPORT_STOPPED_VALIDATORS_ROLE, appManager, {
      from: appManager
    })
  ])

  await pool.initialize(depositContract.address, oracleMock.address, nodeOperatorRegistry.address)
  await mGno.increaseAllowance(pool.address, tokens(UNLIMITED), { from: user1 })
  await mGno.increaseAllowance(pool.address, tokens(UNLIMITED), { from: user2 })
  await mGno.increaseAllowance(pool.address, tokens(UNLIMITED), { from: user3 })

  await oracleMock.setPool(pool.address)
  await depositContract.reset()
  await depositContract.set_deposit_root(DEPOSIT_ROOT)

  const [treasuryAddr, insuranceAddr] = await Promise.all([pool.getTreasury(), pool.getInsuranceFund()])

  return {
    dao,
    acl,
    oracleMock,
    depositContract,
    token,
    pool,
    nodeOperatorRegistry,
    treasuryAddr,
    insuranceAddr,
    mGno
  }
}
