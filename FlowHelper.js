const EC = require("elliptic").ec;
const SHA3 = require("sha3").SHA3;
const Buffer = require("buffer").Buffer;
const fcl = require("@onflow/fcl");

const ec = new EC("secp256k1");

const hashMsgHex = (msgHex) => {
    const sha = new SHA3(256);
    sha.update(Buffer.from(msgHex, "hex"));
    return sha.digest();
};

const sign = (privateKey, msgHex) => {
    const key = ec.keyFromPrivate(privateKey);
    const sig = key.sign(hashMsgHex(msgHex));
    const n = 32;
    const r = sig.r.toArrayLike(Buffer, "be", n);
    const s = sig.s.toArrayLike(Buffer, "be", n);
    return Buffer.concat([r, s]).toString("hex");
};

const authorizationFunction = (
  accountAddress,
  keyId,
  privateKey
) => {
  return async (account) => {
      return {
          ...account,
          tempId: `${accountAddress}-${keyId}`,
          addr: fcl.sansPrefix(accountAddress),
          keyId: keyId,
          signingFunction: (signable) => {
              return {
                  addr: fcl.withPrefix(accountAddress),
                  keyId: keyId,
                  signature: sign(privateKey, signable.message),
              };
          },
      };
  };
};

const startTransaction = async (
  transactionCode,
  transactionArgs
) => {
  // hardcoded for service account on emulator
  const address = "0xf8d6e0586b0a20c7"
  const keyId = 0;
  const privateKey = "6d12eebfef9866c9b6fa92b97c6e705c26a1785b1e7944da701fc545a51d4673"
  const authorization = authorizationFunction(
      address,
      keyId,
      privateKey
  );

  const response = await fcl.mutate({
    cadence: transactionCode,
    args: transactionArgs,
    authorizations: [authorization],
    proposer: authorization,
    payer: authorization,
    limit: 9999,
  });

  return await fcl.tx(response).onceSealed();
}

module.exports = {
  startTransaction
}
