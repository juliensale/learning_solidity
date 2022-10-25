const { BN } = require('bn.js')
const { expect } = require('chai')
require('chai').use(require('chai-as-promised')).should()

const CryptoTemplesTest = artifacts.require('CryptoTemplesTest')
const [templeName1, templeName2, templeName3] = [
    'Alice Temple',
    "Bob's Kingdom",
    'Charlie Temple',
    'David Temple',
]
contract('CryptoTemplesTest', (accounts) => {
    let [alice, bob, charlie, david] = accounts
    let contractInstance
    beforeEach(async () => {
        contractInstance = await CryptoTemplesTest.new()
    })

    it('should create a zombie for two users', async () => {
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
            await contractInstance.createTemple(templeName3, { from: charlie })
        })

        it('should not be able to create two zombies for the same user', async () => {
            await contractInstance
                .createTemple('wrongTemple', { from: alice })
                .should.be.rejectedWith('A user may only have one temple.')
        })

        it('should retrieve the right temple', async () => {
            const result1 = await contractInstance.getTemple({ from: alice })
            expect(result1.name).to.equal(templeName1)
            const result2 = await contractInstance.getTemple({ from: bob })
            expect(result2.name).to.equal(templeName2)
        })

        it('should retrieve no temple', async () => {
            await contractInstance
                .getTemple({ from: david })
                .should.be.rejectedWith('No temple is assigned to this address.')
        })

        /**
         * values found in the experience table on https://bulbapedia.bulbagarden.net/wiki/Experience
         * refering to the total experience for the slow formula
         */
        it('should calculate the right amout of exp required for the next level', async () => {
            const result1 = await contractInstance.getNextLevelExp(1)
            const result2 = await contractInstance.getNextLevelExp(2)
            const result14 = await contractInstance.getNextLevelExp(14)
            expect(new BN(result1).toNumber()).to.equal(10)
            expect(new BN(result2).toNumber()).to.equal(33)
            expect(new BN(result14).toNumber()).to.equal(4218)
        })

        it('should calculate the right amount of exp gained depending on the levels', async () => {
            const result1_1 = await contractInstance.getGainedExp(1, 1)
            const result1_2 = await contractInstance.getGainedExp(1, 2)
            const result7_6 = await contractInstance.getGainedExp(7, 6)

            expect(new BN(result1_1).toNumber()).to.equal(31)
            expect(new BN(result1_2).toNumber()).to.equal(70)
            expect(new BN(result7_6).toNumber()).to.equal(165)
        })

        it('a temple should have 100 engergy points in total', async () => {
            const result = await contractInstance.getTemple({ from: alice })
            expect(
                parseInt(result.waterEnergy) +
                    parseInt(result.fireEnergy) +
                    parseInt(result.grassEnergy),
            ).to.equal(100)
        })
    })
})
