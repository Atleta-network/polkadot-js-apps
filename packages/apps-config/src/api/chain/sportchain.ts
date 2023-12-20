import type { OverrideBundleDefinition } from '@polkadot/types/types';

/* eslint-disable sort-keys */
const definitions: OverrideBundleDefinition = {
  types: [
    {
      minmax: [
        0,
        null
      ],
      types: {
        AccountId: "EthereumAccountId",
        Address: "AccountId",
        Balance: "u128",
        RefCount: "u8",
        LookupSource: "AccountId",
        Account: {
          nonce: "U256",
          balance: "u128"
        },
        EthTransaction: "LegacyTransaction",
        DispatchErrorModule: "DispatchErrorModuleU8",
        "EthereumSignature": {
          r: "H256",
          s: "H256",
          v: "U8"
        },
        ExtrinsicSignature: "EthereumSignature",
        TxPoolResultContent: {
          pending: "HashMap<H160, HashMap<U256, PoolTransaction>>",
          queued: "HashMap<H160, HashMap<U256, PoolTransaction>>"
        },
        TxPoolResultInspect: {
          pending: "HashMap<H160, HashMap<U256, Summary>>",
          queued: "HashMap<H160, HashMap<U256, Summary>>"
        },
        TxPoolResultStatus: {
          pending: "U256",
          queued: "U256"
        },
        Summary: "Bytes",
        PoolTransaction: {
          hash: "H256",
          nonce: "U256",
          blockHash: "Option<H256>",
          blockNumber: "Option<U256>",
          from: "H160",
          to: "Option<H160>",
          value: "U256",
          gasPrice: "U256",
          gas: "U256",
          input: "Bytes"
        }
      }
    },
  ]
};

export default definitions;
