// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import '../../../lib/reactive-lib/src/interfaces/IReactive.sol';
import '../../../lib/reactive-lib/src/abstract-base/AbstractReactive.sol';
import '../../../lib/reactive-lib/src/interfaces/ISystemContract.sol';

contract RewardsReactive is IReactive, AbstractReactive {
    event Event(
        uint256 indexed chain_id,
        address indexed _contract,
        uint256 indexed topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3,
        bytes data,
        uint256 counter
    );

    event Callback(uint256 indexed chain_id, address indexed target, uint64 gas_limit, bytes payload);

    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint64 private constant GAS_LIMIT = 1000000;

    address private rewardsContract;

    bytes32 private constant SET_REWARD_TOPIC = keccak256("SetReward(address,uint256)");

    constructor(address _service, address _rewardsContract) payable {
        service = ISystemContract(payable(_service));
        rewardsContract = _rewardsContract;

        if (!vm) {
            service.subscribe(
                SEPOLIA_CHAIN_ID,
                _rewardsContract,
                uint256(SET_REWARD_TOPIC),
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }
    }

    function react(LogRecord calldata log) external vmOnly {// this clls the fxn of other contract 
        emit Event(
            log.chain_id,
            log._contract,
            log.topic_0,
            log.topic_1,
            log.topic_2,
            log.topic_3,
            log.data,
            ++counter
        );

        address user;
        assembly {
            user := mload(add(log.data, 32))
        }

        bytes memory payload = abi.encodeWithSignature("claim()",address(0));
        emit Callback(log.chain_id, user, GAS_LIMIT, payload);
    }

    function subscribe() external {
        service.subscribe(
            SEPOLIA_CHAIN_ID,
            rewardsContract,
            uint256(SET_REWARD_TOPIC),
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
    }

    function unsubscribe() external {
        service.unsubscribe(
            SEPOLIA_CHAIN_ID,
            rewardsContract,
            uint256(SET_REWARD_TOPIC),
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
    }

    function resetCounter() external {
        counter = 0;
    }
}
