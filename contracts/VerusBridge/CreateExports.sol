// SPDX-License-Identifier: MIT
// Bridge between ethereum and verus

pragma solidity >=0.6.0 <0.9.0;
pragma abicoder v2;

import "../Libraries/VerusObjects.sol";
import "../Libraries/VerusConstants.sol";
import "./Token.sol";
import "../Storage/StorageMaster.sol";

contract CreateExports is VerusStorage {

    function subtractPoolSize(uint64 _amount) private returns (bool) {

        if(_amount > poolSize) return false;
        poolSize -= _amount;
        return true;
    }
 
    function export(bytes calldata data) payable external {

        uint256 fees;

        VerusObjects.CReserveTransfer memory transfer = abi.decode(data, (VerusObjects.CReserveTransfer));

        address verusExportManagerAddress = contracts[uint(VerusConstants.ContractType.ExportManager)];

        (bool success, bytes memory feeBytes) = verusExportManagerAddress.delegatecall(abi.encodeWithSignature("checkExport(bytes,uint256)", data, uint256(msg.value)));
        require(success, "checkExport call failed");

        fees = abi.decode(feeBytes, (uint256)); //fees = exportManager.checkExport(transfer, paidValue, poolAvailable);

        require(fees != 0, "CheckExport Failed Checks"); 

        if(!poolAvailable)
        {
            require (subtractPoolSize(uint64(transfer.fees)));
        }

        if (transfer.currencyvalue.currency != VerusConstants.VEth && transfer.destination.destinationtype != VerusConstants.DEST_ETHNFT) {

            VerusObjects.mappedToken memory mappedContract = verusToERC20mapping[transfer.currencyvalue.currency];
            Token token = Token(mappedContract.erc20ContractAddress); 
            //Check user has allowed the verusBridgeStorage contract to spend on their behalf
            uint256 allowedTokens = token.allowance(msg.sender, address(this));
            uint256 tokenAmount = convertFromVerusNumber(transfer.currencyvalue.amount, token.decimals()); //convert to wei from verus satoshis
            require( allowedTokens >= tokenAmount);
            //transfer the tokens to the delegator contract
            //total amount kept as wei until export to verus
            exportERC20Tokens(tokenAmount, token, mappedContract.flags & VerusConstants.MAPPING_VERUS_OWNED == VerusConstants.MAPPING_VERUS_OWNED, msg.sender );
            
        } else if (transfer.destination.destinationtype == VerusConstants.DEST_ETHNFT){
            //handle a NFT Import
                
            address destinationAddress;
            uint8 desttype;
            address nftContract;
            uint256 tokenId;
            bytes memory serializedDest;
            serializedDest = transfer.destination.destinationaddress;  
            // 1byte desttype + 20bytes destinationaddres + 20bytes NFT address + 32bytes NFTTokenI
            assembly
            {
                desttype := mload(add(serializedDest, 1))
                destinationAddress := mload(add(serializedDest, 21))
                tokenId := mload(add(serializedDest, 53))  // cant have constant in assebmly == VerusConstants.VERUS_NFT_DEST_LENGTH
            }

            VerusObjects.mappedToken memory mappedContract = verusToERC20mapping[transfer.currencyvalue.currency];
            nftContract = mappedContract.erc20ContractAddress;
            require (serializedDest.length == VerusConstants.VERUS_NFT_DEST_LENGTH && (desttype == VerusConstants.DEST_PKH || desttype == VerusConstants.DEST_ID) && destinationAddress != address(0), "NFT packet wrong length/dest wrong");

            VerusNft nft = VerusNft(nftContract);
            require (nft.getApproved(tokenId) == address(this), "NFT not approved");

            nft.transferFrom(msg.sender, address(this), tokenId);
            
            if(transfer.currencyvalue.currency == VerusConstants.VerusNFTID)
            {
                nft.burn(tokenId);
            }

            transfer.destination.destinationtype = desttype;
            transfer.destination.destinationaddress = abi.encodePacked(destinationAddress);
 
        } 
        _createExports(transfer, false);
    }

    function exportERC20Tokens(uint256 _tokenAmount, Token token, bool burn, address sender ) private {
        
        (bool success, ) = address(token).call(abi.encodeWithSignature("transferFrom(address,address,uint256)", sender, address(this), _tokenAmount));
        require(success, "transferfrom of token failed");

        if (burn) 
        {
            token.burn(_tokenAmount);
        }
    }

    function externalCreateExportCall(bytes memory data) public {

        (VerusObjects.CReserveTransfer memory reserveTransfer, bool forceNewCCE) = abi.decode(data, (VerusObjects.CReserveTransfer, bool));

        _createExports(reserveTransfer, forceNewCCE);
    }

    function _createExports(VerusObjects.CReserveTransfer memory reserveTransfer, bool forceNewCCE) private {

        // Create CCE: If transactions in transfers > 50 and on same block then revert.
        // If transactions over 50 and inbetween notarization boundaries, increment CCE start and endheight
        // If notarization happens increment CCE to next boundary
        // If changing from pool closed to pool open create a boundary (As all sends will then go through the bridge)
        uint64 blockNumber = uint64(block.number);
        uint64 cceStartHeight = cceLastStartHeight;
        uint64 cceEndHeight = cceLastEndHeight;
        uint64 lastCCEExportHeight = cceLastStartHeight;
        uint64 blockDelta = cceEndHeight - (cceStartHeight == 0 ? cceEndHeight : cceStartHeight);


        VerusObjects.CReserveTransferSet memory temptx = _readyExports[cceStartHeight];

        // if there are no transfers then there is no need to make a new CCE as this is the first one, and the endheight can become the block number if it is less than the current block no.
        // if the last notary received height is less than the endheight then keep building up the CCE (as long as 10 ETH blocks havent passed, and anew CCE isnt being forced and there is less than 50)

        if ((temptx.transfers.length < 1 || (notaryHeight < cceEndHeight && blockDelta < 10)) && !forceNewCCE  && temptx.transfers.length < 50) {

            // set the end height of the CCE to the current block.number only if the current block we are on is greater than its value
            if (cceEndHeight < blockNumber) {
                cceEndHeight = blockNumber;
            }
        // if a new CCE is triggered for any reason, its startblock is always the previous endblock +1, 
        // its start height may of spilled in to virtual future block numbers so if the current cce start height is less than the block we are on we can update the end 
        // height to a new greater value.  Otherwise if the startheight is still in the future then the endheight is also in the future at the same block.
        } else {
            cceStartHeight = cceEndHeight + 1;

            if (cceStartHeight < blockNumber) {
                cceEndHeight = blockNumber;
            } else {
                cceEndHeight = cceStartHeight;
            }
        }

        setReadyExportTransfers(cceStartHeight, cceEndHeight, reserveTransfer, 50);

        VerusObjects.CReserveTransferSet memory pendingTransfers = _readyExports[cceStartHeight];

        address crossChainExportAddress = contracts[uint(VerusConstants.ContractType.VerusCrossChainExport)];

        (bool success, bytes memory returnData) = crossChainExportAddress.call(abi.encodeWithSignature("generateCCE(bytes)", abi.encode(pendingTransfers.transfers, poolAvailable, cceStartHeight, cceEndHeight, contracts[uint(VerusConstants.ContractType.VerusSerializer)])));
        require(success, "generateCCEfailed");

        bytes memory serializedCCE = abi.decode(returnData, (bytes)); 
        bytes32 prevHash;
 
        if(pendingTransfers.transfers.length == 1)
        {
            prevHash = _readyExports[lastCCEExportHeight].exportHash;
            cceLastStartHeight = cceStartHeight;
            cceLastEndHeight = cceEndHeight;
        } 
        else 
        {
            prevHash = pendingTransfers.prevExportHash;
        }
          
        setReadyExportTxid(keccak256(abi.encodePacked(serializedCCE, prevHash)), prevHash, cceStartHeight);

    }

    function setReadyExportTxid(bytes32 txidhash, bytes32 prevTxidHash, uint _block) private {
        
        _readyExports[_block].exportHash = txidhash;

        if (_readyExports[_block].transfers.length == 1)
        {
            _readyExports[_block].prevExportHash = prevTxidHash;

        }
    }

    function setReadyExportTransfers(uint64 _startHeight, uint64 _endHeight, VerusObjects.CReserveTransfer memory reserveTransfer, uint blockTxLimit) private {
        
        _readyExports[_startHeight].endHeight = _endHeight;
        _readyExports[_startHeight].transfers.push(reserveTransfer);
        require(_readyExports[_startHeight].transfers.length <= blockTxLimit);
      
    }
        
    function convertFromVerusNumber(uint256 a,uint8 decimals) public pure returns (uint256) {
        uint8 power = 10; //default value for 18
        uint256 c = a;

        if(decimals > 8 ) {
            power = decimals - 8;// number of decimals in verus
            c = a * (10 ** power);
        }else if(decimals < 8){
            power = 8 - decimals;// number of decimals in verus
            c = a / (10 ** power);
        }
      
        return c;
    }

}
