// interface IAave {
//     function supply(
//         address asset,
//         uint256 amount,
//         address onBehalfOf,
//         uint16 referralCode
//     ) external;
// }

// contract AaveTest {
//     address userAddr = msg.sender;
//     uint32 chainId = 11155111;
//     address target = address(0); //Aave pool address

//     function supplyToken() external {
//         bytes memory message = abi.encodeWithSignature(
//             "function supply(address asset,uint256 amount,address onBehalfOf,uint16 referralCode) external;",
//             address(0),
//             100,
//             msg.sender,
//             0
//         );

//         Dispatcher.Dispatcher(address(this)).dispatch(
//             userAddr,
//             chainId,
//             message,
//             target
//         );
//     }
// }