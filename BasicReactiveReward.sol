// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import './lib/reactive-lib/src/interfaces/IReactive.sol';
import './lib/reactive-lib/src/abstract-base/AbstractReactive.sol';
import './lib/reactive-lib/src/interfaces/ISystemContract.sol';

contract RewardsReactive is IReactive, AbstractReactive {

    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint64 private constant GAS_LIMIT = 1000000;

    address private rewardsContract;

    bytes32 private constant SET_REWARD_TOPIC = keccak256("SetReward(address,uint256)");
    //topic_1->address
    //topic_2->uint256
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

        address user=address(uint160(log.topic_1));

        bytes memory payload = abi.encodeWithSignature("claim(address,address)",address(0),user);
        emit Callback(log.chain_id, rewardsContract, GAS_LIMIT, payload);
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
}
