const { expect } = require('chai')
require('chai').use(require('chai-as-promised')).should()

const CryptoTemples = artifacts.require('CryptoTemples')
const [templeName1, templeName2] = ['Alice Temple', "Bob's Kingdom"]
contract('CryptoTemples', (accounts) => {
    let [alice, bob] = accounts
    let contractInstance
    beforeEach(async () => {
        contractInstance = await CryptoTemples.new()
    })

    it('should create a zombie for both users', async () => {
        const result1 = await contractInstance.createTemple(templeName1, { from: alice })
        const result2 = await contractInstance.createTemple(templeName2, { from: bob })

        expect(result1.receipt.status).to.be.true
        expect(result2.receipt.status).to.be.true
        expect(result1.logs[0].args.name).to.be.equal(templeName1)
        expect(result2.logs[0].args.name).to.be.equal(templeName2)
    })

    context('when temples have been created', async () => {
        beforeEach(async () => {
            await contractInstance.createTemple(templeName1, { from: alice })
            await contractInstance.createTemple(templeName2, { from: bob })
        })

        it('should not be able to create two zombies for the same user', async () => {
            await contractInstance
                .createTemple('wrongTemple', { from: alice })
                .should.be.rejectedWith('A user may only have one temple.')
        })
    })
})
