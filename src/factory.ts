import { ProxyCreation } from '../generated/GnosisSafeProxyFactory/GnosisSafeProxyFactory'
import { GnosisSafe  } from '../generated/templates/GnosisSafe/GnosisSafe'
import { Wallet } from '../generated/schema'
import { GnosisSafe as GnosisSafeContract } from '../generated/templates'
import { Bytes, dataSource, Address } from '@graphprotocol/graph-ts'

export function handleProxyCreation(event: ProxyCreation): void {

  let safeInstance = GnosisSafe.bind(event.params.proxy)

  let wallet = new Wallet(event.params.proxy.toHex())
  wallet.creator             = event.transaction.from
  wallet.network             = dataSource.network()
  wallet.stamp               = event.block.timestamp
  wallet.hash                = event.transaction.hash
  wallet.factory             = event.address as Address
  wallet.owners              = safeInstance.getOwners() as Bytes[]
  wallet.threshold           = safeInstance.getThreshold()
  wallet.transactions        = []

  wallet.save()

  // Instanciate a new datasource
  GnosisSafeContract.create(event.params.proxy)
}

