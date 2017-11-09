const should = require('chai')
    .use(require('chai-as-promised'))
    .should()
const expect = require('chai').expect;


// --- Artifacts
const Renthereum = artifacts.require("./Renthereum.sol");

// --- Test variables 
let owner = null;
let customer = null;
let renthereum = null;
let items = [];

contract('Renthereum', accounts => {

    before( done => {
        owner = accounts[0];
        customer = accounts[1];
        Renthereum.new().then(contract => {
            renthereum = contract;
            done();
        })
    })
    
    it("should rent an item", done => {
        renthereum.createOrder('123456789','bike','a great bike', 23, 1, 30, {from: owner}).then(transaction => {
            should.exist(transaction.tx);
            renthereum.Ordered( { _id : '123456789' }).watch((err, log) => {
                const event = log.args;
                expect(event).to.include.all.keys([
                    '_index',
                    '_id',
                    '_owner',
                    '_name',
                    '_value'
                ]);
                assert.equal(event._owner, owner, "The user must be the owner of the rent order");
                items.push(event);
                renthereum.Ordered().stopWatching();
                done();       
             })
        })
    })

    it("should cancel a rent order", done => {
        let itemIndex = items[0]._index;
        renthereum.cancelOrder(itemIndex, {from: owner}).then(transaction => {
            should.exist(transaction.tx);
            renthereum.Canceled( { _id : '123456789' }).watch((err, log) => {
                const event = log.args;
                expect(event).to.include.all.keys([
                    '_id',
                    '_owner',
                    '_name',
                    '_value'
                ]);
                assert.equal(event._owner, owner, "The user must be the owner of the rent order");
                done();        
            })
        })
    })

    it("should rent an second item", done => {
        renthereum.createOrder('1234567891','car','a great car', 1200, 1, 180, {from: owner}).then(transaction => {
            should.exist(transaction.tx);
            renthereum.Ordered( { _id : '1234567891' }).watch((err, log) => {
                const event = log.args;
                items.push(event);    
                done();        
            })
        })
    })

    it("should rent an item", done => {
        let itemIndex = items[1]._index;
        renthereum.rent(itemIndex, 30, {from: customer, value: 1200 * 30}).then(transaction => {
            should.exist(transaction.tx);
            renthereum.Rented( { _customer : customer }).watch((err, log) => {
                const event = log.args;
                expect(event).to.include.all.keys([
                    '_owner',
                    '_customer',
                    '_period',
                    '_value'
                ]);
                assert.equal(event._customer, customer, "The user must be the customer of the order");
                done();              
            })
        })
    })

})