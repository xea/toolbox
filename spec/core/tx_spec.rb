require 'core/tx'

RSpec.describe CoreTransaction do

    class FakeCore

        attr_reader :committed_txs

        def commit_tx(requests)
            @committed_txs = requests
        end

        def test_method_noargs
        end
    end

    context "#initialize" do
        it "should begin a clean transaction" do
            core = FakeCore.new
            tx = CoreTransaction.new core

            tx.commit

            expect(core.committed_txs).to eq([])
        end
    end

    context "#commit" do
        it "should commit added request" do
            core = FakeCore.new
            tx = CoreTransaction.new core

            tx.test_method_noargs
            tx.commit

            expect(core.committed_txs.length).to eq(1)
            expect(core.committed_txs).to eq([{:method=>:test_method_noargs, :args=>[], :block=>nil}])
        end

        it "should add all subsequent requests" do
            core = FakeCore.new
            tx = CoreTransaction.new core

            tx.test_method_noargs
            tx.test_method_noargs
            tx.test_method_noargs
            tx.commit

            expect(core.committed_txs.length).to eq(3)
            (0...2).each { |i| expect(core.committed_txs[i]).to eq({:method=>:test_method_noargs, :args=>[], :block=>nil}) }
        end
    end

    context "#dirty?" do
        it "should return true once the tx is modified" do
            core = FakeCore.new
            tx = CoreTransaction.new core

            expect(tx.dirty?).to be(false)
            tx.test_method_noargs
            expect(tx.dirty?).to be(true)
        end

        it "should return false after a rollback" do
            core = FakeCore.new
            tx = CoreTransaction.new core

            expect(tx.dirty?).to be(false)
            tx.test_method_noargs
            tx.test_method_noargs
            expect(tx.dirty?).to be(true)
            tx.rollback
            expect(tx.dirty?).to be(false)
        end
    end

    context "#rollback" do
        it "should discard all uncommitted changes" do
            core = FakeCore.new
            tx = CoreTransaction.new core

            tx.test_method_noargs
            tx.rollback
            expect(tx.dirty?).to be(false)
            tx.commit

            expect(core.committed_txs).to eq([])
        end
    end

end
