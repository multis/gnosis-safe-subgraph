import { GnosisSafe, AddedOwner, RemovedOwner, ChangedThreshold,
    ExecutionSuccess, ExecutionFailure, ExecTransactionCall } from '../generated/templates/GnosisSafe/GnosisSafe'
import { Wallet, Transaction } from '../generated/schema'
import { oneBigInt, concat, zeroBigInt } from './utils'
import { log, Address, Bytes, crypto, ByteArray } from '@graphprotocol/graph-ts'

export function handleAddedOwner(event: AddedOwner): void {
    let walletAddr = event.address
    let wallet = Wallet.load(walletAddr.toHex())

    if(wallet != null) {
        let owners = wallet.owners
        owners.push(event.params.owner)
        wallet.owners = owners
        wallet.save()

    } else {
        log.warning("handleAddedOwner::Wallet {} not found", [walletAddr.toHexString()])
    }
}

export function handleRemovedOwner(event: RemovedOwner): void {
    let walletAddr = event.address
    let wallet = Wallet.load(walletAddr.toHex())

    if(wallet != null) {
        let owners = wallet.owners
        let index = owners.indexOf(event.params.owner, 0)
        if (index > -1) {
            owners.splice(index, 1)
        }
        wallet.owners = owners
        wallet.save()

    } else {
        log.warning("handleRemovedOwner::Wallet {} not found", [walletAddr.toHexString()])
    }
}

export function handleChangedThreshold(event: ChangedThreshold): void {
    let walletAddr = event.address
    let wallet = Wallet.load(walletAddr.toHex())

    if(wallet != null) {
        wallet.threshold = event.params.threshold
        wallet.save()

    } else {
        log.warning("handleChangedThreshold::Wallet {} not found", [walletAddr.toHexString()])
    }
}

export function handleExecutionSuccess(event: ExecutionSuccess): void {
    let walletAddr = event.address
    let wallet = Wallet.load(walletAddr.toHex())

    if(wallet != null) {
        let transaction = getTransaction(walletAddr, event.params.txHash)
        transaction.status = "EXECUTED"
        transaction.block = event.block.number
        transaction.hash = event.transaction.hash
        transaction.stamp = event.block.timestamp
        transaction.txhash = event.params.txHash
        transaction.payment = event.params.payment
        transaction.save()

        wallet = addTransactionToWallet(<Wallet> wallet, transaction)
        wallet.save()

    } else {
        log.warning("handleExecutionSuccess::Wallet {} not found", [walletAddr.toHexString()])
    }
}


export function handleExecutionFailure(event: ExecutionFailure): void {
    let walletAddr = event.address
    let wallet = Wallet.load(walletAddr.toHex())

    if(wallet != null) {
        let transaction = getTransaction(walletAddr, event.params.txHash)
        transaction.status = "FAILED"
        transaction.block = event.block.number
        transaction.hash = event.transaction.hash
        transaction.stamp = event.block.timestamp
        transaction.txhash = event.params.txHash
        transaction.payment = event.params.payment
        transaction.save()

        wallet = addTransactionToWallet(<Wallet> wallet, transaction)
        wallet.save()

    } else {
        log.warning("handleExecutionFailure::Wallet {} not found", [walletAddr.toHexString()])
    }
}

export function handleExecTransaction(call: ExecTransactionCall): void {
    let walletAddr = call.to
    let wallet = Wallet.load(walletAddr.toHex())

    let walletInstance = GnosisSafe.bind(walletAddr)

    if(wallet != null) {
        let currentNonce = walletInstance.nonce()
        let nonce = currentNonce.equals(zeroBigInt()) ? currentNonce : currentNonce.minus(oneBigInt())
        let txHash = walletInstance.getTransactionHash(
            call.inputs.to,
            call.inputs.value,
            call.inputs.data,
            call.inputs.operation,
            call.inputs.safeTxGas,
            call.inputs.baseGas,
            call.inputs.gasPrice,
            call.inputs.gasToken,
            call.inputs.refundReceiver,
            nonce)

        let transaction = getTransaction(walletAddr, txHash)

        if(call.inputs.data.length < 2700) { // max size of a column. In some very rare cases, the method data bytecode is very long 
            transaction.data = call.inputs.data
        } else {
            log.warning("wallet: {} transaction {} - cannot store transaction.data (too long), length: {}", 
                        [walletAddr.toHexString(), call.transaction.hash.toHexString(), ByteArray.fromI32(call.inputs.data.length).toHexString()])
        }        
        transaction.value = call.inputs.value
        transaction.destination = call.inputs.to
        transaction.signatures = call.inputs.signatures
        transaction.nonce = nonce
        transaction.operation = (call.inputs.operation == 0) ? "CALL" : "DELEGATE_CALL"
        transaction.estimatedSafeTxGas = call.inputs.safeTxGas
        transaction.estimatedBaseGas = call.inputs.baseGas
        transaction.gasToken = call.inputs.gasToken
        transaction.gasPrice =  call.inputs.gasPrice
        transaction.refundReceiver = call.inputs.refundReceiver
        transaction.save()

        wallet = addTransactionToWallet(<Wallet> wallet, transaction)
        wallet.currentNonce = currentNonce
        wallet.save()

    } else {
        log.warning("handleExecTransaction::Wallet {} not found", [walletAddr.toHexString()])
    }
}




/*
 * UTILS
 */

function getTransaction(wallet: Address, transctionHash: Bytes): Transaction {
    let id = crypto.keccak256(concat(wallet, transctionHash))
    
    let transaction = Transaction.load(id.toHexString())
    if(transaction == null) {
        transaction = new Transaction(id.toHexString())
    }

    return transaction as Transaction
}

function addTransactionToWallet(wallet: Wallet, transaction: Transaction): Wallet {
    let transactions = wallet.transactions

    if (transactions.indexOf(transaction.id, 0) == -1) {
        transactions.push(transaction.id)
        wallet.transactions = transactions
    }

    return wallet
}
