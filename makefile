-include .env

deploy-script:
	@forge script script/Counter.s.sol:HackBlockedScript --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) -- --vvvv

hack:
	@forge script script/hack.s.sol:HackScript --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -- --vvvvv

hack2:    
	@forge script script/AaveInteract.s.sol:AaveScript --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -- --vvvvv --gas-price 6000000000

hackLisk:    
	@forge script script/AaveLiskInteract.s.sol:AaveLiskInteract --rpc-url $(LISK_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -- --vvvvv --gas-price 6000000000

hack3:
	@forge script script/AddLiquidityLisk.s.sol:AddLiquidityLiskScript --rpc-url $(LISK_RPC_URL) --private-key $(LISK_PRIVATE_KEY) --broadcast -- --vvvvv --gas-price 6000000000

hack4:
	@forge script script/Uniswap.s.sol:UniswapScript --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -- --vvvvv --etherscan-api-key $(ETHERSCAN_API_KEY) --verify  --gas-price 6000000000

deploy-create:
	@forge create src/Counter.sol:HackScript --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --etherscan-api-key $(ETHERSCAN_API_KEY) --verify 

verify:
	@forge verify-contract --chain 11155111 --rpc-url $(SEPOLIA_RPC_URL) $(CONTRACT_ADDRESS) $(CONTRACT_PATH):$(CONTRACT_NAME)



# fetch-interface:
# 	@cast interface -o src/Hack.sol addy -c 84532
